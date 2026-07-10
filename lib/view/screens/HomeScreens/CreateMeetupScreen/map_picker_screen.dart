import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:http/http.dart' as http;
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

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

class _PlaceSuggestion {
  final String title;
  final String subtitle;
  final String fullText;
  final double? latitude;
  final double? longitude;
  final double importance;
  final String type;
  final String category;
  final int placeRank;

  const _PlaceSuggestion({
    required this.title,
    required this.subtitle,
    required this.fullText,
    this.latitude,
    this.longitude,
    this.importance = 0,
    this.type = '',
    this.category = '',
    this.placeRank = 999,
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
  static const String _searchBaseUrl =
      'https://nominatim.openstreetmap.org/search';
  static const Duration _searchDebounceDuration = Duration(milliseconds: 350);
  static const Duration _minimumSearchRequestGap = Duration(seconds: 1);
  static const int _minimumQueryLength = 2;

  gmaps.GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  gmaps.LatLng _center = _defaultCenter;
  final List<_PlaceSuggestion> _suggestions = <_PlaceSuggestion>[];
  String _address = '';
  bool _dragging = false;
  bool _loadingAddress = false;
  bool _loadingLocation = true;
  bool _searching = false;
  bool _loadingSuggestions = false;
  Timer? _searchDebounce;
  int _suggestionsRequestId = 0;
  DateTime? _lastSearchRequestAt;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleSearchFocusChange);
    if (widget.initialLat != null && widget.initialLng != null) {
      _center = gmaps.LatLng(widget.initialLat!, widget.initialLng!);
      _address = widget.initialAddress ?? '';
      _searchController.text = _address;
      _loadingLocation = false;
    } else {
      _fetchCurrentLocation();
    }
  }

  void _handleSearchFocusChange() {
    if (!_searchFocusNode.hasFocus && mounted) {
      setState(() {
        _loadingSuggestions = false;
        _suggestions.clear();
      });
    } else if (_searchFocusNode.hasFocus) {
      final query = _searchController.text.trim();
      if (query.length >= _minimumQueryLength) {
        unawaited(_fetchSuggestions(query));
      }
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
      await _reverseGeocode(_center);
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  Future<void> _reverseGeocode(gmaps.LatLng pos) async {
    if (!mounted) return;
    setState(() => _loadingAddress = true);
    try {
      final marks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (!mounted) return;
      if (marks.isNotEmpty) {
        final p = marks.first;
        final nextAddress = [p.street, p.subLocality, p.locality, p.country]
            .where((s) => s != null && s.isNotEmpty)
            .join(', ');
        setState(() {
          _address = nextAddress;
          if (!_searchFocusNode.hasFocus && nextAddress.isNotEmpty) {
            _searchController.text = nextAddress;
          }
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingAddress = false);
    }
  }

  Future<void> _searchLocation() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || _searching) return;

    FocusScope.of(context).unfocus();
    setState(() => _searching = true);

    try {
      if (_suggestions.isNotEmpty) {
        await _selectSuggestion(_suggestions.first);
        return;
      }

      final found = await _moveToQueryLocation(query);
      if (!found && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No location found for that search.')),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to search that location.')),
      );
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();
    if (query.length < _minimumQueryLength) {
      if (mounted) {
        setState(() {
          _loadingSuggestions = false;
          _suggestions.clear();
        });
      }
      return;
    }

    _searchDebounce = Timer(
      _searchDebounceDuration,
      () => unawaited(_fetchSuggestions(query)),
    );
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < _minimumQueryLength) return;
    final requestId = ++_suggestionsRequestId;

    if (mounted) {
      setState(() => _loadingSuggestions = true);
    }

    try {
      final suggestions = await _fetchSuggestionsFromNominatim(query);
      if (!mounted || requestId != _suggestionsRequestId) return;

      setState(() {
        _loadingSuggestions = false;
        _suggestions
          ..clear()
          ..addAll(suggestions);
      });
    } catch (_) {
      await _fetchSuggestionsWithGeocoder(query, requestId);
    }
  }

  Future<void> _fetchSuggestionsWithGeocoder(
    String query,
    int requestId,
  ) async {
    try {
      final results = await locationFromAddress(query);
      if (!mounted || requestId != _suggestionsRequestId) return;

      final seen = <String>{};
      final built = <_PlaceSuggestion>[];

      for (final result in results.take(6)) {
        final fallbackTitle =
            '${result.latitude.toStringAsFixed(5)}, ${result.longitude.toStringAsFixed(5)}';
        String fullText = fallbackTitle;

        try {
          final marks = await placemarkFromCoordinates(
            result.latitude,
            result.longitude,
          );
          if (marks.isNotEmpty) {
            final p = marks.first;
            fullText = [
              p.name,
              p.street,
              p.subLocality,
              p.locality,
              p.administrativeArea,
              p.country,
            ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
          }
        } catch (_) {
          // Keep coordinate fallback if reverse lookup fails.
        }

        final normalized =
            fullText.trim().isNotEmpty ? fullText.trim() : fallbackTitle;
        if (!seen.add(normalized.toLowerCase())) continue;

        final parts = normalized.split(',');
        final title = parts.isNotEmpty ? parts.first.trim() : normalized;
        final subtitle = parts.length > 1
            ? parts.skip(1).map((part) => part.trim()).join(', ')
            : '';

        built.add(
          _PlaceSuggestion(
            title: title,
            subtitle: subtitle,
            fullText: normalized,
            latitude: result.latitude,
            longitude: result.longitude,
          ),
        );
      }

      if (!mounted || requestId != _suggestionsRequestId) return;
      setState(() {
        _loadingSuggestions = false;
        _suggestions
          ..clear()
          ..addAll(built);
      });
    } catch (_) {
      if (!mounted || requestId != _suggestionsRequestId) return;
      setState(() {
        _loadingSuggestions = false;
        _suggestions.clear();
      });
    }
  }

  Future<List<_PlaceSuggestion>> _fetchSuggestionsFromNominatim(
    String query,
  ) async {
    await _respectSearchRateLimit();
    final uri = Uri.parse(_searchBaseUrl).replace(
      queryParameters: <String, String>{
        'q': query,
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '10',
        'dedupe': '1',
        'viewbox': _buildViewBox(),
      },
    );

    final response = await http.get(
      uri,
      headers: <String, String>{
        'User-Agent': 'meetmern-mobile-app/1.0',
        'Accept-Language': _languageTag,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Search request failed');
    }

    final payload = jsonDecode(response.body);
    if (payload is! List) {
      throw const FormatException('Unexpected search response');
    }

    final normalizedQuery = _normalizeQuery(query);
    final suggestions = payload
        .whereType<Map<String, dynamic>>()
        .map(_suggestionFromNominatim)
        .where((suggestion) => suggestion.fullText.isNotEmpty)
        .toList();

    suggestions.sort(
      (a, b) => _compareSuggestions(
        a,
        b,
        normalizedQuery,
      ),
    );

    return suggestions;
  }

  Future<void> _selectSuggestion(_PlaceSuggestion suggestion) async {
    FocusScope.of(context).unfocus();
    if (mounted) {
      setState(() {
        _searching = true;
        _searchController.text = suggestion.fullText;
        _suggestions.clear();
        _loadingSuggestions = false;
      });
    }

    if (suggestion.latitude != null && suggestion.longitude != null) {
      await _moveToSuggestionLocation(
        latitude: suggestion.latitude!,
        longitude: suggestion.longitude!,
        formattedAddress: suggestion.fullText,
      );
      if (mounted) {
        setState(() => _searching = false);
      }
      return;
    }

    try {
      final query = suggestion.fullText.trim();
      if (query.isEmpty) {
        throw const FormatException('No place details found.');
      }
      await _moveToQueryLocation(query);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load that place.')),
      );
    } finally {
      if (mounted) {
        setState(() => _searching = false);
      }
    }
  }

  Future<bool> _moveToQueryLocation(String query) async {
    _PlaceSuggestion? match;
    try {
      final suggestions = await _fetchSuggestionsFromNominatim(query);
      if (suggestions.isNotEmpty) {
        match = suggestions.first;
      }
    } catch (_) {
      // Fall back to platform geocoder when network search is unavailable.
    }

    if (match?.latitude == null || match?.longitude == null) {
      final results = await locationFromAddress(query);
      if (!mounted || results.isEmpty) return false;

      final result = results.first;
      match = _PlaceSuggestion(
        title: query,
        subtitle: '',
        fullText: query,
        latitude: result.latitude,
        longitude: result.longitude,
      );
    }

    final resolvedMatch = match;
    if (!mounted ||
        resolvedMatch == null ||
        resolvedMatch.latitude == null ||
        resolvedMatch.longitude == null) {
      return false;
    }

    await _moveToSuggestionLocation(
      latitude: resolvedMatch.latitude!,
      longitude: resolvedMatch.longitude!,
      formattedAddress: resolvedMatch.fullText,
    );
    return true;
  }

  Future<void> _respectSearchRateLimit() async {
    final lastRequestAt = _lastSearchRequestAt;
    if (lastRequestAt != null) {
      final elapsed = DateTime.now().difference(lastRequestAt);
      if (elapsed < _minimumSearchRequestGap) {
        await Future.delayed(_minimumSearchRequestGap - elapsed);
      }
    }
    _lastSearchRequestAt = DateTime.now();
  }

  String get _languageTag {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale.toLanguageTag();
  }

  String _buildViewBox() {
    const latitudeDelta = 1.8;
    final longitudeDelta = math.max(
      1.8,
      1.8 /
          math.max(
            math.cos(_center.latitude * math.pi / 180).abs(),
            0.25,
          ),
    );
    final left = (_center.longitude - longitudeDelta).clamp(-180.0, 180.0);
    final right = (_center.longitude + longitudeDelta).clamp(-180.0, 180.0);
    final top = (_center.latitude + latitudeDelta).clamp(-90.0, 90.0);
    final bottom = (_center.latitude - latitudeDelta).clamp(-90.0, 90.0);
    return '$left,$top,$right,$bottom';
  }

  _PlaceSuggestion _suggestionFromNominatim(Map<String, dynamic> raw) {
    final displayName = (raw['display_name'] as String?)?.trim() ?? '';
    final name = (raw['name'] as String?)?.trim() ?? '';
    final title = name.isNotEmpty ? name : _extractTitle(displayName);
    final subtitle = _buildSubtitle(
      title: title,
      displayName: displayName,
      address: raw['address'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );

    return _PlaceSuggestion(
      title: title.isNotEmpty ? title : displayName,
      subtitle: subtitle,
      fullText: displayName,
      latitude: double.tryParse(raw['lat']?.toString() ?? ''),
      longitude: double.tryParse(raw['lon']?.toString() ?? ''),
      importance: (raw['importance'] as num?)?.toDouble() ?? 0,
      type: (raw['type'] as String?)?.trim() ?? '',
      category: (raw['category'] as String?)?.trim() ?? '',
      placeRank: (raw['place_rank'] as num?)?.toInt() ?? 999,
    );
  }

  String _extractTitle(String displayName) {
    if (displayName.isEmpty) return '';
    return displayName.split(',').first.trim();
  }

  String _buildSubtitle({
    required String title,
    required String displayName,
    required Map<String, dynamic> address,
  }) {
    final parts = <String>[
      address['suburb']?.toString() ?? '',
      address['city']?.toString() ?? '',
      address['state']?.toString() ?? '',
      address['country']?.toString() ?? '',
    ].where((part) => part.trim().isNotEmpty).toList();

    final subtitle = parts.join(', ');
    if (subtitle.isNotEmpty && subtitle != title) {
      return subtitle;
    }

    if (displayName.startsWith('$title, ')) {
      return displayName.substring(title.length + 2).trim();
    }

    return displayName == title ? '' : displayName;
  }

  int _compareSuggestions(
    _PlaceSuggestion a,
    _PlaceSuggestion b,
    String normalizedQuery,
  ) {
    final scoreA = _scoreSuggestion(a, normalizedQuery);
    final scoreB = _scoreSuggestion(b, normalizedQuery);
    if (scoreA != scoreB) return scoreB.compareTo(scoreA);

    if (a.importance != b.importance) {
      return b.importance.compareTo(a.importance);
    }

    if (a.placeRank != b.placeRank) {
      return a.placeRank.compareTo(b.placeRank);
    }

    return a.fullText.compareTo(b.fullText);
  }

  int _scoreSuggestion(_PlaceSuggestion suggestion, String normalizedQuery) {
    final normalizedTitle = _normalizeQuery(suggestion.title);
    final normalizedFullText = _normalizeQuery(suggestion.fullText);
    var score = 0;

    if (normalizedTitle == normalizedQuery) {
      score += 1000;
    } else if (normalizedTitle.startsWith(normalizedQuery)) {
      score += 700;
    } else if (normalizedFullText.startsWith(normalizedQuery)) {
      score += 500;
    } else if (normalizedFullText.contains(normalizedQuery)) {
      score += 200;
    }

    if (_isBroadPlaceType(suggestion.type, suggestion.category)) {
      score += 250;
    }

    if (_isAdministrativePlace(suggestion.type, suggestion.category)) {
      score += 100;
    }

    score += (suggestion.importance * 100).round();
    score -= suggestion.placeRank;
    return score;
  }

  bool _isBroadPlaceType(String type, String category) {
    const broadTypes = <String>{
      'city',
      'town',
      'village',
      'municipality',
      'administrative',
      'suburb',
      'county',
      'state',
      'province',
    };
    return category == 'place' || broadTypes.contains(type);
  }

  bool _isAdministrativePlace(String type, String category) {
    return category == 'boundary' || type == 'administrative' || type == 'city';
  }

  String _normalizeQuery(String value) {
    final lower = value.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final codeUnit in lower.codeUnits) {
      final isAlphaNum = (codeUnit >= 97 && codeUnit <= 122) ||
          (codeUnit >= 48 && codeUnit <= 57) ||
          codeUnit == 32;
      if (isAlphaNum) {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool get _showSuggestionsPanel =>
      _searchFocusNode.hasFocus &&
      (_searchController.text.trim().isNotEmpty ||
          _loadingSuggestions ||
          _suggestions.isNotEmpty);

  Future<void> _moveToSuggestionLocation({
    required double latitude,
    required double longitude,
    required String formattedAddress,
  }) async {
    final target = gmaps.LatLng(latitude, longitude);
    if (!mounted) return;

    setState(() {
      _center = target;
      _address = formattedAddress;
      _searchController.text = formattedAddress;
    });

    await _mapController?.animateCamera(
      gmaps.CameraUpdate.newCameraPosition(
        gmaps.CameraPosition(target: target, zoom: 16),
      ),
    );
    await _reverseGeocode(target);
  }

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
  void dispose() {
    _searchDebounce?.cancel();
    _searchFocusNode.removeListener(_handleSearchFocusChange);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
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
          // ── Map ──────────────────────────────────────────────────────────
          gmaps.GoogleMap(
            initialCameraPosition:
                const gmaps.CameraPosition(target: _defaultCenter, zoom: 15),
            onMapCreated: (ctrl) {
              _mapController = ctrl;
              if (!_loadingLocation) {
                ctrl.animateCamera(gmaps.CameraUpdate.newLatLng(_center));
              }
            },
            onCameraMove: (pos) {
              _center = pos.target;
              if (!_dragging) setState(() => _dragging = true);
            },
            onCameraIdle: () async {
              setState(() => _dragging = false);
              await _reverseGeocode(_center);
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),

          // ── Center pin (fixed overlay) ───────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSlide(
                  offset: _dragging ? const Offset(0, -0.15) : Offset.zero,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: Icon(
                    Icons.location_pin,
                    size: 48.sp,
                    color: appTheme.b_Primary,
                  ),
                ),
                // Shadow dot under pin
                AnimatedOpacity(
                  opacity: _dragging ? 0.4 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 10.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
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
                            onFieldSubmitted: (_) => _searchLocation(),
                            inputDecoration: InputDecoration(
                              hintText: 'Search places',
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
                        IconButton(
                          onPressed: _searching ? null : _searchLocation,
                          icon: _searching
                              ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  Icons.search,
                                  size: 20.sp,
                                  color: appTheme.neutral_700,
                                ),
                        ),
                      ],
                    ),
                  ),
                  if (_showSuggestionsPanel)
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
                      child: _loadingSuggestions
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 18.h, horizontal: 16.w),
                              child: const Center(
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : _suggestions.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 18.h,
                                    horizontal: 16.w,
                                  ),
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
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 8.h),
                                        itemCount: _suggestions.length,
                                        separatorBuilder: (_, __) => Divider(
                                          height: 1,
                                          color:
                                              appTheme.neutral_400.withValues(
                                            alpha: 0.25,
                                          ),
                                        ),
                                        itemBuilder: (context, index) {
                                          final suggestion =
                                              _suggestions[index];
                                          return ListTile(
                                            dense: true,
                                            leading: Icon(
                                              Icons.location_on_outlined,
                                              size: 20.sp,
                                              color: appTheme.b_Primary,
                                            ),
                                            title: Text(
                                              suggestion.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: appTheme.neutral_800,
                                              ),
                                            ),
                                            subtitle: suggestion
                                                    .subtitle.isEmpty
                                                ? null
                                                : Text(
                                                    suggestion.subtitle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 12.sp,
                                                      color:
                                                          appTheme.neutral_600,
                                                    ),
                                                  ),
                                            onTap: () =>
                                                _selectSuggestion(suggestion),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom address + confirm ─────────────────────────────────────
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
                                      : 'Move the map to select a location',
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
                        onPressed: (_loadingLocation || _loadingAddress)
                            ? null
                            : _confirm,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Loading overlay ──────────────────────────────────────────────
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
