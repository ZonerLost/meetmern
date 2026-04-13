import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/constants/constants.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/authcontroller/SplashScreens/splash_screen_1_controller.dart';
import 'package:meetmern/view/screens/authscreens/SplashScreens/splash_screen_2.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      initState: (_) => Get.find<SplashController>().startTimer(
        () => context.navigateToScreen(const SplashScreen2()),
      ),
      builder: (_) => Scaffold(
        backgroundColor: appTheme.b_Primary,
        body: Center(child: Image.asset(strings.img5)),
      ),
    );
  }
}
