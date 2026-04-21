import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomRoundedTile extends StatelessWidget {
  final String title;
  final String? subtitle;

  final TextStyle? titletextStyle;
  final TextStyle? subtitleStyle;

  final IconData? leadingIcon;
  final String? leadingImage;
  final double? leadingIconSize;

  final IconData? trailingIcon;
  final String? trailingText;
  final TextStyle? trailingTextStyle;

  final double? iconBoxWidth;
  final double? iconBoxHeight;

  final Color? iconBackgroundColor;
  final Color? iconColor;

  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;

  final BorderRadius? borderRadius;

  final double? width;
  final double? height;

  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;

  const CustomRoundedTile({
    super.key,
    required this.title,
    this.subtitle,
    this.titletextStyle,
    this.subtitleStyle,
    this.leadingIcon,
    this.leadingImage,
    this.leadingIconSize,
    this.trailingIcon,
    this.trailingText,
    this.trailingTextStyle,
    this.iconBoxWidth,
    this.iconBoxHeight,
    this.iconBackgroundColor,
    this.iconColor,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.width,
    this.height,
    this.onTap,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    final showLeading = leadingIcon != null || leadingImage != null;
    final showTrailing = trailingText != null || trailingIcon != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(14.r),
          border: Border.all(
            color: borderColor ?? Colors.grey.shade300,
            width: borderWidth ?? 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showLeading)
              Container(
                width: iconBoxWidth ?? 44.w,
                height: iconBoxHeight ?? 44.w,
                decoration: BoxDecoration(
                  color: iconBackgroundColor ?? Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: _buildLeading(),
              ),
            if (showLeading) SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: titletextStyle ??
                        TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: subtitleStyle ??
                          TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey,
                          ),
                    ),
                ],
              ),
            ),
            if (showTrailing)
              trailingText != null
                  ? GestureDetector(
                      onTap: onTrailingTap,
                      child: Text(
                        trailingText!,
                        style: trailingTextStyle ??
                            const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  : Icon(trailingIcon),
          ],
        ),
      ),
    );
  }

  Widget? _buildLeading() {
    if (leadingImage != null) {
      return ClipOval(
        child: Image.network(
          leadingImage!,
          fit: BoxFit.cover,
          width: iconBoxWidth ?? 44.w,
          height: iconBoxHeight ?? 44.w,
        ),
      );
    }

    if (leadingIcon != null) {
      return Icon(
        leadingIcon,
        color: iconColor ?? Colors.white,
        size: leadingIconSize ?? 22.sp,
      );
    }

    return null;
  }
}
