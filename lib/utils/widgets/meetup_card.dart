import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';

class MeetupCard extends StatelessWidget {
  final Meetup meetup;
  final VoidCallback? onFavorite;
  final VoidCallback onTap;
  final bool showFavorite;

  const MeetupCard({
    required this.meetup,
    this.onFavorite,
    required this.onTap,
    this.showFavorite = true,
    super.key,
  });

  String _formatMeetupTime(DateTime dt) {
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';

    return sameDay
        ? 'Today, $hour $period'
        : '${dt.day}/${dt.month}/${dt.year}, $hour $period';
  }

  bool _isNetwork(String path) => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;

    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth > 600;
        final double imageWidth =
            math.min(constraints.maxWidth * (isWide ? 0.34 : 0.36), 180.w);

        return Card(
          color: appTheme.coreWhite,
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(width: 1.w, color: appTheme.borderColor),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  meetup.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: customButtonandTextStyles
                                      .dobLabelTextStyle,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              SizedBox(
                                width: 36.w,
                                height: 36.w,
                                child: meetup.icon.isNotEmpty
                                    ? SizedBox(
                                        width: 22.w,
                                        height: 22.h,
                                        child: Image.asset(
                                          meetup.icon,
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.info_outline,
                                                  size: 18,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                width: 26.w,
                                height: 26.w,
                                decoration: BoxDecoration(
                                  color: appTheme.b_100,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.calendar_today_outlined,
                                    size: 12.sp,
                                    color: appTheme.b_600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  meetup.time is DateTime
                                      ? _formatMeetupTime(meetup.time)
                                      : meetup.time.toString(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: customButtonandTextStyles
                                      .locationTextStyle,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Container(
                                width: 26.w,
                                height: 26.w,
                                decoration: BoxDecoration(
                                  color: appTheme.b_50,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.my_location_outlined,
                                    size: 12.sp,
                                    color: appTheme.b_600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  meetup.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: customButtonandTextStyles
                                      .locationTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: SizedBox(
                      width: imageWidth,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          meetup.image.isNotEmpty
                              ? (_isNetwork(meetup.image)
                                  ? Image.network(
                                      meetup.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, st) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : Image.asset(
                                      meetup.image,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, st) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ))
                              : Container(color: Colors.grey.shade200),
                          if (showFavorite)
                            Positioned(
                              bottom: 8.h,
                              right: 8.w,
                              child: GestureDetector(
                                onTap: onFavorite,
                                child: Icon(
                                  meetup.isFavorite
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: meetup.isFavorite
                                      ? appTheme.blue
                                      : appTheme.coreWhite,
                                  size: 24.sp,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
