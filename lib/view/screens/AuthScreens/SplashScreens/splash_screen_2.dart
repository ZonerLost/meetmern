import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/SplashScreens/splash_screen_2_controller.dart';
import 'package:meetmern/view/screens/authscreens/SignupScreen/signup_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class SplashScreen2 extends StatelessWidget {
  const SplashScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<Splash2Controller>(
      builder: (_) => Scaffold(
        backgroundColor: appTheme.b_Primary,
        body: Stack(
          children: [
            Positioned(
              top: dimension.d56.h,
              left: dimension.d118.w,
              child: Image.asset(
                  width: dimension.d192.w,
                  height: dimension.d93.h,
                  strings.img5),
            ),
            Positioned(
              top: dimension.d164.h,
              left: dimension.d0,
              right: dimension.d0,
              bottom: dimension.d0,
              child: Container(
                padding: EdgeInsets.fromLTRB(dimension.d32.w, dimension.d32.h,
                    dimension.d32.w, dimension.d32.h),
                decoration: BoxDecoration(
                  color: appTheme.coreWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(dimension.d40.r),
                    topRight: Radius.circular(dimension.d40.r),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: dimension.d8.h),
                      Text(strings.splashScreenTitle,
                          style: TextStyle(
                              color: appTheme.neutral_800,
                              fontSize: dimension.d20.sp,
                              fontWeight: FontWeight.w600)),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.splashScreenSubtitle,
                          style: TextStyle(
                              fontSize: dimension.d16.sp,
                              fontWeight: FontWeight.w500,
                              color: appTheme.neutral_800)),
                      SizedBox(height: dimension.d16.h),
                      Image.asset(
                          width: dimension.d366.w,
                          height: dimension.d325.h,
                          strings.img6),
                      SizedBox(height: dimension.d16.h),
                      SizedBox(
                        width: dimension.d366.w,
                        height: dimension.d54.h,
                        child: CustomElevatedButton(
                          height: dimension.d54,
                          width: dimension.d366,
                          onPressed: () =>
                              context.navigateToScreen(const SignupScreen()),
                          buttonStyle: styles.loginButtonStyle,
                          text: strings.continueEmailButtonText,
                          buttonTextStyle: styles.loginButtonTextStyle,
                        ),
                      ),
                      SizedBox(height: dimension.d16.h),
                      Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: appTheme.neutral_600,
                                  thickness: dimension.d1,
                                  endIndent: dimension.d10.w)),
                          Text(strings.orText, style: styles.or1TextStyle),
                          Expanded(
                              child: Divider(
                                  color: appTheme.neutral_600,
                                  thickness: dimension.d1,
                                  indent: dimension.d10.w)),
                        ],
                      ),
                      SizedBox(height: dimension.d16.h),
                      CustomOutlinedButton(
                        onPressed: () {},
                        buttonStyle: styles.googleButtonStyle,
                        leftIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(strings.googleIconPath,
                                  width: dimension.d20.w,
                                  height: dimension.d20.h),
                              SizedBox(width: dimension.d10.w),
                            ]),
                        text: strings.googleText,
                        buttonTextStyle: styles.googleButtonTextStyle,
                      ),
                      SizedBox(height: dimension.d10.h),
                      CustomOutlinedButton(
                        onPressed: () {},
                        buttonStyle: styles.googleButtonStyle,
                        leftIcon: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(strings.appleIconPath,
                                  width: dimension.d20.w,
                                  height: dimension.d20.h),
                              SizedBox(width: dimension.d10.w),
                            ]),
                        text: strings.appleText,
                        buttonTextStyle: styles.googleButtonTextStyle,
                      ),
                      SizedBox(height: dimension.d20.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
