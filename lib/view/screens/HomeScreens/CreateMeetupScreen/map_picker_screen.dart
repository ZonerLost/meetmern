import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/utils/marker_helper.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/service/places_service.dart';

class MapPickerResult {
  final double latitude;
  final double longitude;
  final String address;

  const MapPickerResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  static const gmaps.LatLng _defaultCenter =
      gmaps.LatLng(51.5074, -0.1278); // London fallback

  /// Only these venue categories may be picked as a meetup location.
  static const Set<String> _allowedAmenities = <String>{
    'cafe',
    'restaurant',
    'bar',
    'pub',
  };

  static const Duration _searchDebounce = Duration(milliseconds: 350);
  static const Duration _venueFetchDebounce = Duration(milliseconds: 700);
  static const int _minimumQueryLength = 2;

  /// Radius (metres) to search for venues around the map centre.
  static const double _venueSearchRadiusMeters = 1600;

  /// Skip a venue refetch unless the centre moved at least this far.
  static const double _venueRefetchThresholdMeters = 350;

  gmaps.GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  gmaps.LatLng _center = _defaultCenter;

  final List<PlaceVenue> _searchResults = <PlaceVenue>[];
  Timer? _searchDebounceTimer;
  int _searchRequestId = 0;
  bool _loadingSearch = false;

  final List<PlaceVenue> _venues = <PlaceVenue>[];
  PlaceVenue? _selectedVenue;
  final Map<String, gmaps.BitmapDescriptor> _venueIcons =
      <String, gmaps.BitmapDescriptor>{};
  Set<gmaps.Marker> _markerCache = <gmaps.Marker>{};
  bool _loadingVenues = false;
  bool _venuesLoadedOnce = false;
  Timer? _venueFetchDebounceTimer;
  int _venueRequestId = 0;
  gmaps.LatLng? _lastVenueFetchCenter;
  String? _venueError;

  bool _loadingLocation = true;
  bool _confirming = false;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocusChange);
    _buildVenueIcons();
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = gmaps.LatLng(widget.initialLat!, widget.initialLng!);
      if ((widget.initialAddress ?? '').isNotEmpty) {
        _searchController.text = widget.initialAddress!;
      }
      _loadingLocation = false;
      _scheduleVenueFetch(immediate: true);
    } else {
      _fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _venueFetchDebounceTimer?.cancel();
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _handleSearchFocusChange() {
    if (!_searchFocusNode.hasFocus && mounted) {
      setState(() {
        _loadingSearch = false;
        _searchResults.clear();
      });
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() => _loadingLocation = false);
        _scheduleVenueFetch(immediate: true);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (!mounted) return;
      setState(() {
        _center = gmaps.LatLng(pos.latitude, pos.longitude);
        _loadingLocation = false;
      });
      _mapController?.animateCamera(gmaps.CameraUpdate.newLatLng(_center));
      _scheduleVenueFetch(immediate: true);
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
        _scheduleVenueFetch(immediate: true);
      }
    }
  }

  // ── Venue markers ─────────────────────────────────────────────────────────

  Future<void> _buildVenueIcons() async {
    for (final amenity in _allowedAmenities) {
      for (final selected in const <bool>[false, true]) {
        try {
          _venueIcons['$amenity${selected ? ':selected' : ''}'] =
              await MarkerHelper.buildVenueMarker(
            amenity: amenity,
            selected: selected,
          );
        } catch (_) {
          // Fall back to a default marker for this one (see _rebuildMarkers).
        }
      }
    }
    _rebuildMarkers();
  }

  void _rebuildMarkers() {
    final markers = <gmaps.Marker>{};
    for (final venue in _venues) {
      final isSelected = _selectedVenue?.id == venue.id;
      final iconKey = '${venue.amenity}${isSelected ? ':selected' : ''}';
      final icon = _venueIcons[iconKey] ??
          gmaps.BitmapDescriptor.defaultMarkerWithHue(
            isSelected
                ? gmaps.BitmapDescriptor.hueAzure
                : gmaps.BitmapDescriptor.hueOrange,
          );
      markers.add(
        gmaps.Marker(
          markerId: gmaps.MarkerId(venue.id),
          position: gmaps.LatLng(venue.latitude, venue.longitude),
          icon: icon,
          anchor: isSelected
              ? const Offset(0.5, 1.0)
              : const Offset(0.5, 0.5),
          zIndexInt: isSelected ? 2 : 1,
          infoWindow: gmaps.InfoWindow(
            title: venue.name,
            snippet: _amenityLabel(venue.amenity),
          ),
          onTap: () => _selectVenue(venue),
        ),
      );
    }
    if (!mounted) return;
    setState(() => _markerCache = markers);
  }

  void _selectVenue(PlaceVenue venue) {
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedVenue = venue;
      _center = gmaps.LatLng(venue.latitude, venue.longitude);
    });
    _rebuildMarkers();
    _mapController?.animateCamera(
      gmaps.CameraUpdate.newLatLng(
        gmaps.LatLng(venue.latitude, venue.longitude),
      ),
    );
  }

  // ── Venue loading (Google Places) ─────────────────────────────────────────

  void _scheduleVenueFetch({bool immediate = false}) {
    _venueFetchDebounceTimer?.cancel();
    if (immediate) {
      unawaited(_fetchNearbyVenues());
      return;
    }
    _venueFetchDebounceTimer =
        Timer(_venueFetchDebounce, () => unawaited(_fetchNearbyVenues()));
  }

  bool _shouldRefetchVenues() {
    final last = _lastVenueFetchCenter;
    if (last == null) return true;
    final moved = Geolocator.distanceBetween(
      last.latitude,
      last.longitude,
      _center.latitude,
      _center.longitude,
    );
    return moved >= _venueRefetchThresholdMeters;
  }

  Future<void> _fetchNearbyVenues({bool force = false}) async {
    if (!mounted) return;
    if (!force && !_shouldRefetchVenues()) return;

    final requestId = ++_venueRequestId;
    final target = _center;
    _lastVenueFetchCenter = target;

    setState(() {
      _loadingVenues = true;
      _venueError = null;
    });

    List<PlaceVenue> venues = <PlaceVenue>[];
    String? error;
    try {
      venues = await PlacesService.searchNearbyVenues(
        latitude: target.latitude,
        longitude: target.longitude,
        radiusMeters: _venueSearchRadiusMeters,
      );
      debugPrint('[MapPicker] Places returned ${venues.length} venues');
    } catch (e) {
      error = e.toString();
      debugPrint('[MapPicker] Places venue search failed: $e');
    }

    if (!mounted || requestId != _venueRequestId) return;

    setState(() {
      _loadingVenues = false;
      if (error != null) {
        _venueError = 'Could not load venues. Check your connection.';
        return;
      }
      _venues
        ..clear()
        ..addAll(venues);
      _venuesLoadedOnce = true;
      if (_selectedVenue != null &&
          !_venues.any((v) => v.id == _selectedVenue!.id)) {
        _selectedVenue = null;
      }
    });
    _rebuildMarkers();
  }

  // ── Search box (Google Places text search) ────────────────────────────────

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    final query = value.trim();
    if (query.length < _minimumQueryLength) {
      setState(() {
        _loadingSearch = false;
        _searchResults.clear();
      });
      return;
    }
    _searchDebounceTimer =
        Timer(_searchDebounce, () => unawaited(_runSearch(query)));
  }

  Future<void> _runSearch(String query) async {
    final requestId = ++_searchRequestId;
    setState(() => _loadingSearch = true);

    List<PlaceVenue> results = <PlaceVenue>[];
    try {
      results = await PlacesService.searchText(
        query,
        latitude: _center.latitude,
        longitude: _center.longitude,
      );
    } catch (e) {
      debugPrint('[MapPicker] search failed: $e');
    }

    if (!mounted || requestId != _searchRequestId) return;
    setState(() {
      _loadingSearch = false;
      _searchResults
        ..clear()
        ..addAll(results);
    });
  }

  Future<void> _pickSearchResult(PlaceVenue result) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _searchController.text = result.name;
      _searchResults.clear();
      _loadingSearch = false;
      _center = gmaps.LatLng(result.latitude, result.longitude);
    });
    await _mapController?.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: gmaps.LatLng(result.latitude, result.longitude),
          zoom: 16,
        ),
      ),
    );

    // If the tapped result is itself a cafe/restaurant/bar/pub, select it.
    if (_allowedAmenities.contains(result.amenity)) {
      _selectVenue(result);
    }
    await _fetchNearbyVenues(force: true);
  }

  bool get _showSearchPanel =>
      _searchFocusNode.hasFocus &&
      (_loadingSearch ||
          _searchResults.isNotEmpty ||
          _searchController.text.trim().isNotEmpty);

  // ── Confirm ──────────────────────────────────────────────────────────────

  void _confirm() {
    final venue = _selectedVenue;
    if (venue == null) return;
    setState(() => _confirming = true);

    final address =
        venue.address.isNotEmpty ? '${venue.name}, ${venue.address}' : venue.name;

    Navigator.of(context).pop(
      MapPickerResult(
        latitude: venue.latitude,
        longitude: venue.longitude,
        address: address,
      ),
    );
  }

  static String _amenityLabel(String amenity) {
    switch (amenity) {
      case 'cafe':
        return 'Cafe';
      case 'restaurant':
        return 'Restaurant';
      case 'bar':
        return 'Bar';
      case 'pub':
        return 'Pub';
      default:
        return '';
    }
  }

  String get _selectionLabel {
    final venue = _selectedVenue;
    if (venue != null) {
      final type = _amenityLabel(venue.amenity);
      return type.isEmpty ? venue.name : '${venue.name} · $type';
    }
    if (_venueError != null) return _venueError!;
    if (_venuesLoadedOnce && _venues.isEmpty) {
      return 'No cafes, restaurants, bars or pubs here — move the map or search another area.';
    }
    return 'Tap a cafe, restaurant, bar or pub marker to pick it.';
  }

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return Scaffold(
      body: Stack(
        children: [
          gmaps.GoogleMap(
            initialCameraPosition:
                const gmaps.CameraPosition(target: _defaultCenter, zoom: 15),
            onMapCreated: (ctrl) {
              _mapController = ctrl;
              if (!_loadingLocation) {
                ctrl.animateCamera(gmaps.CameraUpdate.newLatLng(_center));
              }
            },
            onCameraMove: (pos) => _center = pos.target,
            onCameraIdle: () => _scheduleVenueFetch(),
            markers: _markerCache,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Top bar ──────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(6.w, 4.h, 12.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(left: 6.w),
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            autofocus: false,
                            textInputAction: TextInputAction.search,
                            textInputType: TextInputType.streetAddress,
                            onChanged: _onSearchChanged,
                            inputDecoration: InputDecoration(
                              hintText: 'Search area, then tap a venue',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 10.h,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        _loadingSearch
                            ? SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Icon(Icons.search,
                                size: 20.sp, color: appTheme.neutral_700),
                      ],
                    ),
                  ),
                  if (_showSearchPanel)
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 8.h, left: 6.w),
                      constraints: BoxConstraints(maxHeight: 240.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: _loadingSearch
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 18.h, horizontal: 16.w),
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _searchResults.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 18.h, horizontal: 16.w),
                                  child: Center(
                                    child: Text(
                                      _searchController.text.trim().length <
                                              _minimumQueryLength
                                          ? 'Type at least $_minimumQueryLength letters'
                                          : 'No places found',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: appTheme.neutral_600,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  itemCount: _searchResults.length,
                                  separatorBuilder: (_, __) => Divider(
                                    height: 1,
                                    color: appTheme.neutral_400
                                        .withValues(alpha: 0.25),
                                  ),
                                  itemBuilder: (context, index) {
                                    final r = _searchResults[index];
                                    return ListTile(
                                      dense: true,
                                      leading: Icon(
                                        Icons.location_on_outlined,
                                        size: 20.sp,
                                        color: appTheme.b_Primary,
                                      ),
                                      title: Text(
                                        r.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: appTheme.neutral_800,
                                        ),
                                      ),
                                      subtitle: r.address.isEmpty
                                          ? null
                                          : Text(
                                              r.address,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12.sp,
                                                color: appTheme.neutral_600,
                                              ),
                                            ),
                                      onTap: () => _pickSearchResult(r),
                                    );
                                  },
                                ),
                    ),
                ],
              ),
            ),
          ),

          // ── Venue loading pill ───────────────────────────────────────────
          if (_loadingVenues)
            Positioned(
              top: MediaQuery.of(context).padding.top + 120.h,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 14.w,
                        height: 14.w,
                        child:
                            const CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Finding cafes, restaurants, bars & pubs…',
                        style: TextStyle(
                            fontSize: 12.sp, color: appTheme.neutral_700),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Bottom selection + confirm ───────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Container(
                margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _selectedVenue == null
                              ? Icons.storefront_outlined
                              : Icons.check_circle,
                          size: 18.sp,
                          color: _selectedVenue == null
                              ? appTheme.neutral_500
                              : appTheme.b_Primary,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _selectionLabel,
                            style: styles.dobLabelTextStyle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (_selectedVenue != null &&
                        _selectedVenue!.address.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Padding(
                        padding: EdgeInsets.only(left: 26.w),
                        child: Text(
                          _selectedVenue!.address,
                          style: styles.locationTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        text: 'Confirm Venue',
                        buttonStyle: styles.loginButtonStyle,
                        buttonTextStyle: styles.loginButtonTextStyle,
                        isDisabled: _selectedVenue == null ||
                            _loadingLocation ||
                            _confirming,
                        onPressed: (_selectedVenue == null ||
                                _loadingLocation ||
                                _confirming)
                            ? null
                            : _confirm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_loadingLocation)
            const ColoredBox(
              color: Colors.white54,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
