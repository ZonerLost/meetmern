import 'package:flutter/material.dart';

class LightCodeColors {
  Color get borderColor => const Color(0xFFCFCFCF);
  Color get forgotPasswordColor => const Color(0xFFD83AF0);
  Color get accentsgreen => const Color(0xFF34C759);
  Color get infieldColor => const Color(0xFFFCFCFC);
  Color get b_Primary => const Color(0xFF7D3AF0);
  Color get orange => const Color(0xFFFE5E29);
  Color get c_Red => const Color(0xFF3A52F0);
  Color get redshade => const Color(0xffffffe6e6);

  Color get b_900 => const Color(0xFF4C1B97);
  Color get b_800 => const Color(0xFF5A1FB8);
  Color get b_700 => const Color(0xFF6C25DC);
  Color get b_600 => const Color(0xFF7D3AF0);
  Color get b_500 => const Color(0xFF8A5AF8);
  Color get b_400 => const Color(0xFFA689FC);
  Color get b_300 => const Color(0xFFA689FC);
  Color get b_200 => const Color(0xFFDDD5FF);
  Color get b_100 => const Color(0xFFEDE9FE);
  Color get b_50 => const Color(0xFFF5F3FF);
  Color get neutral_800 => const Color(0xFF1E293B);
  Color get neutral_700 => const Color(0xFF334155);
  Color get neutral_600 => const Color(0xFF475569);
  Color get neutral_500 => const Color(0xFF64748B);
  Color get neutral_400 => const Color(0xFF94A3B8);
  Color get neutral_300 => const Color(0xFFCBD5E1);
  Color get neutral_200 => const Color(0xFFE2E8F0);
  Color get neutral_100 => const Color(0xFFF1F5F9);
  Color get neutral_50 => const Color(0xFFF8FAFC);

  Color get coreWhite => const Color(0xFFFFFFFF);
  Color get black900 => const Color(0xFF090418);
  Color get black90001 => const Color(0xFF000000);
  Color get blacktransparent => const Color(0x00000000);
  Color get gray10001 => const Color(0xFFF4F4F4);
  Color get lime50 => const Color(0xFFFEF6ED);
  Color get red => const Color(0xFFFF6565);

  Color get blue100 => const Color(0xFFD3DCFB);
  Color get blue800 => const Color(0xFF2566AF);
  Color get blue => const Color(0xFF1565C0);
  Color get darkgrayish => const Color(0xFF747775);
  Color get gray600 => const Color(0xFF828282);

  Color get darkgray => const Color(0xFF535353);
}

class ColorSchemes {
  final ColorScheme lightCodeColorScheme;

  ColorSchemes()
      : lightCodeColorScheme = const ColorScheme.light(
          primaryFixed: Color(0xFF2196F3),
          secondary: Color(0xFF03A9F4),
          inversePrimary: Color(0xFF9E9E9E),
          primary: Color(0xFFFFFFFF),
          primaryContainer: Color(0xFFFAD15F),
          secondaryContainer: Color(0xFFE8761F),
          errorContainer: Color(0xFFBE4C1B),
          onError: Color(0xFF32BA7C),
          onErrorContainer: Color(0xFF09051C),
          onPrimary: Color(0xB2181818),
          onPrimaryContainer: Color(0x0FFAD15F),
        );
}

class ThemeHelper {
  final String appThemeName;

  ThemeHelper({required this.appThemeName});

  Map<String, LightCodeColors> get supportedCustomColor => {
        "lightCode": LightCodeColors(),
      };

  final Map<String, ColorScheme> supportedColorScheme = {
    "lightCode": ColorSchemes().lightCodeColorScheme,
  };

  LightCodeColors _getThemeColors() {
    return supportedCustomColor[appThemeName] ?? LightCodeColors();
  }

  ThemeData _getThemeData() {
    var colorScheme = supportedColorScheme[appThemeName] ??
        ColorSchemes().lightCodeColorScheme;

    return ThemeData(
      visualDensity: VisualDensity.standard,
      colorScheme: colorScheme,
      // textTheme: TextThemes().textTheme(colorScheme),
      scaffoldBackgroundColor: _getThemeColors().coreWhite,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: EdgeInsets.zero,
          elevation: 0,
          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(
            color: _getThemeColors().gray10001,
            width: 1,
          ),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
        ),
      ),
      dividerTheme: DividerThemeData(
        thickness: 5,
        space: 5,
        color: _getThemeColors().lime50,
      ),
    );
  }

  LightCodeColors get themeColor => _getThemeColors();
  ThemeData get themeData => _getThemeData();
}
