import 'package:get/get.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/core/routes/route_names.dart';

class SettingController extends GetxController {
  bool logoutRequested = false;

  final List<String> menuOrder = const <String>[
    'Blocked Users',
    'My Location',
    'Support and Feedback',
    'Notifications',
    'Share App',
    'Logout',
  ];

  void requestLogout() {
    logoutRequested = true;
    update();
  }

  void clearLogoutRequest() {
    logoutRequested = false;
    update();
  }

  Future<void> performLogout() async {
    await AuthService.signOut();
    Get.offAllNamed(Routes.login);
  }
}
