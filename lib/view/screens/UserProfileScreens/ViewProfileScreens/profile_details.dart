import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
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
            title:
                Text(strings.profileDetailsTitle, style: styles.titleTextStyle),
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
                              child: ClipOval(
                                  child: _buildAvatar(controller, strings)),
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
                                child: Icon(Icons.camera_alt,
                                    size: dimension.d18.sp),
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
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? strings.pleaseEnterYourNameText
                              : null,
                      inputDecoration: styles.userNameInputDecoration,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Email ───────────────────────────────────────────────
                    Text(strings.emailPrompt,
                        style: styles.emailLabelTextStyle),
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

                    // ── Password ─────────────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Password', style: styles.emailLabelTextStyle),
                        TextButton(
                          onPressed: () =>
                              _showPasswordDialog(context, controller, styles),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: dimension.d12.w,
                                vertical: dimension.d4.h),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: appTheme.b_Primary,
                          ),
                          child: Text(
                            'Change',
                            style: TextStyle(
                              fontSize: dimension.d13.sp,
                              fontWeight: FontWeight.w600,
                              color: appTheme.b_Primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: dimension.d10.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                          horizontal: dimension.d14.w,
                          vertical: dimension.d14.h),
                      decoration: BoxDecoration(
                        color: appTheme.infieldColor,
                        borderRadius:
                            BorderRadius.circular(dimension.d12.r),
                        border: Border.all(color: appTheme.borderColor),
                      ),
                      child: Text(
                        '••••••••',
                        style: TextStyle(
                            fontSize: dimension.d16.sp,
                            color: appTheme.neutral_500,
                            letterSpacing: 2),
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

                    // ── Languages ───────────────────────────────────────────
                    Text(strings.languagesSpoken,
                        style: styles.emailLabelTextStyle),
                    SizedBox(height: dimension.d10.h),
                    CustomMultiSelectButton(
                      hint: strings.selectLanguagesYouSpeakText,
                      items: OnboardingMockData.languages,
                      selectedValues: controller.languages,
                      decoration: styles.genderFInputDecoration,
                      onSelectionChanged: controller.setLanguages,
                    ),
                    SizedBox(height: dimension.d12.h),

                    // ── Orientation ─────────────────────────────────────────
                    Text(strings.orientationLabel,
                        style: styles.emailLabelTextStyle),
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

  void _showPasswordDialog(
    BuildContext context,
    ProfileDetailsController controller,
    CustomButtonStyles styles,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PasswordDialog(
        controller: controller,
        styles: styles,
      ),
    );
  }

  Widget _buildAvatar(ProfileDetailsController controller, Strings strings) {
    if (controller.imageBytes != null) {
      return Image.memory(
        controller.imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initials(controller),
      );
    }
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

// ── Password change dialog ────────────────────────────────────────────────────

class _PasswordDialog extends StatefulWidget {
  final ProfileDetailsController controller;
  final CustomButtonStyles styles;

  const _PasswordDialog({
    required this.controller,
    required this.styles,
  });

  @override
  State<_PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<_PasswordDialog> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentCtrl.text.trim();
    final newPw = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (current.isEmpty || newPw.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (newPw.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (newPw != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final err = await widget.controller.changePassword(
      currentPassword: current,
      newPassword: newPw,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) {
      setState(() => _error = err);
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: appTheme.coreWhite,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dimension.d20.r)),
      insetPadding:
          EdgeInsets.symmetric(horizontal: dimension.d20.w, vertical: 40.h),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            dimension.d20.w, dimension.d20.h, dimension.d20.w, dimension.d24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ──────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: dimension.d36.w,
                  height: dimension.d36.w,
                  decoration: BoxDecoration(
                    color: appTheme.b_100,
                    borderRadius: BorderRadius.circular(dimension.d20.r),
                  ),
                  child: Icon(LucideIcons.lock,
                      color: appTheme.b_Primary, size: dimension.d20.sp),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child:
                      Icon(Icons.close, size: dimension.d22.sp, color: appTheme.neutral_600),
                ),
              ],
            ),
            SizedBox(height: dimension.d14.h),

            Text(
              'Change Your Password',
              style: TextStyle(
                fontSize: dimension.d18.sp,
                fontWeight: FontWeight.w700,
                color: appTheme.black90001,
              ),
            ),
            SizedBox(height: dimension.d6.h),
            Text(
              'For your account\'s security, enter your current password and set a new one.',
              style: TextStyle(
                fontSize: dimension.d13.sp,
                color: appTheme.neutral_500,
                height: 1.4,
              ),
            ),
            SizedBox(height: dimension.d20.h),

            // ── Current password ─────────────────────────────────────────────
            Text('Current Password',
                style: widget.styles.emailLabelTextStyle),
            SizedBox(height: dimension.d8.h),
            _PasswordField(
              controller: _currentCtrl,
              hint: 'Enter current password',
              obscure: !_showCurrent,
              onToggle: () => setState(() => _showCurrent = !_showCurrent),
            ),
            SizedBox(height: dimension.d14.h),

            // ── New password ─────────────────────────────────────────────────
            Text('New Password', style: widget.styles.emailLabelTextStyle),
            SizedBox(height: dimension.d8.h),
            _PasswordField(
              controller: _newCtrl,
              hint: 'Enter new password',
              obscure: !_showNew,
              onToggle: () => setState(() => _showNew = !_showNew),
            ),
            SizedBox(height: dimension.d14.h),

            // ── Confirm password ─────────────────────────────────────────────
            Text('Confirm Password', style: widget.styles.emailLabelTextStyle),
            SizedBox(height: dimension.d8.h),
            _PasswordField(
              controller: _confirmCtrl,
              hint: 'Re-enter new password',
              obscure: !_showConfirm,
              onToggle: () => setState(() => _showConfirm = !_showConfirm),
            ),

            if (_error != null) ...[
              SizedBox(height: dimension.d10.h),
              Text(
                _error!,
                style: TextStyle(
                    color: appTheme.red, fontSize: dimension.d12.sp),
              ),
            ],

            SizedBox(height: dimension.d20.h),

            // ── Yes, Change button ───────────────────────────────────────────
            CustomElevatedButton(
              text: _loading ? '' : 'Yes, Change',
              onPressed: _loading ? null : _submit,
              buttonStyle: widget.styles.loginButtonStyle,
              buttonTextStyle: widget.styles.loginButtonTextStyle,
              activeColor: appTheme.b_Primary,
              activeTextColor: appTheme.coreWhite,
              inactiveColor: appTheme.neutral_200,
              inactiveTextColor: appTheme.neutral_500,
              isDisabled: _loading,
              child: _loading
                  ? SizedBox(
                      width: dimension.d20.w,
                      height: dimension.d20.w,
                      child: CircularProgressIndicator(
                          color: appTheme.coreWhite, strokeWidth: 2),
                    )
                  : null,
            ),
            SizedBox(height: dimension.d10.h),

            // ── Cancel button ────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: appTheme.black90001,
                  padding: EdgeInsets.symmetric(vertical: dimension.d14.h),
                  shape: const StadiumBorder(),
                  side: BorderSide(color: appTheme.borderColor),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                      fontSize: dimension.d15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(fontSize: dimension.d14.sp, color: appTheme.black90001),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(fontSize: dimension.d14.sp, color: appTheme.neutral_400),
        filled: true,
        fillColor: appTheme.infieldColor,
        contentPadding: EdgeInsets.symmetric(
            horizontal: dimension.d14.w, vertical: dimension.d14.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d30.r),
          borderSide: BorderSide(color: appTheme.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d30.r),
          borderSide: BorderSide(color: appTheme.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimension.d30.r),
          borderSide: BorderSide(color: appTheme.b_Primary, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: dimension.d20.sp,
            color: appTheme.neutral_500,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

