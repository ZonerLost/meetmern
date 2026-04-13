import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/ForgetPasswordScreens/setnew_password_screen_controller.dart';
import 'package:meetmern/view/screens/authscreens/loginScreen/login_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/auth_background_image.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<ResetPasswordController>(
      builder: (c) => Scaffold(
        body: Stack(
          children: [
            AuthBackgroundImage(
                imagePath: strings.img2, verticalShift: -dimension.d120.h),
            Positioned(
              top: dimension.d320.h,
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
                  key: c.formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.setNewKeyTitle,
                            style: styles.titleTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.setNewKeySubtitle,
                            style: styles.subtitleTextStyle),
                        SizedBox(height: dimension.d20.h),
                        Text(strings.newPasswordLabel,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.newPasswordController,
                          obscureText: c.isObscure1,
                          textStyle: styles.userNameTextStyle,
                          validator: c.validatePassword,
                          inputDecoration: styles.passwordInputDecoration(
                            isObscure: c.isObscure1,
                            onToggle: c.toggleNewPasswordVisibility,
                          ),
                        ),
                        SizedBox(height: dimension.d16.h),
                        Text(strings.confirmPasswordLabel,
                            style: styles.emailLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        CustomTextFormField(
                          controller: c.confirmPasswordController,
                          obscureText: c.isObscure2,
                          textStyle: styles.userNameTextStyle,
                          validator: c.validateConfirmPassword,
                          inputDecoration: styles.passwordInputDecoration(
                            isObscure: c.isObscure2,
                            onToggle: c.toggleConfirmPasswordVisibility,
                          ),
                        ),
                        SizedBox(height: dimension.d28.h),
                        CustomElevatedButton(
                          text: strings.resetButtonText,
                          buttonTextStyle: styles.loginButtonTextStyle,
                          buttonStyle: styles.loginButtonStyle,
                          onPressed: () {
                            if (c.validateForm())
                              context.navigateToScreen(const LoginScreen());
                          },
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
