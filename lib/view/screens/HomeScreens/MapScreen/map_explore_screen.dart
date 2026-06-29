import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meetmern/core/utils/marker_helper.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/home_controller/ExploreScreen/explore_meetups_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/view_meetup_screen.dart';

class MapExploreScreen extends StatefulWidget {
  const MapExploreScreen({super.key});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  static const LatLng _defaultCenter = LatLng(51.5074, -0.1278);

  final TextEditingController _searchCtrl = TextEditingController();
  GoogleMapController? _mapCtrl;

  LatLng? _currentPos;
  Meetup? _selectedMeetup;
  bool _loading = true;
  String _searchQuery = '';
  String? _typeFilter;

  List<Meetup> _allMeetups = [];
  final Map<String, LatLng> _coords = {};
  final Map<String, BitmapDescriptor> _bitmaps = {};
  BitmapDescriptor? _userBitmap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final ctrl = Get.find<ExploreController>();
    _allMeetups = List<Meetup>.from(ctrl.meetups);

    await Future.wait([
      _fetchCurrentLocation(),
      _resolveAllCoords(),
    ]);

    _userBitmap = await MarkerHelper.buildUserLocationMarker();
    await _buildAllBitmaps();

    if (mounted) {
      setState(() => _loading = false);
      _jumpToInitialCamera();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      if (mounted) setState(() => _currentPos = LatLng(pos.latitude, pos.longitude));
    } catch (_) {}
  }

  Future<void> _resolveAllCoords() async {
    await Future.wait(_allMeetups.map((m) async {
      if (m.latitude != null && m.longitude != null) {
        _coords[m.id] = LatLng(m.latitude!, m.longitude!);
      } else if (m.location.isNotEmpty) {
        try {
          final locs = await locationFromAddress(m.location);
          if (locs.isNotEmpty) {
            _coords[m.id] = LatLng(locs.first.latitude, locs.first.longitude);
          }
        } catch (_) {}
      }
    }));
  }

  Future<void> _buildAllBitmaps() async {
    await Future.wait(_allMeetups.map((m) async {
      if (!_coords.containsKey(m.id)) return;
      _bitmaps[m.id] = await MarkerHelper.buildMeetupMarker(m);
    }));
  }

  void _jumpToInitialCamera() {
    final target = _currentPos ??
        (_coords.isNotEmpty ? _coords.values.first : null);
    if (target != null) {
      _mapCtrl?.animateCamera(CameraUpdate.newLatLngZoom(target, 13));
    }
  }

  List<Meetup> get _filtered {
    return _allMeetups.where((m) {
      if (!_coords.containsKey(m.id)) return false;
      if (_typeFilter != null &&
          !m.type.toLowerCase().contains(_typeFilter!.toLowerCase())) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!m.title.toLowerCase().contains(q) &&
            !m.hostName.toLowerCase().contains(q) &&
            !m.location.toLowerCase().contains(q) &&
            !m.type.toLowerCase().contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  Set<Marker> get _markers {
    final out = <Marker>{};
    if (_currentPos != null && _userBitmap != null) {
      out.add(Marker(
        markerId: const MarkerId('__me__'),
        position: _currentPos!,
        icon: _userBitmap!,
        anchor: const Offset(0.5, 0.5),
        zIndexInt: 10,
      ));
    }
    for (final m in _filtered) {
      final pos = _coords[m.id];
      if (pos == null) continue;
      out.add(Marker(
        markerId: MarkerId(m.id),
        position: pos,
        icon: _bitmaps[m.id] ?? BitmapDescriptor.defaultMarker,
        anchor: const Offset(0.5, 1.0),
        zIndexInt: 5,
        onTap: () => setState(() => _selectedMeetup = m),
      ));
    }
    return out;
  }

  Set<Circle> get _circles {
    if (_currentPos == null) return {};
    return {
      Circle(
        circleId: const CircleId('__me_radius__'),
        center: _currentPos!,
        radius: 80,
        fillColor: const Color(0x221A73E8),
        strokeColor: const Color(0x551A73E8),
        strokeWidth: 1,
      ),
    };
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Google Map ────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPos ?? _defaultCenter,
              zoom: 13,
            ),
            onMapCreated: (c) {
              _mapCtrl = c;
              _jumpToInitialCamera();
            },
            markers: _markers,
            circles: _circles,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (_) => setState(() => _selectedMeetup = null),
          ),

          // ── Search bar + filter chips ─────────────────────────────────────
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SearchBar(
                  controller: _searchCtrl,
                  onBack: () => Navigator.of(context).pop(),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                SizedBox(height: 8.h),
                _FilterChips(
                  selected: _typeFilter,
                  onSelect: (t) => setState(() => _typeFilter = _typeFilter == t ? null : t),
                ),
              ],
            ),
          ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (_loading)
            const ColoredBox(
              color: Colors.white54,
              child: Center(child: CircularProgressIndicator()),
            ),

          // ── Bottom meetup card ────────────────────────────────────────────
          if (_selectedMeetup != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _MeetupBottomSheet(
                meetup: _selectedMeetup!,
                onClose: () => setState(() => _selectedMeetup = null),
                onViewMeetup: () {
                  final m = _selectedMeetup!;
                  setState(() => _selectedMeetup = null);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ViewMeetupScreen(meetup: m)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ── Search bar widget ─────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onBack;
  final ValueChanged<String> onChanged;

  const _SearchBar({
    required this.controller,
    required this.onBack,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
      child: Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 20),
              onPressed: onBack,
              color: Colors.black87,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 44.w),
            ),
            Icon(Icons.location_on_outlined, size: 18.sp, color: Colors.grey),
            SizedBox(width: 6.w),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search place or meetups',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: TextStyle(fontSize: 14.sp),
                onChanged: onChanged,
              ),
            ),
            SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }
}

// ── Filter chips ──────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _FilterChips({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const types = ['Coffee', 'Drinks', 'Meal'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: types.map((t) {
          final active = selected == t;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => onSelect(t),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: active ? appTheme.b_Primary : Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  t,
                  style: TextStyle(
                    color: active ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _MeetupBottomSheet extends StatelessWidget {
  final Meetup meetup;
  final VoidCallback onClose;
  final VoidCallback onViewMeetup;

  const _MeetupBottomSheet({
    required this.meetup,
    required this.onClose,
    required this.onViewMeetup,
  });

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String get _timeStr {
    final now = DateTime.now();
    final t = meetup.time;
    final isToday = t.year == now.year && t.month == now.month && t.day == now.day;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final period = t.hour < 12 ? 'AM' : 'PM';
    final min = t.minute == 0 ? '' : ':${t.minute.toString().padLeft(2, '0')}';
    final timeFormatted = '$h$min $period';
    return isToday
        ? 'Today, $timeFormatted'
        : '${_months[t.month - 1]} ${t.day}, $timeFormatted';
  }

  String get _locationStr {
    final parts = meetup.location
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (parts.length >= 2) return parts[parts.length - 2];
    return parts.isNotEmpty ? parts.first : meetup.location;
  }

  IconData get _typeIcon {
    switch (meetup.type.toLowerCase()) {
      case 'coffee':
        return Icons.coffee;
      case 'drink':
      case 'drinks':
        return Icons.local_bar;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: EdgeInsets.only(top: 10.h),
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            // Header row
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 8.w, 0),
              child: Row(
                children: [
                  Text(
                    'View Meetup',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    color: Colors.black54,
                  ),
                ],
              ),
            ),
            // Card
            GestureDetector(
              onTap: onViewMeetup,
              child: Container(
                margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meetup.title,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 6.w),
                              Icon(_typeIcon,
                                  size: 20.sp, color: appTheme.b_Primary),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined,
                                  size: 15.sp, color: appTheme.b_Primary),
                              SizedBox(width: 6.w),
                              Text(_timeStr,
                                  style: TextStyle(
                                      fontSize: 13.sp, color: Colors.black87)),
                            ],
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(Icons.my_location,
                                  size: 15.sp, color: appTheme.b_Primary),
                              SizedBox(width: 6.w),
                              Expanded(
                                child: Text(
                                  _locationStr.isNotEmpty
                                      ? 'Near $_locationStr'
                                      : meetup.location,
                                  style: TextStyle(
                                      fontSize: 13.sp, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    // Photo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: meetup.image.isNotEmpty &&
                              meetup.image.startsWith('http')
                          ? Image.network(
                              meetup.image,
                              width: 88.w,
                              height: 88.h,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _Placeholder(type: meetup.type),
                            )
                          : _Placeholder(type: meetup.type),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String type;
  const _Placeholder({required this.type});

  @override
  Widget build(BuildContext context) {
    final color = MarkerHelper.typeColor(type);
    IconData icon;
    switch (type.toLowerCase()) {
      case 'coffee':
        icon = Icons.coffee;
        break;
      case 'drink':
      case 'drinks':
        icon = Icons.local_bar;
        break;
      default:
        icon = Icons.restaurant;
    }
    return Container(
      width: 88.w,
      height: 88.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, size: 32.sp, color: color),
    );
  }
}
