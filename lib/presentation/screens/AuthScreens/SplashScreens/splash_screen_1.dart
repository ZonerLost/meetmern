import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetmern/presentation/screens/AuthScreens/SplashScreens/splash_screen_2.dart';
import 'package:meetmern/utils/constants/constants.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen1> {
  final constants = Constants();
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: constants.s5), () {
      context.navigateToScreen(const SplashScreen2());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.b_Primary,
      body: Center(
        child: Image.asset(
          strings.img5,
        ),
      ),
    );
  }
}
