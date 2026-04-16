import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/authcontroller/SplashScreens/splash_screen_1_controller.dart';
import 'package:meetmern/view/routes/route_names.dart';

class SplashScreen1 extends StatelessWidget {
  const SplashScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      initState: (_) {
        final controller = Get.find<SplashController>();
        controller.startTimer(() => controller.checkAuthAndNavigate());
      },
      builder: (_) => Scaffold(
        backgroundColor: appTheme.b_Primary,
        body: Center(child: Image.asset(strings.img5)),
      ),
    );
  }
}
