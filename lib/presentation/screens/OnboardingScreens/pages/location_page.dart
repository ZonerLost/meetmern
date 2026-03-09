import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_outlined_button.dart';

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
            width: dimension.d366.w,
            height: dimension.d54.h,
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            text: 'Exit App',
            buttonTextStyle: customButtonandTextStyles.googleButtonTextStyle,
            buttonStyle: customButtonandTextStyles.googleButtonStyle,
          ),
          SizedBox(height: dimension.d20.h),
          SizedBox(
            width: dimension.d366.w,
            height: dimension.d54.h,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: widget.stepValid
                  ? _enableLocationAndOpenMap
                  : widget.onDisabledTap,
              child: ElevatedButton(
                onPressed: widget.stepValid ? _enableLocationAndOpenMap : null,
                style: customButtonandTextStyles.loginButtonStyle,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(strings.enableLocationButton,
                        style: customButtonandTextStyles.loginButtonTextStyle),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
