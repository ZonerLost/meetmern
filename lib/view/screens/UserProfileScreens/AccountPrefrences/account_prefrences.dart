import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/screens/onboardingscreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_multi_select_button.dart';
import 'package:meetmern/core/widgets/custom_required_label.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/userprofile_controller/AccountPrefrences/account_prefrences_controller.dart';

class AccountPreferencesScreen extends StatelessWidget {
  const AccountPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return GetBuilder<AccountPreferencesController>(
      builder: (c) {
        if (c.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: appTheme.coreWhite,
          appBar: AppBar(
            backgroundColor: appTheme.coreWhite,
            actions: [
              IconButton(
                onPressed: () => _showDeleteDialog(context, c, styles),
                icon: Icon(Icons.delete_outline, color: appTheme.red),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(dimension.d16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.accountPreferencesScreenTitle,
                    style: styles.titleTextStyle,
                  ),
                  SizedBox(height: dimension.d10.h),
                  Text(
                    strings.accountPreferencesSubtitle,
                    style: styles.subtitleTextStyle,
                  ),
                  SizedBox(height: dimension.d20.h),

                  // Interests
                  RequiredLabel(text: strings.interestsLabel),
                  SizedBox(height: dimension.d8.h),
                  Wrap(
                    spacing: dimension.d8.w,
                    runSpacing: dimension.d8.h,
                    children: OnboardingMockData.interests.map((i) {
                      final sel = c.interests.contains(i);
                      return GestureDetector(
                        onTap: () => c.toggleInterest(i),
                        child: _buildChip(i, sel),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: dimension.d16.h),

                  // Passion Topics
                  RequiredLabel(text: strings.passionTopicsLabel),
                  SizedBox(height: dimension.d8.h),
                  Wrap(
                    spacing: dimension.d8.w,
                    runSpacing: dimension.d8.h,
                    children: OnboardingMockData.passionTopics.map((p) {
                      final sel = c.passions.contains(p);
                      return GestureDetector(
                        onTap: () => c.togglePassion(p),
                        child: _buildChip(p, sel),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: dimension.d16.h),

                  // Dietary
                  _sectionHeader(
                    strings.dietaryPreferencesText,
                    showClear: c.dietary.isNotEmpty,
                    onClear: c.clearDietary,
                  ),
                  SizedBox(height: dimension.d10.h),
                  CustomMultiSelectButton(
                    hint: strings.selectLanguagesYouSpeakText,
                    items: OnboardingMockData.dietaryPreferences,
                    selectedValues: c.dietary,
                    decoration: styles.genderFInputDecoration,
                    onSelectionChanged: c.setDietary,
                  ),
                  SizedBox(height: dimension.d20.h),

                  // Relationship Status
                  RequiredLabel(text: strings.relationshipStatusLabel),
                  SizedBox(height: dimension.d10.h),
                  CustomDropdownButton(
                    decoration: styles.genderFInputDecoration,
                    hint: strings.relationshipStatusLabel,
                    items: OnboardingMockData.relationshipStatus,
                    value: c.relationship,
                    onChanged: c.setRelationship,
                    itemHeight: dimension.d48.h,
                    menuMaxHeight: dimension.d200.h,
                    menuMaxWidth: dimension.d320.w,
                    alignMenuRight: true,
                  ),
                  SizedBox(height: dimension.d14.h),

                  // Children
                  RequiredLabel(text: strings.childrenLabel),
                  SizedBox(height: dimension.d10.h),
                  CustomDropdownButton(
                    decoration: styles.genderFInputDecoration,
                    hint: strings.childrenLabel,
                    items: OnboardingMockData.children,
                    value: c.children,
                    onChanged: c.setChildren,
                    itemHeight: dimension.d48.h,
                    menuMaxHeight: dimension.d200.h,
                    menuMaxWidth: dimension.d320.w,
                    alignMenuRight: true,
                  ),
                  SizedBox(height: dimension.d14.h),

                  // Religion
                  _sectionHeader(
                    strings.religionLabel,
                    showClear: c.religion != null,
                    onClear: c.clearReligion,
                  ),
                  SizedBox(height: dimension.d10.h),
                  CustomDropdownButton(
                    decoration: styles.genderFInputDecoration,
                    hint: strings.religionLabel,
                    items: OnboardingMockData.religion,
                    value: c.religion,
                    onChanged: c.setReligion,
                    itemHeight: dimension.d48.h,
                    menuMaxHeight: dimension.d200.h,
                    menuMaxWidth: dimension.d320.w,
                    alignMenuRight: true,
                  ),
                  SizedBox(height: dimension.d14.h),

                  // Short Bio
                  _sectionHeader(
                    strings.shortBioLabel,
                    showClear: c.shortBioController.text.trim().isNotEmpty,
                    onClear: c.clearBio,
                  ),
                  SizedBox(height: dimension.d8.h),
                  CustomTextFormField(
                    controller: c.shortBioController,
                    maxLines: 5,
                    textInputType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    hintText: strings.shortBioHintText,
                    height: dimension.d120.h,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: dimension.d12.w,
                      vertical: dimension.d12.h,
                    ),
                    inputDecoration:
                        styles.messagefInputDecoration.copyWith(
                      labelStyle: TextStyle(color: appTheme.neutral_400),
                      floatingLabelStyle:
                          TextStyle(color: appTheme.black90001),
                    ),
                    onChanged: c.onBioChanged,
                  ),
                  SizedBox(height: dimension.d20.h),

                  // Save button
                  Obx(() => CustomElevatedButton(
                        onPressed: c.canSave && !c.isSaving.value
                            ? () => _save(context, c)
                            : null,
                        buttonStyle: _saveButtonStyle(styles, c.canSave),
                        text: c.isSaving.value
                            ? strings.savingText
                            : strings.saveDetailsText,
                        buttonTextStyle:
                            styles.loginButtonTextStyle.copyWith(
                          color: c.canSave
                              ? appTheme.coreWhite
                              : appTheme.neutral_500,
                          fontSize: dimension.d16.sp,
                        ),
                      )),
                  SizedBox(height: dimension.d24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChip(String label, bool selected) {
    return ChoiceChip(
      showCheckmark: false,
      labelPadding: EdgeInsets.symmetric(
        horizontal: dimension.d12.w,
        vertical: dimension.d6.h,
      ),
      label: Text(
        label,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: dimension.d14.sp,
          color: selected ? appTheme.b_600 : appTheme.neutral_700,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      avatar: selected
          ? Icon(Icons.close, size: dimension.d16.sp, color: appTheme.b_600)
          : null,
      selectedColor: appTheme.b_100,
      backgroundColor: appTheme.infieldColor,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? appTheme.b_100 : appTheme.borderColor,
          width: dimension.d1.w,
        ),
      ),
    );
  }

  Widget _sectionHeader(
    String title, {
    bool showClear = false,
    VoidCallback? onClear,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: dimension.d16.sp,
            ),
          ),
        ),
        if (showClear)
          TextButton(
            onPressed: onClear,
            child: Text(
              strings.clearText,
              style: TextStyle(fontSize: dimension.d14.sp),
            ),
          ),
      ],
    );
  }

  ButtonStyle _saveButtonStyle(CustomButtonStyles styles, bool canSave) {
    if (canSave) return styles.loginButtonStyle;
    return styles.loginButtonStyle.copyWith(
      backgroundColor: WidgetStatePropertyAll(
        appTheme.borderColor.withOpacity(0.35),
      ),
      foregroundColor: WidgetStatePropertyAll(appTheme.neutral_500),
    );
  }

  Future<void> _save(
      BuildContext context, AccountPreferencesController c) async {
    final success = await c.save();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? strings.preferencesUpdatedSnackText
            : strings.errorSavingPreferencesText),
      ),
    );
    if (success) Navigator.of(context).pop();
  }

  void _showDeleteDialog(
    BuildContext context,
    AccountPreferencesController c,
    CustomButtonStyles styles,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomModalDialog(
        showLeftIconBackground: true,
        leftIconBackgroundColor: appTheme.redshade,
        topLeftIcon: Icon(Icons.delete, color: appTheme.red),
        showCloseButton: true,
        title: strings.deleteAccountTitleText,
        subtitle: strings.deleteAccountSubtitleText,
        primaryLabel: strings.yesDeleteText,
        primaryColor: appTheme.red,
        primaryTextStyle: styles.loginButtonTextStyle,
        secondaryLabel: strings.closeLabel,
        secondaryTextStyle: styles.cancelButtonTextStyle,
        onPrimary: () {
          Navigator.of(ctx).pop();
          c.resetAllFields();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(strings.allSelectionsClearedSnackText)),
          );
        },
        onSecondary: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}
