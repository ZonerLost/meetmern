import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meetmern/core/constants/app_dimensions.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/view/screens/AuthScreens/SplashScreens/splash_screen_2.dart';
import 'package:meetmern/core/constants/constants.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  State<SplashScreen1> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen1> {
  final constants = DimensionResource();
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 5), () {
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
