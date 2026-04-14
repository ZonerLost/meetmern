import 'package:flutter/material.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/theme/theme.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    this.decoration,
    this.leftIcon,
    this.rightIcon,
    required this.text,
    this.activeText,
    this.inactiveText,
    this.activeColor,
    this.inactiveColor,
    this.activeTextColor,
    this.inactiveTextColor,
    this.onPressed,
    this.onDisabledPressed,
    this.buttonStyle,
    this.buttonTextStyle,
    this.isDisabled = false,
    this.disabledColor,
    this.disabledTextColor,
    this.alignment,
    this.height,
    this.width,
    this.margin,
    this.elevation = 2.0,
    this.child,
  });

  final BoxDecoration? decoration;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final String text;
  final String? activeText;
  final String? inactiveText;
  final VoidCallback? onPressed;
  final VoidCallback? onDisabledPressed;
  final ButtonStyle? buttonStyle;
  final TextStyle? buttonTextStyle;
  final bool isDisabled;
  final Color? disabledColor;
  final Color? disabledTextColor;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeTextColor;
  final Color? inactiveTextColor;
  final Alignment? alignment;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? margin;
  final double elevation;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final DimensionResource dimension = DimensionResource();
    final appTheme = ThemeHelper(appThemeName: "lightCode").themeColor;

    final double finalHeight = (height ?? dimension.d56).toDouble();
    final double? finalWidth = width;

    final bool disabled = isDisabled || onPressed == null;

    final String label =
        disabled ? (inactiveText ?? text) : (activeText ?? text);

    final Color enabledColor = activeColor ?? appTheme.b_Primary;
    final Color defaultDisabledBg =
        appTheme.neutral_200 ?? enabledColor.withOpacity(0.35);
    final Color resolvedDisabledBg =
        inactiveColor ?? disabledColor ?? defaultDisabledBg;

    const Color defaultLabelColor = Colors.white;

    final Color resolvedEnabledText =
        activeTextColor ?? buttonTextStyle?.color ?? defaultLabelColor;

    final Color resolvedDisabledText = inactiveTextColor ??
        disabledTextColor ??
        Colors.white.withOpacity(0.75);

    // Always enforce minimumSize so height is respected even when buttonStyle is provided.
    final ButtonStyle resolvedStyle = (buttonStyle ??
            ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: dimension.d16),
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dimension.d100),
              ),
              backgroundColor: enabledColor,
              foregroundColor: resolvedEnabledText,
            ))
        .copyWith(
      minimumSize: WidgetStateProperty.all(
        Size(finalWidth ?? double.infinity, finalHeight),
      ),
    );

    Widget button = Container(
      margin: margin,
      decoration: decoration,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: finalHeight,
          maxHeight: finalHeight,
          minWidth: finalWidth ?? 0,
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (disabled) {
              onDisabledPressed?.call();
            }
          },
          child: ElevatedButton(
            onPressed: disabled ? null : onPressed,
            style: resolvedStyle,
            child: child ??
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (leftIcon != null)
                      Padding(
                        padding: EdgeInsets.only(right: dimension.d8),
                        child: SizedBox(
                          height: finalHeight * 0.6,
                          child: leftIcon,
                        ),
                      ),
                    Flexible(
                      fit: FlexFit.tight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: buttonTextStyle ??
                              TextStyle(
                                fontSize: dimension.d16,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                    if (rightIcon != null)
                      Padding(
                        padding: EdgeInsets.only(left: dimension.d8),
                        child: SizedBox(
                          height: finalHeight * 0.6,
                          child: rightIcon,
                        ),
                      ),
                  ],
                ),
          ),
        ),
      ),
    );

    return alignment != null
        ? Align(alignment: alignment!, child: button)
        : button;
  }
}
