import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/core/extensions/date_picker_extension.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_multi_select_button.dart';
import 'package:meetmern/core/widgets/custom_required_label.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class ProfileDetailsScreen extends StatefulWidget {
  final String? initialName;
  final String? initialEmail;
  final String? initialBio;
  final String? initialDob;
  final String? initialGender;
  final String? initialEthnicity;
  final List<String>? initialLanguages;

  const ProfileDetailsScreen({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialBio,
    this.initialDob,
    this.initialGender,
    this.initialEthnicity,
    this.initialLanguages,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _passwordController;

  String? _gender;
  String? _ethnicity;
  List<String> _languages = [];

  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;

  static const Color primaryPurple = Color(0xFF7C3AED);

  bool isObscure = true;

  @override
  void initState() {
    super.initState();

    _nameCtrl = TextEditingController(
      text: widget.initialName ?? const Strings().initialProfileNameText,
    );

    _emailCtrl = TextEditingController(
      text: widget.initialEmail ?? const Strings().initialProfileEmailText,
    );

    _bioCtrl = TextEditingController(
      text: widget.initialBio ?? '',
    );

    _dobCtrl = TextEditingController(
      text: widget.initialDob ?? const Strings().initialProfileDobText,
    );

    _passwordController = TextEditingController(text: '123456');

    _gender = widget.initialGender ?? OnboardingMockData.genders.first;
    _ethnicity =
        widget.initialEthnicity ?? OnboardingMockData.ethnicities.first;
    _languages = widget.initialLanguages ?? const ['English', 'Spanish'];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _bioCtrl.dispose();
    _dobCtrl.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      final bytes = await picked.readAsBytes();

      if (!mounted) return;
      setState(() {
        _imageBytes = bytes;
      });
    } catch (e, st) {
      debugPrint('Image pick error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(const Strings().failedToPickImageText)),
        );
      }
    }
  }

  Future<void> _showImageSourceActionSheet() async {
    if (kIsWeb) {
      await _pickImage(ImageSource.gallery);
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(dimension.d12.r),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(const Strings().chooseFromGalleryText),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(const Strings().takeAPhotoText),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: Text(const Strings().cancelLabel),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _initialCircleText(String initial, CustomButtonStyles styles) {
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

  Widget _buildAvatar(CustomButtonStyles styles) {
    const strings = Strings();
    final initial =
        _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'A';
    final avatarSize = dimension.d48.w * 2;

    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        width: avatarSize,
        height: avatarSize,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialCircleText(initial, styles),
      );
    }

    return Image.asset(
      strings.img9,
      width: avatarSize,
      height: avatarSize,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _initialCircleText(initial, styles),
    );
  }

  String _relationshipFromFields() {
    return const Strings().initialProfileRelationshipText;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final result = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'dob': _dobCtrl.text.trim(),
      'gender': _gender,
      'ethnicity': _ethnicity,
      'languages': List<String>.from(_languages),
      'relationship': _relationshipFromFields(),
      'password': _passwordController.text.trim(),
      'imageBytes': _imageBytes,
    };

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(const Strings().profileUpdatedSnackText)),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    const genders = OnboardingMockData.genders;
    const ethnicities = OnboardingMockData.ethnicities;

    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;

    final customButtonAndTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: dimension.d16.w,
                vertical: dimension.d12.h,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Form(
                  key: _formKey,
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.profileDetailsTitle,
                          style: customButtonAndTextStyles.titleTextStyle,
                        ),
                        SizedBox(height: dimension.d16.h),
                        Text(
                          strings.profilePictureLabel,
                          style: customButtonAndTextStyles.emailLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d10.h),
                        Center(
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              GestureDetector(
                                onTap: _showImageSourceActionSheet,
                                child: Container(
                                  width: dimension.d48.w * 2,
                                  height: dimension.d48.w * 2,
                                  decoration: BoxDecoration(
                                    color: appTheme.borderColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: ClipOval(
                                    child: _buildAvatar(
                                      customButtonAndTextStyles,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: dimension.d0,
                                bottom: dimension.d0,
                                child: GestureDetector(
                                  onTap: _showImageSourceActionSheet,
                                  child: Container(
                                    padding: EdgeInsets.all(dimension.d6.w),
                                    decoration: BoxDecoration(
                                      color: appTheme.coreWhite,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: dimension.d18.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: dimension.d16.h),
                        Text(
                          strings.nameLabel,
                          style: customButtonAndTextStyles.emailLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d10.h),
                        CustomTextFormField(
                          controller: _nameCtrl,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return strings.pleaseEnterYourNameText;
                            }
                            return null;
                          },
                          inputDecoration:
                              customButtonAndTextStyles.userNameInputDecoration,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Text(
                          strings.emailPrompt,
                          style: customButtonAndTextStyles.emailLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d10.h),
                        CustomTextFormField(
                          controller: _emailCtrl,
                          textInputType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return strings.pleaseEnterYourEmailText;
                            }
                            if (!v.contains('@')) {
                              return strings.enterValidEmailText;
                            }
                            return null;
                          },
                          inputDecoration:
                              customButtonAndTextStyles.emailInputDecoration,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Row(
                          children: [
                            Text(
                              strings.passwordPrompt,
                              style:
                                  customButtonAndTextStyles.emailLabelTextStyle,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => CustomModalDialog(
                                    topLeftIcon: Icon(
                                      Icons.lock,
                                      color: appTheme.b_Primary,
                                    ),
                                    topRightIcon: IconButton(
                                      icon: Icon(Icons.close,
                                          size: dimension.d20),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    title: strings.changePasswordTitle,
                                    subtitle: strings.changePasswordSubtitle,
                                    fields: [
                                      DialogField(
                                        label: strings.currentPasswordLabel,
                                        hint: strings.maskPassword,
                                        isPassword: true,
                                        labelStyle: customButtonAndTextStyles
                                            .emailLabelTextStyle,
                                        hintStyle: customButtonAndTextStyles
                                            .emailLabelTextStyle,
                                      ),
                                      DialogField(
                                        label: strings.newPasswordLabel,
                                        hint: strings.maskPassword,
                                        isPassword: true,
                                        labelStyle: customButtonAndTextStyles
                                            .emailLabelTextStyle,
                                        hintStyle: customButtonAndTextStyles
                                            .emailLabelTextStyle,
                                      ),
                                      DialogField(
                                        label: strings.confirmPasswordLabel,
                                        hint: strings.maskPassword,
                                        isPassword: true,
                                        labelStyle: customButtonAndTextStyles
                                            .emailLabelTextStyle,
                                        hintStyle: customButtonAndTextStyles
                                            .emailLabelTextStyle,
                                        validator: (v) {
                                          if (v == null || v.isEmpty) {
                                            return strings
                                                .pleaseEnterPasswordText;
                                          }
                                          return null;
                                        },
                                      ),
                                    ],
                                    primaryLabel: strings.changeText,
                                    primaryButtonStyle:
                                        customButtonAndTextStyles
                                            .loginButtonStyle,
                                    primaryTextStyle: customButtonAndTextStyles
                                        .loginButtonTextStyle,
                                    onPrimary: () =>
                                        Navigator.of(context).pop(),
                                    secondaryLabel: strings.cancelLabel,
                                    onSecondary: () =>
                                        Navigator.of(context).pop(),
                                    secondaryButtonStyle:
                                        customButtonAndTextStyles
                                            .googleButtonStyle,
                                    secondaryTextStyle:
                                        customButtonAndTextStyles
                                            .cancelButtonTextStyle,
                                  ),
                                );
                              },
                              child: Text(
                                strings.changeText,
                                style: TextStyle(
                                  color: appTheme.b_Primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        CustomTextFormField(
                          controller: _passwordController,
                          obscureText: isObscure,
                          textStyle:
                              customButtonAndTextStyles.userNameTextStyle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return strings.pleaseEnterPasswordText;
                            } else if (value.length < dimension.d6) {
                              return strings.passwordMinLengthText;
                            }
                            return null;
                          },
                          inputDecoration:
                              customButtonAndTextStyles.passwordInputDecoration(
                            isObscure: isObscure,
                            onToggle: () {
                              setState(() {
                                isObscure = !isObscure;
                              });
                            },
                          ),
                        ),
                        SizedBox(height: dimension.d12.h),
                        RequiredLabel(text: strings.dateOfBirthLabel),
                        SizedBox(height: dimension.d10.h),
                        CustomTextFormField(
                          controller: _dobCtrl,
                          textInputType: TextInputType.datetime,
                          hintText: strings.dateFormatHint,
                          inputDecoration: customButtonAndTextStyles
                              .dateFieldInputDecoration(
                            suffix: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.calendar_today,
                                size: dimension.d20.w,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onPressed: () async {
                                FocusScope.of(context).unfocus();
                                context.pickDobIntoController(
                                  _dobCtrl,
                                  initialDate: DateTime(1995, 1, 1),
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: dimension.d12.h),
                        RequiredLabel(text: strings.genderLabel),
                        SizedBox(height: dimension.d10.h),
                        CustomDropdownButton(
                          decoration:
                              customButtonAndTextStyles.genderFInputDecoration,
                          hint: strings.genderHint,
                          items: genders,
                          value: _gender,
                          onChanged: (v) => setState(() => _gender = v),
                          itemHeight: dimension.d48.h,
                          menuMaxHeight: dimension.d200.h,
                          menuMaxWidth: dimension.d320.h,
                          alignMenuRight: true,
                        ),
                        SizedBox(height: dimension.d14.h),
                        RequiredLabel(text: strings.ethnicityLabel),
                        SizedBox(height: dimension.d10.h),
                        CustomDropdownButton(
                          decoration:
                              customButtonAndTextStyles.genderFInputDecoration,
                          hint: strings.ethnicityHint,
                          items: ethnicities,
                          value: _ethnicity,
                          onChanged: (v) => setState(() => _ethnicity = v),
                          itemHeight: dimension.d48.h,
                          menuMaxHeight: dimension.d200.h,
                          alignMenuRight: true,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Text(
                          strings.languagesSpoken,
                          style: customButtonAndTextStyles.emailLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d10.h),
                        CustomMultiSelectButton(
                          hint: strings.selectLanguagesYouSpeakText,
                          items: OnboardingMockData.languages,
                          selectedValues: _languages,
                          decoration:
                              customButtonAndTextStyles.genderFInputDecoration,
                          onSelectionChanged: (values) {
                            setState(() => _languages = values);
                          },
                        ),
                        SizedBox(height: dimension.d20.h),
                        CustomElevatedButton(
                          onPressed: _save,
                          buttonStyle:
                              customButtonAndTextStyles.loginButtonStyle,
                          text: strings.saveDetailsText,
                          buttonTextStyle:
                              customButtonAndTextStyles.loginButtonTextStyle,
                        ),
                        SizedBox(height: dimension.d24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
