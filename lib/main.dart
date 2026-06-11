import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/services/notification_service.dart';
import 'package:meetmern/firebase_options.dart';
import 'package:meetmern/view/binding/app_binding.dart';
import 'package:meetmern/core/routes/app_routes.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hczijzxdgmqkcektnvxm.supabase.co',
    anonKey: 'sb_publishable_PMYj-KdaUddRFMdQCBtMqg_dHQ-gmXa',
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await NotificationService.instance.initialize();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase init failed in main(): $e');
    }
  }

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _didScheduleInitialNavigation = false;

  @override
  Widget build(BuildContext context) {
    if (!_didScheduleInitialNavigation) {
      _didScheduleInitialNavigation = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.instance.processPendingInitialNavigation();
      });
    }

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
