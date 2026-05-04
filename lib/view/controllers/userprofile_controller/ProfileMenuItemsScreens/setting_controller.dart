import 'package:get/get.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/ExploreScreen/explore_meetups_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/AccountPrefrences/account_prefrences_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/BlockedUser/block_user_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/Favourites/favourites_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/ads_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/delete_meetup_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/NotificationScreens/notification_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ProfileMenuItemsScreens/personal_profile_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ProfileMenuItemsScreens/personal_profile_setting_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart';

class SettingController extends GetxController {
  bool logoutRequested = false;

  final List<String> menuOrder = const <String>[
    'Blocked Users',
    'My Location',
    'Support and Feedback',
    'Notifications',
    // 'Share App',
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
    _clearUserControllers();
    Get.offAllNamed(Routes.login);
  }

  void _clearUserControllers() {
    Get.delete<ChatListController>(force: true);
    Get.delete<ExploreController>(force: true);
    Get.delete<PersonalProfileController>(force: true);
    Get.delete<PersonalProfileSettingController>(force: true);
    Get.delete<AccountPreferencesController>(force: true);
    Get.delete<FavouritesController>(force: true);
    Get.delete<AdsScreenController>(force: true);
    Get.delete<DeleteMeetupController>(force: true);
    Get.delete<BlockedUserController>(force: true);
    Get.delete<NotificationController>(force: true);
    Get.delete<OnboardingController>(force: true);
  }
}
