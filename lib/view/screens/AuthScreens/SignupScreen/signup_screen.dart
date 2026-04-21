import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/SignupScreen/signup_screen_controller.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/auth_background_image.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<SignupController>(
      builder: (c) => Scaffold(
        body: Stack(
          children: [
            AuthBackgroundImage(
                imagePath: strings.img2,
                verticalShift: -dimension.d220.h,
                fit: BoxFit.contain),
            Positioned(
              top: dimension.d216.h,
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
                        Text(strings.signUpScreenTitle,
                            style: styles.titleTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.signUpScreenSubtitle,
                            style: styles.subtitleTextStyle),
                        SizedBox(height: dimension.d16.h),
                        Text(strings.nameLabel,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.nameController,
                          textStyle: styles.userNameTextStyle,
                          validator: c.validateName,
                          inputDecoration: styles.userNameInputDecoration,
                        ),
                        SizedBox(height: dimension.d12.h),
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
                        Text(strings.phoneNumberLabel,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.phoneController,
                          textStyle: styles.userNameTextStyle,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          textInputType: TextInputType.number,
                          validator: c.validatePhone,
                          inputDecoration: styles.emailInputDecoration.copyWith(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(
                                  left: dimension.d12.w, right: dimension.d8.w),
                              child: Icon(Icons.call_outlined,
                                  size: dimension.d20.w),
                            ),
                            prefixIconConstraints: BoxConstraints(
                                minWidth: dimension.d32.w,
                                minHeight: dimension.d32.h),
                          ),
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
                        SizedBox(height: dimension.d20.h),
                        Center(
                          child: CustomElevatedButton(
                            onPressed:
                                c.isLoading ? null : () => c.signUp(_formKey),
                            buttonStyle: styles.loginButtonStyle,
                            text: c.isLoading ? '' : strings.createAccountText,
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
                                      text: strings.alreadyHaveAccountText,
                                      style: styles.donotHaveAccontTextStyle),
                                  TextSpan(
                                      text: strings.loginButtonText,
                                      style: styles.signUpTextSpanTextStyle),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: dimension.d24.h),
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
