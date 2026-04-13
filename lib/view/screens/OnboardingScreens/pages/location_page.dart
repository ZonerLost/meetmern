import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

const strings = Strings();

class LocationPage extends StatefulWidget {
  final VoidCallback onNext;
  final bool stepValid;
  final VoidCallback onDisabledTap;

  const LocationPage({
    super.key,
    required this.onNext,
    required this.stepValid,
    required this.onDisabledTap,
  });

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  bool _loading = false;
  Future<void> _enableLocationAndOpenMap() async {
    setState(() => _loading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      widget.onNext();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimension.d20.w),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: dimension.d16.h),
          Text(strings.locationRequiredTitle,
              style: customButtonandTextStyles.titleTextStyle),
          SizedBox(height: dimension.d12.h),
          Text(strings.locationRequiredSubtitle,
              style: customButtonandTextStyles.subtitleTextStyle),
          SizedBox(height: dimension.d40.h),
          Center(
            child: Image.asset(
              strings.img8,
              width: dimension.d366.w,
              height: dimension.d367.h,
            ),
          ),
          SizedBox(height: dimension.d58.h),
          CustomOutlinedButton(
            onPressed: () {
              SystemNavigator.pop();
            },
            text: strings.exitApptext,
            buttonTextStyle: customButtonandTextStyles.googleButtonTextStyle,
            buttonStyle: customButtonandTextStyles.googleButtonStyle,
          ),
          SizedBox(height: dimension.d20.h),
          SizedBox(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.stepValid
                  ? _enableLocationAndOpenMap
                  : widget.onDisabledTap,
              child: CustomElevatedButton(
                onPressed: widget.stepValid && !_loading
                    ? _enableLocationAndOpenMap
                    : null,
                buttonStyle: customButtonandTextStyles.loginButtonStyle,
                text: _loading ? "Loading..." : strings.enableLocationButton,
                buttonTextStyle: customButtonandTextStyles.loginButtonTextStyle,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
