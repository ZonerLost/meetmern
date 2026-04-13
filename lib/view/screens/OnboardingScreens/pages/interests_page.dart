import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_required_label.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

const strings = Strings();

class InterestsPage extends StatelessWidget {
  final Map<String, dynamic> options;
  final Set<String> selectedInterests;
  final void Function(String, bool) onToggleInterest;
  final Set<String> selectedPassions;
  final void Function(String, bool) onTogglePassion;
  final bool showErrors;
  final VoidCallback onNext;
  final bool stepValid;
  final VoidCallback onDisabledTap;

  const InterestsPage({
    super.key,
    required this.options,
    required this.selectedInterests,
    required this.onToggleInterest,
    required this.selectedPassions,
    required this.onTogglePassion,
    required this.showErrors,
    required this.onNext,
    required this.stepValid,
    required this.onDisabledTap,
  });
  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);
    final interests = List<String>.from(options['interests'] ?? []);
    final passions = List<String>.from(options['passion_topics'] ?? []);

    Widget buildChip(
      String text,
      bool selected,
      void Function(bool) onSelected,
    ) {
      return ChoiceChip(
        showCheckmark: false,
        labelPadding: EdgeInsets.symmetric(
            horizontal: dimension.d12.w, vertical: dimension.d6.h),
        label: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: dimension.d14.sp,
            color: selected ? appTheme.b_600 : appTheme.black900,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: selected,
        avatar: selected
            ? Icon(Icons.close, size: dimension.d16.r, color: appTheme.b_600)
            : null,
        onSelected: onSelected,
        selectedColor: appTheme.b_100,
        backgroundColor: appTheme.infieldColor,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? appTheme.b_100 : appTheme.borderColor,
            width: dimension.d1,
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimension.d20.w),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: dimension.d16.h),
          Text(strings.interestsTitle,
              style: customButtonandTextStyles.titleTextStyle),
          SizedBox(height: dimension.d12.h),
          Text(strings.interestsSubtitle,
              style: customButtonandTextStyles.subtitleTextStyle),
          SizedBox(height: dimension.d16.h),
          RequiredLabel(text: strings.interestLabel),
          SizedBox(height: dimension.d8.h),
          Wrap(
            spacing: dimension.d8.w,
            runSpacing: dimension.d8.h,
            children: interests.map((it) {
              final sel = selectedInterests.contains(it);
              return buildChip(it, sel, (v) => onToggleInterest(it, v));
            }).toList(),
          ),
          if (showErrors &&
              selectedInterests.isEmpty &&
              selectedPassions.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: dimension.d8.h),
              child: Text(
                strings.selectAtLeastOneInterest,
                style:
                    TextStyle(color: appTheme.red, fontSize: dimension.d12.sp),
              ),
            ),
          SizedBox(height: dimension.d16.h),
          RequiredLabel(text: strings.passionTopicsLabel),
          SizedBox(height: dimension.d8.h),
          Wrap(
            spacing: dimension.d8.w,
            runSpacing: dimension.d8.h,
            children: passions.map((pt) {
              final sel = selectedPassions.contains(pt);
              return buildChip(pt, sel, (v) => onTogglePassion(pt, v));
            }).toList(),
          ),
          SizedBox(height: dimension.d30.h),
          CustomElevatedButton(
            text: strings.nextButtonText,
            isDisabled: !stepValid,
            inactiveColor: appTheme.neutral_200,
            inactiveTextColor: appTheme.neutral_500,
            activeTextColor: appTheme.coreWhite,
            activeColor: appTheme.b_Primary,
            onPressed: onNext,
            onDisabledPressed: onDisabledTap,
            buttonStyle: customButtonandTextStyles.loginButtonStyle,
            buttonTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          ),
        ]),
      ),
    );
  }
}
