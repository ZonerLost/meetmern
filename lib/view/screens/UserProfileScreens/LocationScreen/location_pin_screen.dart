import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/service/places_service.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/map_picker_screen.dart'
    show MapPickerResult;

/// Free-form location picker: the user drops a pin anywhere (not restricted to
/// businesses). Used by the profile Location screen to set a discovery area.
class LocationPinScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final String? initialAddress;

  const LocationPinScreen({
    super.key,
    this.initialLat,
    this.initialLng,
    this.initialAddress,
  });

  @override
  State<LocationPinScreen> createState() => _LocationPinScreenState();
}

class _LocationPinScreenState extends State<LocationPinScreen> {
  static const gmaps.LatLng _defaultCenter = gmaps.LatLng(51.5074, -0.1278);

  gmaps.GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  gmaps.LatLng _center = _defaultCenter;
  String _address = '';
  bool _moving = false;
  bool _loadingAddress = false;
  bool _loadingLocation = true;

  final List<PlaceVenue> _searchResults = <PlaceVenue>[];
  Timer? _searchDebounce;
  int _searchRequestId = 0;
  bool _loadingSearch = false;

  Timer? _reverseDebounce;
  int _reverseRequestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = gmaps.LatLng(widget.initialLat!, widget.initialLng!);
      _address = widget.initialAddress ?? '';
      _loadingLocation = false;
      _reverseGeocode();
    } else {
      _fetchCurrentLocation();
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _reverseDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _loadingLocation = false);
        _reverseGeocode();
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
      _reverseGeocode();
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLocation = false);
        _reverseGeocode();
      }
    }
  }

  void _scheduleReverseGeocode() {
    _reverseDebounce?.cancel();
    _reverseDebounce =
        Timer(const Duration(milliseconds: 500), _reverseGeocode);
  }

  Future<void> _reverseGeocode() async {
    final requestId = ++_reverseRequestId;
    final target = _center;
    if (mounted) setState(() => _loadingAddress = true);

    String? label;
    try {
      label = await PlacesService.reverseGeocode(
        latitude: target.latitude,
        longitude: target.longitude,
      );
    } catch (_) {}

    if (!mounted || requestId != _reverseRequestId) return;
    setState(() {
      _loadingAddress = false;
      _address = label?.trim().isNotEmpty == true
          ? label!.trim()
          : '${target.latitude.toStringAsFixed(5)}, ${target.longitude.toStringAsFixed(5)}';
    });
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < 2) {
      setState(() {
        _loadingSearch = false;
        _searchResults.clear();
      });
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => unawaited(_runSearch(query)),
    );
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
    } catch (_) {}
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
      _searchController.clear();
      _searchResults.clear();
      _loadingSearch = false;
      _center = gmaps.LatLng(result.latitude, result.longitude);
    });
    await _mapController?.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(
          target: gmaps.LatLng(result.latitude, result.longitude),
          zoom: 15,
        ),
      ),
    );
    _reverseGeocode();
  }

  bool get _showSearchPanel =>
      _searchFocusNode.hasFocus &&
      (_loadingSearch ||
          _searchResults.isNotEmpty ||
          _searchController.text.trim().isNotEmpty);

  void _confirm() {
    Navigator.of(context).pop(
      MapPickerResult(
        latitude: _center.latitude,
        longitude: _center.longitude,
        address: _address,
      ),
    );
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
                const gmaps.CameraPosition(target: _defaultCenter, zoom: 14),
            onMapCreated: (ctrl) {
              _mapController = ctrl;
              if (!_loadingLocation) {
                ctrl.animateCamera(gmaps.CameraUpdate.newLatLng(_center));
              }
            },
            onCameraMove: (pos) {
              _center = pos.target;
              if (!_moving) setState(() => _moving = true);
            },
            onCameraIdle: () {
              if (_moving) setState(() => _moving = false);
              _scheduleReverseGeocode();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // Fixed centre pin
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: AnimatedSlide(
                  offset: _moving ? const Offset(0, -0.12) : Offset.zero,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(Icons.location_pin,
                      size: 46.sp, color: appTheme.b_Primary),
                ),
              ),
            ),
          ),

          // Top bar
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
                            textInputAction: TextInputAction.search,
                            textInputType: TextInputType.streetAddress,
                            onChanged: _onSearchChanged,
                            inputDecoration: InputDecoration(
                              hintText: 'Search a place or address',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 4.w, vertical: 10.h),
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
                                      'No places found',
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: appTheme.neutral_600),
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
                                      leading: Icon(Icons.location_on_outlined,
                                          size: 20.sp,
                                          color: appTheme.b_Primary),
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
                                                  color: appTheme.neutral_600),
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

          // Bottom address + confirm
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
                        Icon(Icons.location_on_outlined,
                            size: 18.sp, color: appTheme.b_Primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _loadingAddress
                              ? Text('Finding address…',
                                  style: styles.locationTextStyle)
                              : Text(
                                  _address.isNotEmpty
                                      ? _address
                                      : 'Move the map to place the pin',
                                  style: styles.dobLabelTextStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    SizedBox(
                      width: double.infinity,
                      child: CustomElevatedButton(
                        text: 'Confirm Location',
                        buttonStyle: styles.loginButtonStyle,
                        buttonTextStyle: styles.loginButtonTextStyle,
                        isDisabled: _loadingLocation,
                        onPressed: _loadingLocation ? null : _confirm,
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
