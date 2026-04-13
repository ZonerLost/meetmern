import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_drop_down_button.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_multi_select_button.dart';
import 'package:meetmern/core/widgets/custom_required_label.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class AccountPreferencesScreen extends StatefulWidget {
  const AccountPreferencesScreen({super.key});

  @override
  State<AccountPreferencesScreen> createState() =>
      _AccountPreferencesScreenState();
}

class _AccountPreferencesScreenState extends State<AccountPreferencesScreen> {
  final Set<String> _interests = {};
  final Set<String> _passions = {};
  List<String> _dietary = [];

  String? _relationship;
  String? _children;
  String? _religion;

  final TextEditingController _shortBio = TextEditingController();

  String _key(String s) => s.trim();

  @override
  void initState() {
    super.initState();
    _interests.addAll(
      OnboardingMockData.interests.take(2).map(_key),
    );
    _passions.addAll(
      OnboardingMockData.passionTopics.take(2).map(_key),
    );
    _dietary = OnboardingMockData.dietaryPreferences.take(1).toList();
    _relationship = OnboardingMockData.relationshipStatus.isNotEmpty
        ? OnboardingMockData.relationshipStatus.first
        : null;
    _children = OnboardingMockData.children.isNotEmpty
        ? OnboardingMockData.children.first
        : null;
    _religion = OnboardingMockData.religion.isNotEmpty
        ? OnboardingMockData.religion.first
        : null;
    _shortBio.text = strings.dummybioMessage;
  }

  @override
  void dispose() {
    _shortBio.dispose();
    super.dispose();
  }

  bool get _canSave {
    return _interests.isNotEmpty ||
        _passions.isNotEmpty ||
        _dietary.isNotEmpty ||
        _relationship != null ||
        _children != null ||
        _religion != null ||
        _shortBio.text.trim().isNotEmpty;
  }

  void _resetAllFields() {
    setState(() {
      _interests.clear();
      _passions.clear();
      _dietary = [];
      _relationship = null;
      _children = null;
      _religion = null;
      _shortBio.clear();
    });
  }

  void _save() {
    if (!_canSave) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.preferencesUpdatedSnackText)),
    );

    Navigator.of(context).pop();
  }

  void _showDeleteDialog() {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CustomModalDialog(
          showLeftIconBackground: true,
          leftIconBackgroundColor: appTheme.redshade,
          topLeftIcon: Icon(
            Icons.delete,
            color: appTheme.red,
          ),
          showCloseButton: true,
          title: strings.deleteAccountTitleText,
          subtitle: strings.deleteAccountSubtitleText,
          primaryLabel: strings.yesDeleteText,
          primaryColor: appTheme.red,
          primaryTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          secondaryLabel: strings.closeLabel,
          secondaryTextStyle: customButtonandTextStyles.cancelButtonTextStyle,
          onPrimary: () {
            Navigator.of(ctx).pop();
            _resetAllFields();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.allSelectionsClearedSnackText)),
            );
          },
          onSecondary: () => Navigator.of(ctx).pop(),
        );
      },
    );
  }

  Widget buildChip(String label, bool selected) {
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

  Widget _buildOptionalSectionHeader(
    String title, {
    VoidCallback? onClear,
    bool showClear = false,
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

  ButtonStyle _saveButtonStyle(CustomButtonStyles styles) {
    final base = styles.loginButtonStyle;

    if (_canSave) {
      return base;
    }

    return base.copyWith(
      backgroundColor: WidgetStatePropertyAll(
        appTheme.borderColor.withOpacity(0.35),
      ),
      foregroundColor: WidgetStatePropertyAll(appTheme.neutral_500),
    );
  }

  @override
  Widget build(BuildContext context) {
    const interests = OnboardingMockData.interests;
    const passions = OnboardingMockData.passionTopics;
    const relationship = OnboardingMockData.relationshipStatus;
    const childrenOptions = OnboardingMockData.children;
    const religionOptions = OnboardingMockData.religion;

    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        actions: [
          IconButton(
            onPressed: _showDeleteDialog,
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
                style: customButtonandTextStyles.titleTextStyle,
              ),
              SizedBox(height: dimension.d10.h),
              Text(
                strings.accountPreferencesSubtitle,
                style: customButtonandTextStyles.subtitleTextStyle,
              ),
              SizedBox(height: dimension.d20.h),
              RequiredLabel(text: strings.interestsLabel),
              SizedBox(height: dimension.d8.h),
              Wrap(
                spacing: dimension.d8.w,
                runSpacing: dimension.d8.h,
                children: interests.map((i) {
                  final keyI = _key(i);
                  final sel = _interests.contains(keyI);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (sel) {
                          _interests.remove(keyI);
                        } else {
                          _interests.add(keyI);
                        }
                      });
                    },
                    child: buildChip(i, sel),
                  );
                }).toList(),
              ),
              SizedBox(height: dimension.d16.h),
              RequiredLabel(text: strings.passionTopicsLabel),
              SizedBox(height: dimension.d8.h),
              Wrap(
                spacing: dimension.d8.w,
                runSpacing: dimension.d8.h,
                children: passions.map((p) {
                  final keyP = _key(p);
                  final sel = _passions.contains(keyP);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (sel) {
                          _passions.remove(keyP);
                        } else {
                          _passions.add(keyP);
                        }
                      });
                    },
                    child: buildChip(p, sel),
                  );
                }).toList(),
              ),
              SizedBox(height: dimension.d16.h),
              _buildOptionalSectionHeader(
                strings.dietaryPreferencesText,
                showClear: _dietary.isNotEmpty,
                onClear: () {
                  setState(() {
                    _dietary = [];
                  });
                },
              ),
              SizedBox(height: dimension.d10.h),
              CustomMultiSelectButton(
                hint: strings.selectLanguagesYouSpeakText,
                items: OnboardingMockData.dietaryPreferences,
                selectedValues: _dietary,
                decoration: customButtonandTextStyles.genderFInputDecoration,
                onSelectionChanged: (values) {
                  setState(() {
                    _dietary = values;
                  });
                },
              ),
              SizedBox(height: dimension.d20.h),
              RequiredLabel(text: strings.relationshipStatusLabel),
              SizedBox(height: dimension.d10.h),
              CustomDropdownButton(
                decoration: customButtonandTextStyles.genderFInputDecoration,
                hint: strings.relationshipStatusLabel,
                items: relationship,
                value: _relationship,
                onChanged: (v) {
                  setState(() {
                    _relationship = v;
                  });
                },
                itemHeight: dimension.d48.h,
                menuMaxHeight: dimension.d200.h,
                menuMaxWidth: dimension.d320.w,
                alignMenuRight: true,
              ),
              SizedBox(height: dimension.d14.h),
              RequiredLabel(text: strings.childrenLabel),
              SizedBox(height: dimension.d10.h),
              CustomDropdownButton(
                decoration: customButtonandTextStyles.genderFInputDecoration,
                hint: strings.childrenLabel,
                items: childrenOptions,
                value: _children,
                onChanged: (v) {
                  setState(() {
                    _children = v;
                  });
                },
                itemHeight: dimension.d48.h,
                menuMaxHeight: dimension.d200.h,
                menuMaxWidth: dimension.d320.w,
                alignMenuRight: true,
              ),
              SizedBox(height: dimension.d14.h),
              _buildOptionalSectionHeader(
                strings.religionLabel,
                showClear: _religion != null,
                onClear: () {
                  setState(() {
                    _religion = null;
                  });
                },
              ),
              SizedBox(height: dimension.d10.h),
              CustomDropdownButton(
                decoration: customButtonandTextStyles.genderFInputDecoration,
                hint: strings.religionLabel,
                items: religionOptions,
                value: _religion,
                onChanged: (v) {
                  setState(() {
                    _religion = v;
                  });
                },
                itemHeight: dimension.d48.h,
                menuMaxHeight: dimension.d200.h,
                menuMaxWidth: dimension.d320.w,
                alignMenuRight: true,
              ),
              SizedBox(height: dimension.d14.h),
              _buildOptionalSectionHeader(
                strings.shortBioLabel,
                showClear: _shortBio.text.trim().isNotEmpty,
                onClear: () {
                  setState(() {
                    _shortBio.clear();
                  });
                },
              ),
              SizedBox(height: dimension.d8.h),
              CustomTextFormField(
                controller: _shortBio,
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
                    customButtonandTextStyles.messagefInputDecoration.copyWith(
                  labelStyle: TextStyle(
                    color: appTheme.neutral_400,
                  ),
                  floatingLabelStyle: TextStyle(
                    color: appTheme.black90001,
                  ),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomElevatedButton(
                onPressed: _canSave ? _save : null,
                buttonStyle: _saveButtonStyle(customButtonandTextStyles),
                text: strings.saveDetailsText,
                buttonTextStyle:
                    customButtonandTextStyles.loginButtonTextStyle.copyWith(
                  color: _canSave ? appTheme.coreWhite : appTheme.neutral_500,
                  fontSize: dimension.d16.sp,
                ),
              ),
              SizedBox(height: dimension.d24.h),
            ],
          ),
        ),
      ),
    );
  }
}
