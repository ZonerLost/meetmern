import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/presentation/screens/AuthScreens/loginScreen/login_screen.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool isObscure1 = true;
  bool isObscure2 = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;

    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              strings.img2,
              fit: BoxFit.cover,
            ),
          ),
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
                key: _formKey,
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
                        controller: _newPasswordController,
                        obscureText: isObscure1,
                        textStyle: styles.userNameTextStyle,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return strings.pleaseEnterPasswordText;
                          }
                          return null;
                        },
                        inputDecoration: styles.passwordInputDecoration(
                          isObscure: isObscure1,
                          onToggle: () {
                            setState(() {
                              isObscure1 = !isObscure1;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: dimension.d16.h),
                      Text(strings.confirmPasswordLabel,
                          style: styles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                        controller: _confirmPasswordController,
                        obscureText: isObscure2,
                        textStyle: styles.userNameTextStyle,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return strings.pleaseEnterPasswordText;
                          }
                          if (value != _newPasswordController.text) {
                            return strings.passwordNotMatch;
                          }
                          return null;
                        },
                        inputDecoration: styles.passwordInputDecoration(
                          isObscure: isObscure2,
                          onToggle: () {
                            setState(() {
                              isObscure2 = !isObscure2;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: dimension.d28.h),
                      CustomElevatedButton(
                        text: strings.resetButtonText,
                        buttonTextStyle: styles.loginButtonTextStyle,
                        buttonStyle: styles.loginButtonStyle,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.navigateToScreen(const LoginScreen());
                          }
                        },
                      ),
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
