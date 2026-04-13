import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/binding/app_binding.dart';
import 'package:meetmern/view/screens/authscreens/SplashScreens/splash_screen_1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: AppBinding(),
        home: const SplashScreen1(),
      ),
    );
  }
}
