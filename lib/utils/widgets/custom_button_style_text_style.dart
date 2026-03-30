import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';

class CustomButtonStyles {
  final ThemeData apppTheme;
  final ThemeData theme;
  final TextEditingController? controller;
  final strings = const Strings();
  DimensionResource dimension = DimensionResource();
  CustomButtonStyles({
    required this.apppTheme,
    required this.theme,
    this.controller,
  });
  final appTheme = ThemeHelper(appThemeName: "lightCode").themeColor;

  ButtonStyle get loginButtonStyle => ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: dimension.d8),
      backgroundColor: appTheme.b_Primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimension.d100),
      ));

  ButtonStyle get deleteButtonStyle => ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: dimension.d8),
      backgroundColor: appTheme.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimension.d100),
      ));
  ButtonStyle get cancelMeetupButtonStyle => ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: dimension.d8),
      backgroundColor: appTheme.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimension.d100),
      ));
  ButtonStyle get googleButtonStyle => OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: dimension.d8),
        backgroundColor: appTheme.infieldColor,
        side: BorderSide(color: appTheme.borderColor, width: dimension.d1),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimension.d100)),
      );

  ButtonStyle get requestButtonStyle => OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: dimension.d8),
        backgroundColor: appTheme.b_100,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dimension.d100)),
      );

  ButtonStyle cnextButtonStyle(bool isStepValid) {
    return ElevatedButton.styleFrom(
      backgroundColor: isStepValid ? appTheme.b_Primary : appTheme.b_200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimension.d28),
      ),
      padding: EdgeInsets.symmetric(
        vertical: dimension.d12.h,
      ),
    );
  }

  // Text Styles
  TextStyle get loginButtonTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d16.sp,
      fontWeight: FontWeight.w600,
      color: appTheme.coreWhite);
  TextStyle get acceptCahtButtonTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: dimension.d16,
      color: appTheme.infieldColor);
  TextStyle get closeButtonTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: dimension.d16,
      color: appTheme.neutral_600);
  TextStyle get googleButtonTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontWeight: FontWeight.w600,
      fontSize: dimension.d16,
      color: appTheme.neutral_700);
  TextStyle get cancelButtonTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d16.sp,
      fontWeight: FontWeight.w600,
      color: appTheme.neutral_700);
  TextStyle get userNameTextStyle => TextStyle(
      color: appTheme.neutral_700,
      fontSize: dimension.d14.sp,
      fontFamily: strings.fontFamily,
      fontWeight: FontWeight.w500);
  TextStyle get dateFieldTextStyle => TextStyle(
      fontSize: dimension.d14.sp,
      color: appTheme.neutral_400,
      fontFamily: strings.fontFamily,
      fontWeight: FontWeight.w500);
  TextStyle get emailLabelTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d18.sp,
      color: appTheme.neutral_800,
      fontWeight: FontWeight.w600);
  TextStyle get dobLabelTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d16.sp,
      color: appTheme.neutral_800,
      fontWeight: FontWeight.w600);
  TextStyle get locationTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d14.sp,
      color: appTheme.neutral_600,
      fontWeight: FontWeight.w500);
  TextStyle get titleTextStyle => TextStyle(
        color: appTheme.neutral_800,
        fontSize: dimension.d20.sp,
        fontWeight: FontWeight.w600,
      );
  TextStyle get subtitleTextStyle => TextStyle(
        fontSize: dimension.d16.sp,
        fontWeight: FontWeight.w500,
        color: appTheme.neutral_600,
      );

  TextStyle get textSpanTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d18.sp,
      fontWeight: FontWeight.w600);
  TextStyle get signUpTextSpanTextStyle => TextStyle(
        color: appTheme.forgotPasswordColor,
      );
  TextStyle get resendSpanTextStyle => TextStyle(
        color: appTheme.c_Red,
      );
  TextStyle get forgetPasswordTextstyle => TextStyle(
        color: appTheme.forgotPasswordColor,
        fontSize: dimension.d16.sp,
        fontWeight: FontWeight.w500,
      );
  TextStyle get donotHaveAccontTextStyle => TextStyle(
        color: appTheme.neutral_600,
      );
  TextStyle get or1TextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d14.sp,
      fontWeight: FontWeight.w500,
      color: appTheme.neutral_600);
  TextStyle get sliderTextStyle => TextStyle(
      fontFamily: strings.fontFamily,
      fontSize: dimension.d12.sp,
      fontWeight: FontWeight.w500,
      color: appTheme.neutral_400);

  InputDecoration get userNameInputDecoration => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintText: strings.defaultName,
        hintStyle: userNameTextStyle,
        prefixIcon: Icon(Icons.person_outline, color: appTheme.neutral_600),
        contentPadding: EdgeInsets.symmetric(
            vertical: dimension.d14, horizontal: dimension.d16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );
  InputDecoration get emailInputDecoration => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintText: strings.defaultEmail,
        hintStyle: userNameTextStyle,
        prefixIcon: Icon(Icons.email_outlined, color: appTheme.neutral_600),
        contentPadding: EdgeInsets.symmetric(
            vertical: dimension.d14, horizontal: dimension.d16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );
  InputDecoration get genderFInputDecoration => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintStyle: dateFieldTextStyle,
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimension.d16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );
  InputDecoration get messagefInputDecoration => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintStyle: dateFieldTextStyle,
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d12),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d12),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );
  InputDecoration get feedbackfInputDecoration => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintStyle: dateFieldTextStyle,
        contentPadding: EdgeInsets.symmetric(horizontal: dimension.d16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );

  InputDecoration dateFieldInputDecoration({Widget? suffix}) => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintText: strings.dateFormatHint,
        hintStyle: userNameTextStyle,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
            vertical: dimension.d14, horizontal: dimension.d16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );
  InputDecoration bioFieldInputDecoration({Widget? suffix}) => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintText: strings.dateFormatHint,
        hintStyle: userNameTextStyle,
        suffixIcon: suffix,
        contentPadding: EdgeInsets.symmetric(
            vertical: dimension.d14, horizontal: dimension.d16),
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );
  InputDecoration passwordInputDecoration({
    required bool isObscure,
    required VoidCallback onToggle,
  }) =>
      InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        hintText: strings.maskedPassword,
        hintStyle: userNameTextStyle,
        suffixIcon: IconButton(
          icon: Icon(
            isObscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: appTheme.black90001,
          ),
          onPressed: onToggle,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: dimension.d14,
          horizontal: dimension.d16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide:
              BorderSide(color: appTheme.borderColor, width: dimension.d1),
        ),
      );

  InputDecoration get timeFInputDecoration => InputDecoration(
        labelText: strings.timeLabelShort,
        hintText: strings.timeHintExample,
        prefixIcon: const Icon(Icons.access_time),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(dimension.d12)),
        contentPadding: EdgeInsets.symmetric(
            horizontal: dimension.d12, vertical: dimension.d12),
      );

  InputDecoration get datefInputDecoration => InputDecoration(
        labelText: strings.dateLabel,
        hintText: strings.dateHintExample,
        prefixIcon: const Icon(Icons.date_range),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(dimension.d12)),
        contentPadding: EdgeInsets.symmetric(
            horizontal: dimension.d12, vertical: dimension.d12),
      );
  InputDecoration get addresFInputDecoration => InputDecoration(
        filled: true,
        fillColor: appTheme.infieldColor,
        suffixIcon: const Icon(Icons.map),
        prefixIcon: const Icon(Icons.maps_home_work_rounded),
        hintText: strings.nearSohoHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d12),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: dimension.d12,
          vertical: dimension.d12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide: BorderSide(
            color: appTheme.borderColor,
            width: dimension.d1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d100),
          borderSide: BorderSide(
            color: appTheme.borderColor,
            width: dimension.d1,
          ),
        ),
      );
}
