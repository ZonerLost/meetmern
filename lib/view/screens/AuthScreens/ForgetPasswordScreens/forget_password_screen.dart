import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/ForgetPasswordScreens/forget_password_screen_controller.dart';
import 'package:meetmern/view/routes/route_names.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<ForgotPasswordController>(
      builder: (c) => Scaffold(
        body: Stack(
          children: [
            AuthBackgroundImage(
                imagePath: strings.img4, verticalShift: -dimension.d80.h),
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
                            style: styles.titleTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.letsGetYouBackSubtitle,
                            style: styles.subtitleTextStyle),
                        SizedBox(height: dimension.d20.h),
                        Text(strings.emailPrompt,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.emailController,
                          textStyle: styles.userNameTextStyle,
                          validator: c.validateEmail,
                          inputDecoration: styles.emailInputDecoration,
                        ),
                        SizedBox(height: dimension.d24.h),
                        CustomElevatedButton(
                          text: c.isLoading
                              ? ''
                              : strings.sendResetLinkButtonText,
                          buttonTextStyle: styles.loginButtonTextStyle,
                          buttonStyle: styles.loginButtonStyle,
                          onPressed: c.isLoading
                              ? null
                              : () => c.sendResetLink(_formKey),
                          child: c.isLoading
                              ? SizedBox(
                                  height: dimension.d20.h,
                                  width: dimension.d20.h,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: appTheme.coreWhite),
                                )
                              : null,
                        ),
                        SizedBox(height: dimension.d20.h),
                        Row(
                          children: [
                            Expanded(
                                child: Divider(color: appTheme.neutral_600)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Text(strings.orText,
                                  style: styles.or1TextStyle),
                            ),
                            Expanded(
                                child: Divider(color: appTheme.neutral_600)),
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
                        SizedBox(height: dimension.d16.h),
                        Center(
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.login),
                            child: RichText(
                              text: TextSpan(
                                style: styles.textSpanTextStyle,
                                children: [
                                  TextSpan(
                                      text: strings.rememberYourAccountText,
                                      style: styles.donotHaveAccontTextStyle),
                                  TextSpan(
                                      text: strings.loginLinkText,
                                      style: styles.signUpTextSpanTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
