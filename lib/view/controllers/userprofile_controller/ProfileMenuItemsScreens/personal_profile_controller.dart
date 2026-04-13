import 'package:get/get.dart';

class ProfileMenuItemData {
  final String title;
  final String routeKey;

  const ProfileMenuItemData({required this.title, required this.routeKey});
}

class PersonalProfileController extends GetxController {
  final List<ProfileMenuItemData> menuItems = const <ProfileMenuItemData>[
    ProfileMenuItemData(title: 'Profile', routeKey: 'profile_settings'),
    ProfileMenuItemData(title: 'Messages', routeKey: 'chat'),
    ProfileMenuItemData(title: 'Favorites', routeKey: 'favorites'),
    ProfileMenuItemData(title: 'Manage Ads', routeKey: 'manage_ads'),
    ProfileMenuItemData(title: 'Settings', routeKey: 'settings'),
  ];
}
