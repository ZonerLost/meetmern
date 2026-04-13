import 'package:get/get.dart';

class UserProfileScreensProfileMenuItemsScreensSettingController
    extends GetxController {
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
}
