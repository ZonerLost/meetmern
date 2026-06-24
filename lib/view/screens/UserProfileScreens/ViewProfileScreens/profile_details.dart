import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ViewProfileScreens/profile_details_controller.dart';
import 'package:meetmern/core/extensions/date_picker_extension.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_multi_select_button.dart';
import 'package:meetmern/core/widgets/custom_required_label.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData = ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return GetBuilder<ProfileDetailsController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: appTheme.coreWhite,
          appBar: AppBar(
            backgroundColor: appTheme.coreWhite,
            elevation: 0,
            leading: const BackButton(),
            title: Text(strings.profileDetailsTitle, style: styles.titleTextStyle),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: dimension.d16.w,
                vertical: dimension.d12.h,
              ),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar ──────────────────────────────────────────────
                    Text(strings.profilePictureLabel,
                        style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    Center(
                      child: GestureDetector(
                        onTap: controller.pickImage,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: dimension.d48.w * 2,
                              height: dimension.d48.w * 2,
                              decoration: BoxDecoration(
                                color: appTheme.borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(child: _buildAvatar(controller, strings)),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: EdgeInsets.all(dimension.d6.w),
                                decoration: BoxDecoration(
                                  color: appTheme.coreWhite,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt, size: dimension.d18.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: dimension.d20.h),

                    // ── Name ────────────────────────────────────────────────
                    Text(strings.nameLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomTextFormField(
                      controller: controller.nameController,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? strings.pleaseEnterYourNameText
                          : null,
                      inputDecoration: styles.userNameInputDecoration,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Email ───────────────────────────────────────────────
                    Text(strings.emailPrompt, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomTextFormField(
                      controller: controller.emailController,
                      textInputType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return strings.pleaseEnterYourEmailText;
                        }
                        if (!v.contains('@')) return strings.enterValidEmailText;
                        return null;
                      },
                      inputDecoration: styles.emailInputDecoration,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Bio ─────────────────────────────────────────────────
                    Text(strings.bioLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomTextFormField(
                      controller: controller.bioController,
                      maxLines: 3,
                      inputDecoration: styles.userNameInputDecoration,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Date of Birth ───────────────────────────────────────
                    RequiredLabel(text: strings.dateOfBirthLabel),
                    SizedBox(height: dimension.d10.h),
                    CustomTextFormField(
                      controller: controller.dobController,
                      textInputType: TextInputType.datetime,
                      hintText: strings.dateFormatHint,
                      inputDecoration: styles.dateFieldInputDecoration(
                        suffix: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.calendar_today,
                            size: dimension.d20.w,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            context.pickDobIntoController(
                              controller.dobController,
                              initialDate: DateTime(1995, 1, 1),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Gender ──────────────────────────────────────────────
                    RequiredLabel(text: strings.genderLabel),
                    SizedBox(height: dimension.d10.h),
                    CustomDropdownButton(
                      decoration: styles.genderFInputDecoration,
                      hint: strings.genderHint,
                      items: OnboardingMockData.genders,
                      value: controller.gender,
                      onChanged: controller.setGender,
                      itemHeight: dimension.d48.h,
                      menuMaxHeight: dimension.d200.h,
                      menuMaxWidth: dimension.d320.h,
                      alignMenuRight: true,
                    ),
                    SizedBox(height: dimension.d14.h),

                    // ── Ethnicity ───────────────────────────────────────────
                    RequiredLabel(text: strings.ethnicityLabel),
                    SizedBox(height: dimension.d10.h),
                    CustomDropdownButton(
                      decoration: styles.genderFInputDecoration,
                      hint: strings.ethnicityHint,
                      items: OnboardingMockData.ethnicities,
                      value: controller.ethnicity,
                      onChanged: controller.setEthnicity,
                      itemHeight: dimension.d48.h,
                      menuMaxHeight: dimension.d200.h,
                      alignMenuRight: true,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Orientation ─────────────────────────────────────────
                    Text(strings.orientationLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomDropdownButton(
                      decoration: styles.genderFInputDecoration,
                      hint: strings.orientationHint,
                      items: OnboardingMockData.orientations,
                      value: controller.orientation,
                      onChanged: controller.setOrientation,
                      itemHeight: dimension.d48.h,
                      menuMaxHeight: dimension.d200.h,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Children ────────────────────────────────────────────
                    Text(strings.childrenLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomDropdownButton(
                      decoration: styles.genderFInputDecoration,
                      hint: strings.selectHint,
                      items: OnboardingMockData.children,
                      value: controller.children,
                      onChanged: controller.setChildren,
                      itemHeight: dimension.d48.h,
                      menuMaxHeight: dimension.d200.h,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Relationship Status ──────────────────────────────────
                    Text(strings.relationshipStatusLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomDropdownButton(
                      decoration: styles.genderFInputDecoration,
                      hint: strings.selectHint,
                      items: OnboardingMockData.relationshipStatus,
                      value: controller.relationshipStatus,
                      onChanged: controller.setRelationshipStatus,
                      itemHeight: dimension.d48.h,
                      menuMaxHeight: dimension.d200.h,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Dietary Preferences ──────────────────────────────────
                    Text(strings.dietaryPreferencesLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomMultiSelectButton(
                      hint: strings.selectdietaryPreferencesText,
                      items: OnboardingMockData.dietaryPreferences,
                      selectedValues: controller.dietaryPreferences,
                      decoration: styles.genderFInputDecoration,
                      onSelectionChanged: controller.setDietaryPreferences,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Religion ────────────────────────────────────────────
                    Text(strings.religionLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomDropdownButton(
                      decoration: styles.genderFInputDecoration,
                      hint: strings.selectOptional,
                      items: OnboardingMockData.religion,
                      value: controller.religion,
                      onChanged: controller.setReligion,
                      itemHeight: dimension.d48.h,
                      menuMaxHeight: dimension.d200.h,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Languages ───────────────────────────────────────────
                    Text(strings.languagesSpoken, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomMultiSelectButton(
                      hint: strings.selectLanguagesYouSpeakText,
                      items: OnboardingMockData.languages,
                      selectedValues: controller.languages,
                      decoration: styles.genderFInputDecoration,
                      onSelectionChanged: controller.setLanguages,
                    ),
                    SizedBox(height: dimension.d16.h),

                    // ── Interests ───────────────────────────────────────────
                    Text(strings.interestsLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    _ChipSelector(
                      items: OnboardingMockData.interests,
                      selected: controller.interests,
                      onToggle: controller.toggleInterest,
                    ),
                    SizedBox(height: dimension.d16.h),

                    // ── Passion Topics ───────────────────────────────────────
                    Text(strings.passionTopicsLabel, style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    _ChipSelector(
                      items: OnboardingMockData.passionTopics,
                      selected: controller.passionTopics,
                      onToggle: controller.togglePassionTopic,
                    ),
                    SizedBox(height: dimension.d24.h),

                    // ── Save button ─────────────────────────────────────────
                    CustomElevatedButton(
                      onPressed: controller.isSaving
                          ? null
                          : () async {
                              final saved = await controller.saveProfile();
                              if (saved && context.mounted) {
                                Navigator.of(context).pop();
                              }
                            },
                      buttonStyle: styles.loginButtonStyle,
                      text: controller.isSaving
                          ? 'Saving...'
                          : strings.saveDetailsText,
                      buttonTextStyle: styles.loginButtonTextStyle,
                    ),
                    SizedBox(height: dimension.d24.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatar(ProfileDetailsController controller, Strings strings) {
    // Newly picked image takes priority
    if (controller.imageBytes != null) {
      return Image.memory(
        controller.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initials(controller),
      );
    }
    // Existing remote photo
    if (controller.existingPhotoUrl?.isNotEmpty == true) {
      return Image.network(
        controller.existingPhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initials(controller),
      );
    }
    return _initials(controller);
  }

  Widget _initials(ProfileDetailsController controller) {
    final initial = controller.nameController.text.isNotEmpty
        ? controller.nameController.text[0].toUpperCase()
        : '?';
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          fontSize: dimension.d32.sp,
          fontWeight: FontWeight.bold,
          color: appTheme.black90001,
        ),
      ),
    );
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> items;
  final Set<String> selected;
  final void Function(String, bool) onToggle;

  const _ChipSelector({
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: dimension.d8.w,
      runSpacing: dimension.d8.h,
      children: items.map((item) {
        final isSelected = selected.contains(item);
        return ChoiceChip(
          showCheckmark: false,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          labelPadding: EdgeInsets.symmetric(
            horizontal: dimension.d4.w,
            vertical: dimension.d6.h,
          ),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected) ...[
                Icon(Icons.close, size: dimension.d14.r, color: appTheme.b_600),
                SizedBox(width: dimension.d4.w),
              ],
              Text(
                item,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: dimension.d14.sp,
                  color: isSelected ? appTheme.b_600 : appTheme.black900,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          selected: isSelected,
          onSelected: (val) => onToggle(item, val),
          selectedColor: appTheme.b_100,
          backgroundColor: appTheme.infieldColor,
          shape: StadiumBorder(
            side: BorderSide(
              color: isSelected ? appTheme.b_100 : appTheme.borderColor,
              width: dimension.d1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
