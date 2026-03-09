import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/utils/constants/constants.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_drop_down_button.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';
import 'package:meetmern/utils/widgets/custom_multi_select_button.dart';
import 'package:meetmern/utils/widgets/custom_required_label.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

const strings = Strings();

class BasicsPage extends StatelessWidget {
  final Map<String, dynamic> options;
  final TextEditingController dobController;
  final String? selectedGender;
  final void Function(String?) onGenderChanged;
  final String? selectedEthnicity;
  final void Function(String?) onEthnicityChanged;
  final String? selectedOrientation;
  final void Function(String?) onOrientationChanged;
  final List<String> selectedLanguages;
  final void Function(List<String>) onLanguageChanged;
  final bool showErrors;
  final VoidCallback onNext;
  final bool stepValid;
  final VoidCallback onDisabledTap;

  const BasicsPage({
    super.key,
    required this.options,
    required this.dobController,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.selectedEthnicity,
    required this.onEthnicityChanged,
    required this.selectedOrientation,
    required this.onOrientationChanged,
    required this.selectedLanguages,
    required this.onLanguageChanged,
    required this.showErrors,
    required this.onNext,
    required this.stepValid,
    required this.onDisabledTap,
  });
  @override
  Widget build(BuildContext context) {
    final constants = Constants();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);
    final genders = List<String>.from(options[strings.genderKey] ?? []);
    final orientations =
        List<String>.from(options[strings.orientationKey] ?? []);
    final ethnicities = List<String>.from(options[strings.ethnicityKey] ?? []);
    final languages = List<String>.from(options[strings.languagesKey] ?? []);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dimension.d20.w),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: dimension.d16.h),
          Text(strings.startWithBasicsTitle,
              style: customButtonandTextStyles.titleTextStyle),
          SizedBox(height: dimension.d14.h),
          Text(strings.startWithBasicsSubtitle,
              style: customButtonandTextStyles.subtitleTextStyle),
          SizedBox(height: dimension.d20.h),
          RequiredLabel(text: strings.dateOfBirthLabel),
          SizedBox(height: dimension.d14.h),
          CustomTextFormField(
            width: dimension.d366.w,
            height: dimension.d48.h,
            controller: dobController,
            textInputType: TextInputType.datetime,
            hintText: strings.dateFormatHint,
            inputDecoration: customButtonandTextStyles.dateFieldInputDecoration(
              suffix: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.calendar_today,
                  size: dimension.d20.w,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(constants.s1995),
                    firstDate: DateTime(constants.s1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    dobController.text =
                        "${picked.year}-${picked.month.toString().padLeft(constants.s2, '0')}-${picked.day.toString().padLeft(constants.s2, '0')}";
                  }
                },
              ),
            ),
            validator: (v) {
              if (!showErrors) return null;
              if (v == null || v.isEmpty) return strings.selectDateOfBirth;
              return null;
            },
          ),
          SizedBox(height: dimension.d14.h),
          RequiredLabel(text: strings.genderLabel),
          CustomDropdownButton(
            decoration: customButtonandTextStyles.genderFInputDecoration,
            width: dimension.d366.w,
            height: dimension.d48.h,
            hint: strings.genderHint,
            items: genders,
            value: selectedGender,
            onChanged: onGenderChanged,
            itemHeight: dimension.d48.h,
            menuMaxHeight: dimension.d200.h,
            menuMaxWidth: dimension.d320.h,
            alignMenuRight: true,
          ),
          SizedBox(height: dimension.d14.h),
          RequiredLabel(text: strings.ethnicityLabel),
          CustomDropdownButton(
            width: dimension.d366.w,
            height: dimension.d48.h,
            decoration: customButtonandTextStyles.genderFInputDecoration,
            hint: strings.ethnicityHint,
            items: ethnicities,
            value: selectedEthnicity,
            onChanged: onEthnicityChanged,
            itemHeight: dimension.d48.h,
            menuMaxHeight: dimension.d200.h,
            alignMenuRight: true,
          ),
          SizedBox(height: dimension.d14.h),
          RequiredLabel(text: strings.orientationLabel),
          CustomDropdownButton(
            width: dimension.d366.w,
            height: dimension.d48.h,
            decoration: customButtonandTextStyles.genderFInputDecoration,
            hint: strings.orientationHint,
            items: orientations,
            value: selectedOrientation,
            onChanged: onOrientationChanged,
            itemHeight: dimension.d48.h,
            menuMaxHeight: dimension.d200.h,
            alignMenuRight: true,
          ),
          SizedBox(height: dimension.d14.h),
          Text('${strings.languagesLabel} (${strings.optionalLabel})',
              style: customButtonandTextStyles.emailLabelTextStyle),
          SizedBox(height: dimension.d14.h),
          CustomMultiSelectButton(
            width: dimension.d366.w,
            height: dimension.d48.h,
            decoration: customButtonandTextStyles.genderFInputDecoration,
            hint: strings.languageHint,
            items: languages,
            selectedValues: selectedLanguages,
            onSelectionChanged: onLanguageChanged,
          ),
          SizedBox(height: dimension.d58.h),
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
            height: dimension.d54.h,
            width: dimension.d366.w,
          ),
        ]),
      ),
    );
  }
}
