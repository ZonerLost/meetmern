import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/AuthScreens/ForgetPasswordScreens/setnew_password_screen.dart';
import 'package:meetmern/view/screens/AuthScreens/loginScreen/login_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/auth_background_image.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
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
            imagePath: strings.img4,
            verticalShift: -dimension.d80.h,
          ),
          Positioned(
            top: dimension.d435.h,
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
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.letsGetYouBackTitle,
                          style: customButtonandTextStyles.titleTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.letsGetYouBackSubtitle,
                          style: customButtonandTextStyles.subtitleTextStyle),
                      SizedBox(height: dimension.d20.h),
                      Text(strings.emailPrompt,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                        controller: _emailController,
                        textStyle: customButtonandTextStyles.userNameTextStyle,
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
                      SizedBox(height: dimension.d24.h),
                      CustomElevatedButton(
                        text: strings.sendResetLinkButtonText,
                        buttonTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                        buttonStyle: customButtonandTextStyles.loginButtonStyle,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context
                                .navigateToScreen(const ResetPasswordScreen());
                          }
                        },
                      ),
                      SizedBox(height: dimension.d20.h),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: appTheme.neutral_600,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(strings.orText,
                                style: customButtonandTextStyles.or1TextStyle),
                          ),
                          Expanded(
                            child: Divider(
                              color: appTheme.neutral_600,
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
                      SizedBox(height: dimension.d16.h),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.navigateToScreen(const LoginScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              style:
                                  customButtonandTextStyles.textSpanTextStyle,
                              children: [
                                TextSpan(
                                  text: strings.rememberYourAccountText,
                                  style: customButtonandTextStyles
                                      .donotHaveAccontTextStyle,
                                ),
                                TextSpan(
                                  text: strings.loginLinkText,
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
          )
        ],
      ),
    );
  }
}
