import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/AuthScreens/loginScreen/login_screen.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/validation_extention.dart';
import 'package:meetmern/core/constants/app_strings.dart';
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final strings = const Strings();
  bool isObscure = true;
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dimension = DimensionResource();
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
            imagePath: strings.img2,
            verticalShift: -dimension.d220.h,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: dimension.d216.h,
            left: dimension.d0,
            right: dimension.d0,
            bottom: dimension.d0,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                dimension.d32.w,
                dimension.d28.h,
                dimension.d32.w,
                dimension.d36.h,
              ),
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
                          style: customButtonandTextStyles.titleTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.signUpScreenSubtitle,
                          style: customButtonandTextStyles.subtitleTextStyle),
                      SizedBox(height: dimension.d16.h),
                      Text(strings.nameLabel,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                          controller: _nameController,
                          textStyle:
                              customButtonandTextStyles.userNameTextStyle,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return strings.pleaseEnterYourNameText;
                            }
                            return null;
                          },
                          inputDecoration: customButtonandTextStyles
                              .userNameInputDecoration),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.emailPrompt,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
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
                              customButtonandTextStyles.emailInputDecoration),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.phoneNumberLabel,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                        controller: _phoneController,
                        textStyle: customButtonandTextStyles.userNameTextStyle,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return strings.pleaseEnterYourPhoneText;
                          }
                          return null;
                        },
                        inputDecoration: customButtonandTextStyles
                            .emailInputDecoration
                            .copyWith(
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(
                                left: dimension.d12.w, right: dimension.d8.w),
                            child: Icon(
                              Icons.call_outlined,
                              size: dimension.d20.w,
                            ),
                          ),
                          prefixIconConstraints: BoxConstraints(
                            minWidth: dimension.d32.w,
                            minHeight: dimension.d32.h,
                          ),
                        ),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.passwordPrompt,
                          style: customButtonandTextStyles.emailLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      CustomTextFormField(
                          controller: _passwordController,
                          obscureText: isObscure,
                          textStyle:
                              customButtonandTextStyles.userNameTextStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return strings.pleaseEnterPasswordText;
                            } else if (value.length < 6) {
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
                          )),
                      SizedBox(height: dimension.d20.h),
                      Center(
                        child: CustomElevatedButton(
                          onPressed: () {
                            // if (_formKey.currentState!.validate()) {
                            context.navigateToScreen(const LoginScreen());
                            // }
                          },
                          buttonStyle:
                              customButtonandTextStyles.loginButtonStyle,
                          text: strings.createAccountText,
                          buttonTextStyle:
                              customButtonandTextStyles.loginButtonTextStyle,
                        ),
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
                                  text: strings.alreadyHaveAccountText,
                                  style: customButtonandTextStyles
                                      .donotHaveAccontTextStyle,
                                ),
                                TextSpan(
                                  text: strings.loginButtonText,
                                  style: customButtonandTextStyles
                                      .signUpTextSpanTextStyle,
                                ),
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
    );
  }
}
