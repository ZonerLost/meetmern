import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_multi_select_button.dart';
import 'package:meetmern/core/widgets/custom_required_label.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

const strings = Strings();

class AboutPage extends StatelessWidget {
  final Map<String, dynamic> options;
  final String? selectedChildren;
  final void Function(String?) onChildrenChanged;
  final String? selectedRelationship;
  final void Function(String?) onRelationshipChanged;
  final String? selectedReligion;
  final void Function(String?) onReligionChanged;
  final TextEditingController bioController;
  final List<String> selectedDietary;
  final void Function(List<String>) onDietaryChanged;
  final bool showErrors;
  final VoidCallback onNext;
  final bool stepValid;
  final VoidCallback onDisabledTap;

  const AboutPage({
    super.key,
    required this.options,
    required this.selectedChildren,
    required this.onChildrenChanged,
    required this.onDietaryChanged,
    required this.selectedRelationship,
    required this.onRelationshipChanged,
    required this.selectedReligion,
    required this.onReligionChanged,
    required this.bioController,
    required this.selectedDietary,
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
    final childrenOpts = List<String>.from(options['children'] ?? []);
    final religionOpts = List<String>.from(options['religion'] ?? []);
    final dietExamples = List<String>.from(
      options['dietary_preferences'] ?? options['Dietarypreferences'] ?? [],
    );
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: dimension.d20.w),
      child: Form(
        autovalidateMode:
            showErrors ? AutovalidateMode.always : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: dimension.d16.h),
            Text(strings.aboutYouTitle,
                style: customButtonandTextStyles.titleTextStyle),
            SizedBox(height: dimension.d12.h),
            Text(strings.aboutYouSubtitle,
                style: customButtonandTextStyles.subtitleTextStyle),
            SizedBox(height: dimension.d20.h),

            // Children
            RequiredLabel(text: strings.childrenLabel),
            SizedBox(height: dimension.d14.h),
            CustomDropdownButton(
              hint: strings.selectHint,
              items: childrenOpts,
              value: selectedChildren,
              onChanged: onChildrenChanged,
              decoration: customButtonandTextStyles.genderFInputDecoration,
              itemHeight: dimension.d48.h,
              itemTextStyle: customButtonandTextStyles.userNameTextStyle,
              textStyle: customButtonandTextStyles.userNameTextStyle,
            ),
            if (showErrors && selectedChildren == null) ...[
              SizedBox(height: dimension.d4.h),
              Text(
                strings.pleaseSelectChildren,
                style: TextStyle(
                    color: appTheme.red, fontSize: dimension.d12.sp),
              ),
            ],
            SizedBox(height: dimension.d14.h),

            // Relationship status
            RequiredLabel(text: strings.relationshipStatusLabel),
            SizedBox(height: dimension.d14.h),
            CustomDropdownButton(
              hint: strings.selectHint,
              items: List<String>.from(options['relationship_status'] ?? []),
              value: selectedRelationship,
              onChanged: onRelationshipChanged,
              decoration: customButtonandTextStyles.genderFInputDecoration,
              itemHeight: dimension.d48.h,
              itemTextStyle: customButtonandTextStyles.userNameTextStyle,
              textStyle: customButtonandTextStyles.userNameTextStyle,
            ),
            if (showErrors && selectedRelationship == null) ...[
              SizedBox(height: dimension.d4.h),
              Text(
                strings.pleaseSelectRelationshipStatus,
                style: TextStyle(
                    color: appTheme.red, fontSize: dimension.d12.sp),
              ),
            ],
            SizedBox(height: dimension.d14.h),

            // Dietary preferences
            Text(
                '${strings.dietaryPreferencesLabel} (${strings.optionalLabel})',
                style: customButtonandTextStyles.emailLabelTextStyle),
            SizedBox(height: dimension.d14.h),
            CustomMultiSelectButton(
              decoration: customButtonandTextStyles.genderFInputDecoration,
              hint: strings.selectHint,
              items: dietExamples,
              selectedValues: selectedDietary,
              onSelectionChanged: onDietaryChanged,
            ),
            SizedBox(height: dimension.d14.h),

            // Religion
            Text('${strings.religionLabel} (${strings.optionalLabel})',
                style: customButtonandTextStyles.emailLabelTextStyle),
            SizedBox(height: dimension.d14.h),
            CustomDropdownButton(
              hint: strings.selectOptional,
              items: religionOpts,
              value: selectedReligion,
              onChanged: onReligionChanged,
              decoration: customButtonandTextStyles.genderFInputDecoration,
              itemHeight: dimension.d48.h,
              itemTextStyle: customButtonandTextStyles.userNameTextStyle,
              textStyle: customButtonandTextStyles.userNameTextStyle,
            ),
            SizedBox(height: dimension.d14.h),

            // Short bio
            Text(strings.shortBioLabel,
                style: customButtonandTextStyles.emailLabelTextStyle),
            SizedBox(height: dimension.d14.h),
            CustomTextFormField(
              controller: bioController,
              maxLines: 5,
              validator: (v) {
                if (!showErrors) return null;
                if (v == null || v.trim().isEmpty) return null;
                if (v.trim().length < 10) return strings.bioMinLength;
                return null;
              },
              inputDecoration:
                  customButtonandTextStyles.bioFieldInputDecoration(),
            ),
            SizedBox(height: dimension.d58.h),

            CustomElevatedButton(
              text: strings.nextButtonText,
              isDisabled: !stepValid,
              inactiveColor: appTheme.neutral_200,
              inactiveTextColor: appTheme.neutral_500,
              activeTextColor: appTheme.coreWhite,
              inactiveText: strings.nextButtonText,
              activeText: strings.doneText,
              activeColor: appTheme.b_Primary,
              onPressed: onNext,
              buttonStyle: customButtonandTextStyles.loginButtonStyle,
              buttonTextStyle: customButtonandTextStyles.loginButtonTextStyle,
            ),
            SizedBox(height: dimension.d20.h),
          ],
        ),
      ),
    );
  }
}
