import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/loginScreen/login_screen_controller.dart';
import 'package:meetmern/core/routes/route_names.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<LoginController>(
      builder: (c) => Scaffold(
        body: Stack(
          children: [
            AuthBackgroundImage(
                imagePath: strings.img1,
                fit: BoxFit.contain,
                verticalShift: -dimension.d220.h),
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
                            style: styles.titleTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.loginScreenSubtitle,
                            style: styles.subtitleTextStyle),
                        SizedBox(height: dimension.d16.h),
                        Text(strings.emailPrompt,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.emailController,
                          textStyle: styles.userNameTextStyle,
                          validator: c.validateEmail,
                          inputDecoration: styles.emailInputDecoration,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Text(strings.passwordPrompt,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.passwordController,
                          obscureText: c.isObscure,
                          textStyle: styles.userNameTextStyle,
                          validator: c.validatePassword,
                          inputDecoration: styles.passwordInputDecoration(
                            isObscure: c.isObscure,
                            onToggle: c.togglePasswordVisibility,
                          ),
                        ),
                        SizedBox(height: dimension.d12.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.forgotPassword),
                            child: Text(strings.forgetPasswordText,
                                style: styles.forgetPasswordTextstyle),
                          ),
                        ),
                        SizedBox(height: dimension.d20.h),
                        CustomElevatedButton(
                          onPressed:
                              c.isLoading ? null : () => c.signIn(_formKey),
                          buttonStyle: styles.loginButtonStyle,
                          text: c.isLoading ? '' : strings.loginButtonText,
                          buttonTextStyle: styles.loginButtonTextStyle,
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
                        SizedBox(height: dimension.d30.h),
                        Center(
                          child: GestureDetector(
                            onTap: () => Get.toNamed(Routes.signup),
                            child: RichText(
                              text: TextSpan(
                                style: styles.textSpanTextStyle,
                                children: [
                                  TextSpan(
                                      text: strings.dontHaveAnAccount,
                                      style: styles.donotHaveAccontTextStyle),
                                  TextSpan(
                                      text: strings.signUpText,
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
