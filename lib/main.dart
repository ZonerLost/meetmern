import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/binding/app_binding.dart';
import 'package:meetmern/view/routes/app_routes.dart';
import 'package:meetmern/view/routes/route_names.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hczijzxdgmqkcektnvxm.supabase.co',
    anonKey: 'sb_publishable_PMYj-KdaUddRFMdQCBtMqg_dHQ-gmXa',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      builder: (_, __) => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialBinding: AppBinding(),
        initialRoute: Routes.splash1,
        getPages: AppRoutes.pages,
      ),
    );
  }
}
