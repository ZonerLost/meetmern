import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

const _strings = Strings();

class PhotoPage extends StatelessWidget {
  final List<File> pickedImages;
  final List<String> existingPhotoUrls;
  final void Function(File) onAdd;
  final void Function(int index) onRemove;
  final VoidCallback onNext;
  final bool stepValid;
  final VoidCallback onDisabledTap;

  const PhotoPage({
    super.key,
    required this.pickedImages,
    required this.existingPhotoUrls,
    required this.onAdd,
    required this.onRemove,
    required this.onNext,
    required this.stepValid,
    required this.onDisabledTap,
  });

  bool get _hasImages =>
      existingPhotoUrls.isNotEmpty || pickedImages.isNotEmpty;

  Future<void> _pick() async {
    final XFile? f = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (f != null) onAdd(File(f.path));
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: _strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  dimension.d20.w, dimension.d16.h, dimension.d20.w, dimension.d24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_strings.addPhotoTitle, style: styles.titleTextStyle),
                  SizedBox(height: dimension.d8.h),
                  Text(_strings.addPhotoSubtitle,
                      style: styles.subtitleTextStyle),
                  SizedBox(height: dimension.d28.h),

                  // "Upload" bold label only in empty state
                  if (!_hasImages) ...[
                    Text(
                      _strings.uploadLabel,
                      style: TextStyle(
                        fontSize: dimension.d16.sp,
                        fontWeight: FontWeight.w600,
                        color: appTheme.black90001,
                      ),
                    ),
                    SizedBox(height: dimension.d12.h),
                  ],

                  // Empty-state upload box OR thumbnail grid
                  _hasImages
                      ? _GridBody(
                          existingPhotoUrls: existingPhotoUrls,
                          pickedImages: pickedImages,
                          onRemove: onRemove,
                          onAdd: _pick,
                        )
                      : _EmptyUploadBox(onTap: _pick),

                  const Spacer(),

                  CustomElevatedButton(
                    text: _strings.nextButtonText,
                    isDisabled: !stepValid,
                    inactiveColor: appTheme.neutral_200,
                    inactiveTextColor: appTheme.neutral_500,
                    activeTextColor: appTheme.coreWhite,
                    activeColor: appTheme.b_Primary,
                    onPressed: onNext,
                    onDisabledPressed: onDisabledTap,
                    buttonStyle: styles.loginButtonStyle,
                    buttonTextStyle: styles.loginButtonTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyUploadBox extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyUploadBox({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 220.h,
        decoration: BoxDecoration(
          color: appTheme.infieldColor,
          border: Border.all(color: appTheme.neutral_300),
          borderRadius: BorderRadius.circular(dimension.d16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.upload,
              size: dimension.d28.sp,
              // color: appTheme.b_Primary,
            ),
            SizedBox(height: dimension.d14.h),
            Text(
              _strings.uploadLabel,
              style: TextStyle(
                fontSize: dimension.d15.sp,
                fontWeight: FontWeight.w600,
                // color: appTheme.b_Primary,
              ),
            ),
            SizedBox(height: dimension.d6.h),
            Text(
              'Recommended size: 512 px by 512 px',
              style: TextStyle(
                fontSize: dimension.d12.sp,
                color: appTheme.neutral_500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grid body (visible once at least one image is selected) ───────────────────

class _GridBody extends StatelessWidget {
  static const double _tileSize = 150;

  final List<String> existingPhotoUrls;
  final List<File> pickedImages;
  final void Function(int) onRemove;
  final VoidCallback onAdd;

  const _GridBody({
    required this.existingPhotoUrls,
    required this.pickedImages,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: dimension.d10.w,
          runSpacing: dimension.d10.h,
          children: [
            // Already-uploaded photos (non-removable, "Profile" badge on first)
            ...List.generate(
              existingPhotoUrls.length,
              (i) => _NetworkTile(url: existingPhotoUrls[i], isFirst: i == 0),
            ),

            // Newly picked local images (removable)
            ...List.generate(
              pickedImages.length,
              (i) => _FileTile(
                file: pickedImages[i],
                isFirst: existingPhotoUrls.isEmpty && i == 0,
                onRemove: () => onRemove(i),
              ),
            ),

            // Add-more tile
            _AddMoreTile(onTap: onAdd),
          ],
        ),
        SizedBox(height: dimension.d10.h),
       
      ],
    );
  }
}

// ── Tile sub-widgets ──────────────────────────────────────────────────────────

class _AddMoreTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMoreTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _GridBody._tileSize.w,
        height: _GridBody._tileSize.w,
        decoration: BoxDecoration(
          color: appTheme.infieldColor,
          borderRadius: BorderRadius.circular(dimension.d12.r),
          border: Border.all(color: appTheme.neutral_300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.upload,
                size: dimension.d28.sp,),
            SizedBox(height: dimension.d6.h),
            Text(
              'Upload',
              style: TextStyle(
                fontSize: dimension.d12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileTile extends StatelessWidget {
  final File file;
  final bool isFirst;
  final VoidCallback onRemove;
  const _FileTile(
      {required this.file, required this.isFirst, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(dimension.d12.r),
          child: Image.file(
            file,
            width: _GridBody._tileSize.w,
            height: _GridBody._tileSize.w,
            fit: BoxFit.cover,
          ),
        ),
        if (isFirst) _profileBadge(),
        _removeButton(),
      ],
    );
  }

  Widget _profileBadge() => Positioned(
        bottom: dimension.d6.h,
        left: dimension.d6.w,
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: dimension.d6.w, vertical: dimension.d2.h),
          decoration: BoxDecoration(
            color: appTheme.b_Primary.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(dimension.d4.r),
          ),
          child: Text(
            'Profile',
            style: TextStyle(
                color: appTheme.coreWhite,
                fontSize: dimension.d10.sp,
                fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget _removeButton() => Positioned(
        top: dimension.d4.h,
        right: dimension.d4.w,
        child: GestureDetector(
          onTap: onRemove,
          child: Container(
            width: dimension.d22.w,
            height: dimension.d22.w,
            decoration: BoxDecoration(
              color: appTheme.black90001.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.close,
                size: dimension.d14.sp, color: appTheme.coreWhite),
          ),
        ),
      );
}

class _NetworkTile extends StatelessWidget {
  final String url;
  final bool isFirst;
  const _NetworkTile({required this.url, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(dimension.d12.r),
          child: Image.network(
            url,
            width: _GridBody._tileSize.w,
            height: _GridBody._tileSize.w,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: _GridBody._tileSize.w,
              height: _GridBody._tileSize.w,
              color: appTheme.borderColor,
              child: Icon(Icons.broken_image_outlined,
                  color: appTheme.neutral_400),
            ),
          ),
        ),
        if (isFirst)
          Positioned(
            bottom: dimension.d6.h,
            left: dimension.d6.w,
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: dimension.d6.w, vertical: dimension.d2.h),
              decoration: BoxDecoration(
                color: appTheme.b_Primary.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(dimension.d4.r),
              ),
              child: Text(
                'Profile',
                style: TextStyle(
                    color: appTheme.coreWhite,
                    fontSize: dimension.d10.sp,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
      ],
    );
  }
}
