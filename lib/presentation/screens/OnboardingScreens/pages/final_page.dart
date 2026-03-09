import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/model/onboarding_model.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_outlined_button.dart';

const strings = Strings();

class FinalPage extends StatelessWidget {
  final OnboardingModel model;
  final VoidCallback? onFinish;

  const FinalPage({super.key, required this.model, this.onFinish});

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(dimension.d20.w, dimension.d20.h,
              dimension.d20.w, dimension.d28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: dimension.d8.h),
              Center(
                child: Image.asset(strings.img7,
                    width: dimension.d366.w, height: dimension.d367.h),
              ),
              SizedBox(height: dimension.d20.h),
              Text(strings.readyTitle,
                  style: customButtonandTextStyles.titleTextStyle),
              SizedBox(height: dimension.d8.h),
              Text(strings.readySubtitle,
                  style: customButtonandTextStyles.subtitleTextStyle),
              SizedBox(height: dimension.d150.h),
              SizedBox(
                width: dimension.d366.w,
                height: dimension.d54.h,
                child: CustomOutlinedButton(
                  onPressed: () {
                    if (onFinish != null) onFinish!();
                  },
                  text: strings.createMeetupText,
                  buttonStyle: customButtonandTextStyles.googleButtonStyle,
                  buttonTextStyle:
                      customButtonandTextStyles.googleButtonTextStyle,
                ),
              ),
              SizedBox(height: dimension.d20.h),
              SizedBox(
                width: dimension.d366.w,
                height: dimension.d54.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (onFinish != null) onFinish!();
                  },
                  style: customButtonandTextStyles.loginButtonStyle,
                  child: Text(strings.exploreMeetupsText,
                      style: customButtonandTextStyles.loginButtonTextStyle),
                ),
              ),
              SizedBox(height: dimension.d20.h),
            ],
          ),
        ),
      ),
    );
  }
}
