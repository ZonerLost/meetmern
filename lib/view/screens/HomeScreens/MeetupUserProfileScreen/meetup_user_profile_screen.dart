import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/home_controller/MeetupUserProfileScreen/meetup_user_profile_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/view_meetup_screen.dart';

class MeetupUserProfileScreen extends StatefulWidget {
  final Meetup meetup;
  final bool showRequestButton;

  const MeetupUserProfileScreen({
    required this.meetup,
    this.showRequestButton = true,
    super.key,
  });

  @override
  State<MeetupUserProfileScreen> createState() =>
      _MeetupUserProfileScreenState();
}

class _MeetupUserProfileScreenState extends State<MeetupUserProfileScreen> {
  final MeetupUserProfileController _controller =
      Get.find<MeetupUserProfileController>();
  final Strings _strings = const Strings();

  static const Color _textPrimary = Color(0xFF222B45);
  static const Color _textSecondary = Color(0xFF3D4A63);
  static const Color _bg = Color(0xFFF4F5F7);
  static const Color _cardBorder = Color(0xFFD8D8D8);
  static const Color _chipBg = Color(0xFFE9E2FF);
  static const Color _chipText = Color(0xFF7A41F5);
  static const Color _accent = Color(0xFF5E37F5);

  static final double _headerHeight = 290.h;

  @override
  void initState() {
    super.initState();
    _controller.init(widget.meetup);
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return GetBuilder<MeetupUserProfileController>(
      builder: (c) {
        final currentMeetup = c.currentMeetup;
        final heroImage = _buildHeaderImage(c, currentMeetup);
        final displayName = _displayNameWithAge(c);
        final distance = currentMeetup.distanceKm > 0
            ? '${currentMeetup.distanceKm.toStringAsFixed(1)} km away'
            : 'Nearby';

        return Scaffold(
          backgroundColor: _bg,
          body: c.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          heroImage,
                          Positioned(
                            top: topInset + 6.h,
                            left: 14.w,
                            right: 14.w,
                            child: Row(
                              children: [
                                _circleIconButton(
                                  icon: Icons.arrow_back,
                                  onTap: () => context.popScreen(),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  icon: Container(
                                    width: 40.w,
                                    height: 40.w,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.28),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 22.sp,
                                    ),
                                  ),
                                  padding: EdgeInsets.zero,
                                  color: Colors.white,
                                  onSelected: (value) async {
                                    if (value == 'report') {
                                      final msg = await c.reportOwner(
                                        reason: _strings.reportReasonOtherValue,
                                        description:
                                            'Reported from meetup profile screen.',
                                      );
                                      if (!context.mounted) return;
                                      context.showCustomSnackBar(msg);
                                    } else if (value == 'block') {
                                      final wasBlocked = c.isOwnerBlockedByMe;
                                      final error = wasBlocked
                                          ? await c.unblockOwner()
                                          : await c.blockOwner();
                                      if (!context.mounted) return;
                                      if (error != null) {
                                        context.showCustomSnackBar(error);
                                      } else {
                                        final name = c.ownerName.isNotEmpty
                                            ? c.ownerName
                                            : 'User';
                                        if (wasBlocked) {
                                          context.showCustomSnackBar(
                                            _strings.unblockedUserSnackText
                                                .replaceAll('{name}', name),
                                          );
                                        } else {
                                          context.showCustomSnackBar(
                                            _strings.blockedUserSnack
                                                .replaceAll('{name}', name),
                                          );
                                          Get.offAllNamed(Routes.explore);
                                        }
                                      }
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Text(
                                        'Report Profile',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const PopupMenuDivider(),
                                    PopupMenuItem<String>(
                                      value: 'block',
                                      child: Text(
                                        c.isOwnerBlockedByMe
                                            ? 'Unblock This Person'
                                            : 'Block This Person',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Transform.translate(
                        offset: Offset(0, -14.h),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(22.r),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              18.w,
                              18.h,
                              18.w,
                              24.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: TextStyle(
                                          color: _textPrimary,
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    IconButton(
                                      onPressed: () async => c.toggleFavorite(),
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 34.w,
                                        minHeight: 34.h,
                                      ),
                                      icon: Icon(
                                        currentMeetup.isFavorite
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        color: _accent,
                                        size: 28.sp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Active today - $distance',
                                  style: TextStyle(
                                    color: _textSecondary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                _profileField(
                                  label: _strings.bioLabel,
                                  value: c.ownerBio.isNotEmpty
                                      ? c.ownerBio
                                      : _strings.notProvidedLabel,
                                ),
                                _profileField(
                                  label: _strings.genderLabel,
                                  value: c.ownerGender.isNotEmpty
                                      ? c.ownerGender
                                      : _strings.notProvidedLabel,
                                ),
                                _profileField(
                                  label: 'Relationship',
                                  value: c.ownerRelationshipStatus.isNotEmpty
                                      ? c.ownerRelationshipStatus
                                      : _strings.notProvidedLabel,
                                ),
                                _profileField(
                                  label: _strings.childrenLabel,
                                  value: c.ownerChildren.isNotEmpty
                                      ? c.ownerChildren
                                      : 'None',
                                ),
                                _profileField(
                                  label: _strings.religionLabel,
                                  value: c.ownerReligion.isNotEmpty
                                      ? c.ownerReligion
                                      : _strings.notProvidedLabel,
                                ),
                                _profileField(
                                  label: 'Language',
                                  value: c.ownerLanguages.isNotEmpty
                                      ? c.ownerLanguages.join(', ')
                                      : _strings.notProvidedLabel,
                                ),
                                _profileField(
                                  label: _strings.passionTopicsLabel,
                                  value: c.ownerPassionTopics.isNotEmpty
                                      ? c.ownerPassionTopics.join(', ')
                                      : _strings.notProvidedLabel,
                                ),
                                Text(
                                  _strings.interestsLabel,
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Wrap(
                                  spacing: 8.w,
                                  runSpacing: 8.h,
                                  children: (c.ownerInterests.isNotEmpty
                                          ? c.ownerInterests
                                          : <String>[currentMeetup.type])
                                      .map(
                                        (tag) => Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 14.w,
                                            vertical: 8.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _chipBg,
                                            borderRadius:
                                                BorderRadius.circular(999.r),
                                          ),
                                          child: Text(
                                            tag,
                                            style: TextStyle(
                                              color: _chipText,
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                                SizedBox(height: 18.h),
                                Text(
                                  _strings.meetupsLabel,
                                  style: TextStyle(
                                    color: _textPrimary,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ...c.ownerMeetups.take(4).map(
                                      (m) => Padding(
                                        padding: EdgeInsets.only(bottom: 10.h),
                                        child: _meetupTile(
                                          meetup: m,
                                          onTap: () => context.navigateToScreen(
                                            ViewMeetupScreen(meetup: m),
                                          ),
                                        ),
                                      ),
                                    ),
                                if (widget.showRequestButton) ...[
                                  SizedBox(height: 18.h),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 52.h,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6B35E7),
                                            Color(0xFF7B3FF8),
                                          ],
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100.r),
                                      ),
                                      child: ElevatedButton(
                                        onPressed: currentMeetup.joinRequested
                                            ? () => context.showCustomSnackBar(
                                                  'Request already sent',
                                                )
                                            : () => context.navigateToScreen(
                                                  ViewMeetupScreen(
                                                    meetup: currentMeetup,
                                                  ),
                                                ),
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0,
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(100.r),
                                          ),
                                        ),
                                        child: Text(
                                          currentMeetup.joinRequested
                                              ? _strings.requestedLabel
                                              : 'Request Meetup',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeaderImage(MeetupUserProfileController c, Meetup meetup) {
    final url = c.ownerPhotoUrl.isNotEmpty
        ? c.ownerPhotoUrl.trim()
        : meetup.image.trim();

    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18.r),
          bottomRight: Radius.circular(18.r),
        ),
        child: Image.network(
          url,
          width: double.infinity,
          height: _headerHeight,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/images/img9.jpg',
            width: double.infinity,
            height: _headerHeight,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(18.r),
        bottomRight: Radius.circular(18.r),
      ),
      child: Image.asset(
        url.isNotEmpty ? url : 'assets/images/img9.jpg',
        width: double.infinity,
        height: _headerHeight,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  Widget _profileField({
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _textPrimary,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 14.sp,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _meetupTile({
    required Meetup meetup,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        height: 145.h,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _cardBorder, width: 1.1),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meetup.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _textPrimary,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 28.w,
                          height: 28.w,
                          child: meetup.icon.isNotEmpty
                              ? Image.asset(meetup.icon, fit: BoxFit.contain)
                              : Icon(
                                  Icons.local_cafe_outlined,
                                  color: _accent,
                                  size: 22.sp,
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _miniRow(
                      icon: Icons.calendar_month_rounded,
                      text: _formatMeetupTime(meetup.time),
                    ),
                    SizedBox(height: 6.h),
                    _miniRow(
                      icon: Icons.my_location_rounded,
                      text: meetup.location,
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(17.r),
                bottomRight: Radius.circular(17.r),
              ),
              child: SizedBox(
                width: 130.w,
                height: double.infinity,
                child: meetup.image.startsWith('http')
                    ? Image.network(
                        meetup.image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/img9.jpg',
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        meetup.image.isNotEmpty
                            ? meetup.image
                            : 'assets/images/img9.jpg',
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFEDE8FF),
          ),
          child: Icon(icon, size: 14.sp, color: _accent),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatMeetupTime(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return sameDay
        ? 'Today, $hour $period'
        : '${dt.day}/${dt.month}, $hour $period';
  }

  String _displayNameWithAge(MeetupUserProfileController c) {
    final rawName = c.ownerName.trim().isNotEmpty ? c.ownerName.trim() : 'Host';
    final age = _ageFromDob(c.ownerDob);
    if (age == null) return rawName;
    return '$rawName, $age';
  }

  int? _ageFromDob(String rawDob) {
    if (rawDob.trim().isEmpty) return null;
    final parsed = DateTime.tryParse(rawDob.trim());
    if (parsed == null) return null;
    final now = DateTime.now();
    var age = now.year - parsed.year;
    final birthdayPassed = now.month > parsed.month ||
        (now.month == parsed.month && now.day >= parsed.day);
    if (!birthdayPassed) age--;
    if (age <= 0 || age > 120) return null;
    return age;
  }
}
