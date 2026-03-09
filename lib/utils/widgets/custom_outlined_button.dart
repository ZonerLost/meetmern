import 'package:flutter/material.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/theme/theme.dart';

class CustomOutlinedButton extends StatelessWidget {
  const CustomOutlinedButton({
    super.key,
    this.decoration,
    this.leftIcon,
    this.rightIcon,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
    required this.text,
    this.onPressed,
    this.buttonStyle,
    this.buttonTextStyle,
    this.isDisabled = false,
    this.alignment,
    this.height,
    this.width,
    this.margin,
  });

  final BoxDecoration? decoration;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final Color borderColor;
  final double borderWidth;

  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? buttonStyle;
  final TextStyle? buttonTextStyle;
  final bool isDisabled;
  final Alignment? alignment;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    DimensionResource dimension = DimensionResource();
    final appTheme = ThemeHelper(appThemeName: "lightCode").themeColor;

    Widget outlinedButton = Container(
      height: height ?? dimension.d56,
      width: width ?? double.infinity,
      margin: margin,
      decoration: decoration,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onPressed ?? () {},
        style: buttonStyle ??
            OutlinedButton.styleFrom(
              side: BorderSide(color: borderColor, width: borderWidth),
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leftIcon != null) leftIcon!,
            Text(
              text,
              style: buttonTextStyle ??
                  TextStyle(
                    fontSize: dimension.d16,
                    fontWeight: FontWeight.w500,
                    color: appTheme.black90001,
                  ),
            ),
            if (rightIcon != null) rightIcon!,
          ],
        ),
      ),
    );

    return alignment != null
        ? Align(alignment: alignment!, child: outlinedButton)
        : outlinedButton;
  }
}
