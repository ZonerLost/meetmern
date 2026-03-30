import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';

class NearbyCard extends StatelessWidget {
  final Nearby nearby;
  final VoidCallback onRequest;
  final VoidCallback onTap;

  const NearbyCard({
    required this.nearby,
    required this.onRequest,
    required this.onTap,
    super.key,
  });

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
            math.min(constraints.maxWidth * (isWide ? 0.22 : 0.28), 160.w);

        return Card(
          color: appTheme.infieldColor,
          elevation: 0,
          margin: EdgeInsets.symmetric(vertical: 6.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.r),
            side: BorderSide(width: 1.w, color: appTheme.borderColor),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: SizedBox(
                      width: imageWidth,
                      height: imageWidth * 0.95,
                      child: _isNetwork(nearby.image)
                          ? Image.network(
                              nearby.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, e, st) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            )
                          : Image.asset(
                              nearby.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, e, st) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nearby.name,
                          style: customButtonandTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${nearby.locationShort} · ${nearby.favMeetupType}',
                          style: customButtonandTextStyles.locationTextStyle,
                        ),
                        SizedBox(height: 10.h),
                        SizedBox(
                          height: 34.h,
                          child: CustomElevatedButton(
                            onPressed: onRequest,
                            text: 'Request Meetup',
                            activeTextColor: appTheme.b_600,
                            buttonStyle:
                                customButtonandTextStyles.requestButtonStyle,
                          ),
                        ),
                      ],
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
