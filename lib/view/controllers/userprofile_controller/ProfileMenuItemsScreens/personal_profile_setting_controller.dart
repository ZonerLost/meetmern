import 'package:get/get.dart';

class UserProfileSettingsSection {
  final String title;
  final List<String> items;

  const UserProfileSettingsSection({required this.title, required this.items});
}

class UserProfileScreensProfileMenuItemsScreensPersonalProfileSettingController
    extends GetxController {
  final List<UserProfileSettingsSection> sections =
      const <UserProfileSettingsSection>[
    UserProfileSettingsSection(
      title: 'Account',
      items: <String>['Account Preferences'],
    ),
    UserProfileSettingsSection(
      title: 'Meetups',
      items: <String>['Manage Existing Ads'],
    ),
    UserProfileSettingsSection(
      title: 'Activity',
      items: <String>['Favorites', 'Blocked Users', 'Notifications'],
    ),
    UserProfileSettingsSection(
      title: 'Extra',
      items: <String>['My Location', 'Support and Feedback'],
    ),
    UserProfileSettingsSection(
      title: 'Support',
      items: <String>['Share App', 'Logout'],
    ),
  ];

  bool logoutRequested = false;

  void requestLogout() {
    logoutRequested = true;
    update();
  }

  void clearLogoutRequest() {
    logoutRequested = false;
    update();
  }
}
