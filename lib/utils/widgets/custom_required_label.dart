import 'package:flutter/material.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class RequiredLabel extends StatelessWidget {
  final String text;

  const RequiredLabel({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );
    return RichText(
      text: TextSpan(
        text: text,
        style: customButtonandTextStyles.dobLabelTextStyle,
        children: [
          TextSpan(
            text: strings.star,
            style: TextStyle(
              color: appTheme.red,
            ),
          ),
        ],
      ),
    );
  }
}
