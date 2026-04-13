import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';

const strings = Strings();

class PhotoPage extends StatelessWidget {
  final File? pickedImage;
  final void Function(File) onPick;
  final VoidCallback onRemove;
  final VoidCallback onNext;
  final bool stepValid;
  final VoidCallback onDisabledTap;
  const PhotoPage({
    super.key,
    required this.pickedImage,
    required this.onPick,
    required this.onRemove,
    required this.onNext,
    required this.stepValid,
    required this.onDisabledTap,
  });
  Future<void> _pick(BuildContext context) async {
    final ImagePicker p = ImagePicker();
    final XFile? f =
        await p.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) onPick(File(f.path));
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimension.d20.w),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: dimension.d16.h),
          Text(strings.addPhotoTitle,
              style: customButtonandTextStyles.titleTextStyle),
          SizedBox(height: dimension.d8.h),
          Text(strings.addPhotoSubtitle,
              style: customButtonandTextStyles.subtitleTextStyle),
          SizedBox(height: dimension.d20.h),
          Text(strings.uploadLabel,
              style: customButtonandTextStyles.emailLabelTextStyle),
          SizedBox(height: dimension.d20.h),
          Row(children: [
            Container(
              child: pickedImage == null
                  ? GestureDetector(
                      onTap: () => _pick(context),
                      child: Container(
                        height: dimension.d350.h,
                        width: dimension.d336.w,
                        decoration: BoxDecoration(
                          color: appTheme.infieldColor,
                          borderRadius: BorderRadius.circular(dimension.d12.r),
                          border: Border.all(color: appTheme.neutral_300),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_upload_outlined,
                                size: dimension.d20.sp,
                                color: appTheme.neutral_600),
                            SizedBox(height: dimension.d8.h),
                            Text(strings.uploadLabel,
                                style: customButtonandTextStyles
                                    .userNameTextStyle),
                            SizedBox(height: dimension.d4.h),
                            Text(strings.uploadRecommended,
                                style: customButtonandTextStyles
                                    .userNameTextStyle),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      height: dimension.d200.h,
                      width: dimension.d100.w,
                      decoration: BoxDecoration(
                        color: appTheme.neutral_50,
                        borderRadius: BorderRadius.circular(dimension.d12.r),
                        border: Border.all(color: appTheme.neutral_300),
                        image: DecorationImage(
                          image: FileImage(pickedImage!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: dimension.d18.w),
            if (pickedImage != null)
              GestureDetector(
                onTap: () => _pick(context),
                child: Container(
                  height: dimension.d300.h,
                  width: dimension.d100.w,
                  decoration: BoxDecoration(
                    color: appTheme.infieldColor,
                    borderRadius: BorderRadius.circular(dimension.d12.r),
                    border: Border.all(color: appTheme.neutral_300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: dimension.d28.sp, color: appTheme.neutral_600),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.uploadLabel,
                          style: customButtonandTextStyles.userNameTextStyle),
                    ],
                  ),
                ),
              ),
          ]),
          if (pickedImage != null)
            Padding(
              padding: EdgeInsets.only(top: dimension.d8.h),
              child: Row(children: [
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.delete, color: appTheme.red),
                ),
                SizedBox(width: dimension.d8.w),
                Text(strings.removePhotoLabel,
                    style: TextStyle(color: appTheme.neutral_800)),
              ]),
            ),
          SizedBox(height: dimension.d450.h),
          CustomElevatedButton(
            onPressed: stepValid ? onNext : null,
            buttonStyle: customButtonandTextStyles.loginButtonStyle,
            text: strings.nextButtonText,
            buttonTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          ),
        ]),
      ),
    );
  }
}
