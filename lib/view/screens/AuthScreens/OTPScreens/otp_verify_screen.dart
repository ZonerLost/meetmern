import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/ForgetPasswordScreens/forget_password_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/otp_verify_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/verify_otp_controller_widget_controller.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/auth_background_image.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class VerifyOtpScreen extends StatelessWidget {
  const VerifyOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customThemeData = ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(apppTheme: Theme.of(context), theme: customThemeData);
    final email = Get.find<ForgotPasswordController>().emailController.text.trim();

    return GetBuilder<OtpVerifyController>(
      initState: (_) {
        final otpWidget = Get.find<OtpWidgetController>();
        if (otpWidget.focusNodes.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            otpWidget.focusNodes[0].requestFocus();
          });
        }
      },
      builder: (c) => GetBuilder<OtpWidgetController>(
        builder: (otpWidget) => Scaffold(
          body: Stack(
            children: [
              AuthBackgroundImage(
                  imagePath: strings.img4,
                  fit: BoxFit.contain,
                  verticalShift: -dimension.d160.h),
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
                        Text(strings.verifyTitle, style: styles.titleTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.verifySubtitle, style: styles.subtitleTextStyle),
                        SizedBox(height: dimension.d24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(otpWidget.length, (index) {
                            return CustomTextFormField(
                              width: dimension.d60.w,
                              height: dimension.d68.h,
                              controller: otpWidget.otpControllers[index],
                              focusNode: otpWidget.focusNodes[index],
                              textInputType: TextInputType.number,
                              textInputAction: index == otpWidget.length - 1
                                  ? TextInputAction.done
                                  : TextInputAction.next,
                              maxLength: 1,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              inputDecoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: appTheme.coreWhite,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(dimension.d12.r),
                                  borderSide: BorderSide(
                                    color: otpWidget.hasError
                                        ? appTheme.red
                                        : appTheme.borderColor,
                                    width: dimension.d1.w,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(dimension.d8.r),
                                  borderSide: BorderSide(
                                    color: otpWidget.hasError
                                        ? appTheme.red
                                        : appTheme.borderColor,
                                    width: dimension.d1.w,
                                  ),
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              onChanged: (value) =>
                                  otpWidget.onOtpChanged(value, index, context),
                            );
                          }),
                        ),
                        SizedBox(height: dimension.d24.h),
                        CustomElevatedButton(
                          height: dimension.d54.h,
                          width: dimension.d366.w,
                          onPressed: c.isVerifying ? null : () => c.verifyOtp(email),
                          buttonStyle: styles.loginButtonStyle,
                          text: c.isVerifying ? '' : strings.verifyButtonText,
                          buttonTextStyle: styles.loginButtonTextStyle,
                          child: c.isVerifying
                              ? SizedBox(
                                  height: dimension.d20.h,
                                  width: dimension.d20.h,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: appTheme.coreWhite),
                                )
                              : null,
                        ),
                        SizedBox(height: dimension.d24.h),
                        Center(
                          child: GestureDetector(
                            onTap: c.canResend ? () => c.resendCode(email) : null,
                            child: RichText(
                              text: TextSpan(
                                style: styles.textSpanTextStyle,
                                children: [
                                  TextSpan(
                                    text: c.canResend ? '' : '${c.resendSeconds}s  ',
                                    style: styles.donotHaveAccontTextStyle,
                                  ),
                                  TextSpan(
                                      text: strings.resendCode,
                                      style: styles.resendSpanTextStyle),
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
        ),
      ),
    );
  }
}
