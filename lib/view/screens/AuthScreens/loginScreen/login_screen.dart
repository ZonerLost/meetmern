import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/AuthScreens/OTPScreens/otp_verify_screen.dart';
import 'package:meetmern/view/screens/AuthScreens/SignupScreen/signup_screen.dart';
import 'package:meetmern/view/screens/OnboardingScreens/OnboardingScreen/onboarding_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/auth_background_image.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isObscure = true;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );
    return Scaffold(
      body: Stack(
        children: [
          AuthBackgroundImage(
            imagePath: strings.img1,
            fit: BoxFit.contain,
            verticalShift: -dimension.d220.h,
          ),
          Positioned(
            top: dimension.d206.h,
            left: dimension.d0,
            right: dimension.d0,
            bottom: dimension.d0,
            child: Container(
              padding: EdgeInsets.fromLTRB(dimension.d32.w, dimension.d28.h,
                  dimension.d32.w, dimension.d36.h),
              decoration: BoxDecoration(
                color: appTheme.coreWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(dimension.d48.r),
                  topRight: Radius.circular(dimension.d48.r),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: dimension.d8.h),
                      Text(strings.loginScreenTitle,
                          style: customButtonandTextStyles.titleTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.loginScreenSubtitle,
                          style: customButtonandTextStyles.subtitleTextStyle),
                      SizedBox(height: dimension.d16.h),
                      Text(strings.emailPrompt,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      SizedBox(
                        child: CustomTextFormField(
                          controller: _emailController,
                          textStyle:
                              customButtonandTextStyles.userNameTextStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return strings.pleaseEnterYourEmailText;
                            } else if (!value.isValidEmail) {
                              return strings.enterValidEmailText;
                            }
                            return null;
                          },
                          inputDecoration:
                              customButtonandTextStyles.emailInputDecoration,
                        ),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.passwordPrompt,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                        controller: _passwordController,
                        obscureText: isObscure,
                        textStyle: customButtonandTextStyles.userNameTextStyle,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return strings.pleaseEnterPasswordText;
                          } else if (value.length < dimension.d6) {
                            return strings.passwordMinLengthText;
                          }
                          return null;
                        },
                        inputDecoration:
                            customButtonandTextStyles.passwordInputDecoration(
                          isObscure: isObscure,
                          onToggle: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            context.navigateToScreen(const VerifyOtpScreen());
                          },
                          child: Text(strings.forgetPasswordText,
                              style: customButtonandTextStyles
                                  .forgetPasswordTextstyle),
                        ),
                      ),
                      SizedBox(height: dimension.d20.h),
                      CustomElevatedButton(
                        onPressed: () {
                          // if (_formKey.currentState!.validate()) {
                          context.navigateToScreen(const OnboardingScreen());
                          // }
                        },
                        buttonStyle: customButtonandTextStyles.loginButtonStyle,
                        text: strings.loginButtonText,
                        buttonTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                      ),
                      SizedBox(
                        height: dimension.d16.h,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: appTheme.neutral_600,
                              thickness: dimension.d1,
                              endIndent: dimension.d10.w,
                            ),
                          ),
                          Text(strings.orText,
                              style: customButtonandTextStyles.or1TextStyle),
                          Expanded(
                            child: Divider(
                              color: appTheme.neutral_600,
                              thickness: dimension.d1,
                              indent: dimension.d10.w,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dimension.d16.h),
                      CustomOutlinedButton(
                        onPressed: () {},
                        buttonStyle:
                            customButtonandTextStyles.googleButtonStyle,
                        leftIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              strings.googleIconPath,
                              width: dimension.d20.w,
                              height: dimension.d20.h,
                            ),
                            SizedBox(width: dimension.d10.w),
                          ],
                        ),
                        text: strings.googleText,
                        buttonTextStyle:
                            customButtonandTextStyles.googleButtonTextStyle,
                      ),
                      SizedBox(height: dimension.d10.h),
                      CustomOutlinedButton(
                        onPressed: () {},
                        buttonStyle:
                            customButtonandTextStyles.googleButtonStyle,
                        leftIcon: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              strings.appleIconPath,
                              width: dimension.d20.w,
                              height: dimension.d20.h,
                            ),
                            SizedBox(width: dimension.d10.w),
                          ],
                        ),
                        text: strings.appleText,
                        buttonTextStyle:
                            customButtonandTextStyles.googleButtonTextStyle,
                      ),
                      SizedBox(height: dimension.d30.h),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.navigateToScreen(const SignupScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              style:
                                  customButtonandTextStyles.textSpanTextStyle,
                              children: [
                                TextSpan(
                                  text: strings.dontHaveAnAccount,
                                  style: customButtonandTextStyles
                                      .donotHaveAccontTextStyle,
                                ),
                                TextSpan(
                                  text: strings.signUpText,
                                  style: customButtonandTextStyles
                                      .signUpTextSpanTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
