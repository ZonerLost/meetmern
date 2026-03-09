import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/presentation/screens/AuthScreens/ForgetPasswordScreens/forget_password_screen.dart';
import 'package:meetmern/presentation/screens/AuthScreens/OTPScreens/verify_otp_controller_widget.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final controller = VerifyOtpController();

  @override
  void initState() {
    super.initState();
    controller.init();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.focusNodes.isNotEmpty) {
        controller.focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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
          Positioned.fill(
            child: Image.asset(
              strings.img4,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: dimension.d433.h,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: dimension.d8.h),
                    Text(
                      strings.verifyTitle,
                      style: customButtonandTextStyles.titleTextStyle,
                    ),
                    SizedBox(height: dimension.d8.h),
                    Text(
                      strings.verifySubtitle,
                      style: customButtonandTextStyles.subtitleTextStyle,
                    ),
                    SizedBox(height: dimension.d24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        controller.length,
                        (index) {
                          final boxDecoration = InputDecoration(
                            counterText: "",
                            filled: true,
                            fillColor: appTheme.coreWhite,
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(dimension.d12.r),
                              borderSide: BorderSide(
                                color: controller.hasError
                                    ? appTheme.red
                                    : appTheme.borderColor,
                                width: dimension.d1.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(dimension.d8.r),
                              borderSide: BorderSide(
                                color: controller.hasError
                                    ? appTheme.red
                                    : appTheme.borderColor,
                                width: dimension.d1.w,
                              ),
                            ),
                          );

                          return CustomTextFormField(
                            width: dimension.d60.w,
                            height: dimension.d68.h,
                            controller: controller.otpControllers[index],
                            focusNode: controller.focusNodes[index],
                            textInputType: TextInputType.number,
                            textInputAction: index == controller.length - 1
                                ? TextInputAction.done
                                : TextInputAction.next,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            inputDecoration: boxDecoration,
                            contentPadding: EdgeInsets.zero,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            onChanged: (value) =>
                                controller.onOtpChanged(value, index, context),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: dimension.d24.h),
                    CustomElevatedButton(
                      height: dimension.d54.h,
                      width: dimension.d366.w,
                      onPressed: () {
                        context.navigateToScreen(const ForgotPasswordScreen());
                      },
                      buttonStyle: customButtonandTextStyles.loginButtonStyle,
                      text: strings.verifyButtonText,
                      buttonTextStyle:
                          customButtonandTextStyles.loginButtonTextStyle,
                    ),
                    SizedBox(height: dimension.d24.h),
                    Center(
                      child: GestureDetector(
                        onTap: () {},
                        child: RichText(
                          text: TextSpan(
                            style: customButtonandTextStyles.textSpanTextStyle,
                            children: [
                              TextSpan(
                                text: strings.secText,
                                style: customButtonandTextStyles
                                    .donotHaveAccontTextStyle,
                              ),
                              TextSpan(
                                text: strings.resendCode,
                                style: customButtonandTextStyles
                                    .resendSpanTextStyle,
                              ),
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
        ],
      ),
    );
  }
}
