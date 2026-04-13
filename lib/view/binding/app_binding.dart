import 'package:get/get.dart';
import 'package:meetmern/view/controllers/authcontroller/ForgetPasswordScreens/forget_password_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/ForgetPasswordScreens/setnew_password_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/loginScreen/login_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/otp_verify_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/OTPScreens/verify_otp_controller_widget_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/SignupScreen/signup_screen_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/SplashScreens/splash_screen_1_controller.dart';
import 'package:meetmern/view/controllers/authcontroller/SplashScreens/splash_screen_2_controller.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_detail_screen_controller.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';
import 'package:meetmern/view/controllers/chat_controller/message_screen_controller.dart';
import 'package:meetmern/view/controllers/chat_controller/user_meetup_info_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/CreateMeetupScreen/create_meetup_controller.dart';
import 'package:meetmern/view/controllers/home_controller/CreateMeetupScreen/review_meetup_controller.dart';
import 'package:meetmern/view/controllers/home_controller/ExploreScreen/explore_meetups_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/FilterScreen/filter_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/MeetupUserProfileScreen/meetup_user_profile_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/RequestMeetupScreen/request_meetup_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/ViewMeetupScreen/repeat_meetup_dialog_controller.dart';
import 'package:meetmern/view/controllers/home_controller/ViewMeetupScreen/view_meetup_screen_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/OnboardingScreen/onboarding_screen_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/about_page_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/basics_page_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/final_page_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/interests_page_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/location_page_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/onboarding_topbar_controller.dart';
import 'package:meetmern/view/controllers/onboarding_controller/pages/photo_page_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/AccountPrefrences/account_prefrences_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/BlockedUser/block_user_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/Favourites/favourites_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/Feedback&Support/feedback&support_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/LocationScreen/location_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/ads_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/delete_meetup_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/NotificationScreens/notification_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ProfileMenuItemsScreens/personal_profile_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ProfileMenuItemsScreens/personal_profile_setting_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ProfileMenuItemsScreens/setting_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ViewProfileScreens/profile_details_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ViewProfileScreens/view_profil_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthScreensForgetPasswordScreensForgetPasswordScreenController>(
        () => AuthScreensForgetPasswordScreensForgetPasswordScreenController(),
        fenix: true);
    Get.lazyPut<AuthScreensForgetPasswordScreensSetnewPasswordScreenController>(
        () => AuthScreensForgetPasswordScreensSetnewPasswordScreenController(),
        fenix: true);
    Get.lazyPut<AuthScreensLoginScreenLoginScreenController>(
        () => AuthScreensLoginScreenLoginScreenController(),
        fenix: true);
    Get.lazyPut<AuthScreensOTPScreensOtpVerifyScreenController>(
        () => AuthScreensOTPScreensOtpVerifyScreenController(),
        fenix: true);
    Get.lazyPut<AuthScreensOTPScreensVerifyOtpControllerWidgetController>(
        () => AuthScreensOTPScreensVerifyOtpControllerWidgetController(),
        fenix: true);
    Get.lazyPut<AuthScreensSignupScreenSignupScreenController>(
        () => AuthScreensSignupScreenSignupScreenController(),
        fenix: true);
    Get.lazyPut<AuthScreensSplashScreensSplashScreen1Controller>(
        () => AuthScreensSplashScreensSplashScreen1Controller(),
        fenix: true);
    Get.lazyPut<AuthScreensSplashScreensSplashScreen2Controller>(
        () => AuthScreensSplashScreensSplashScreen2Controller(),
        fenix: true);
    Get.lazyPut<ChatScreensChatDetailScreenController>(
        () => ChatScreensChatDetailScreenController(),
        fenix: true);
    Get.lazyPut<ChatScreensChatScreenController>(
        () => ChatScreensChatScreenController(),
        fenix: true);
    Get.lazyPut<ChatScreensMessageScreenController>(
        () => ChatScreensMessageScreenController(),
        fenix: true);
    Get.lazyPut<ChatScreensUserMeetupInfoScreenController>(
        () => ChatScreensUserMeetupInfoScreenController(),
        fenix: true);
    Get.lazyPut<HomeScreensCreateMeetupScreenCreateMeetupController>(
        () => HomeScreensCreateMeetupScreenCreateMeetupController(),
        fenix: true);
    Get.lazyPut<HomeScreensCreateMeetupScreenReviewMeetupController>(
        () => HomeScreensCreateMeetupScreenReviewMeetupController(),
        fenix: true);
    Get.lazyPut<HomeScreensExploreScreenExploreMeetupsScreenController>(
        () => HomeScreensExploreScreenExploreMeetupsScreenController(),
        fenix: true);
    Get.lazyPut<HomeScreensFilterScreenFilterScreenController>(
        () => HomeScreensFilterScreenFilterScreenController(),
        fenix: true);
    Get.lazyPut<
            HomeScreensMeetupUserProfileScreenMeetupUserProfileScreenController>(
        () =>
            HomeScreensMeetupUserProfileScreenMeetupUserProfileScreenController(),
        fenix: true);
    Get.lazyPut<HomeScreensRequestMeetupScreenRequestMeetupScreenController>(
        () => HomeScreensRequestMeetupScreenRequestMeetupScreenController(),
        fenix: true);
    Get.lazyPut<HomeScreensViewMeetupScreenRepeatMeetupDialogController>(
        () => HomeScreensViewMeetupScreenRepeatMeetupDialogController(),
        fenix: true);
    Get.lazyPut<HomeScreensViewMeetupScreenViewMeetupScreenController>(
        () => HomeScreensViewMeetupScreenViewMeetupScreenController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensOnboardingScreenOnboardingScreenController>(
        () => OnboardingScreensOnboardingScreenOnboardingScreenController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesAboutPageController>(
        () => OnboardingScreensPagesAboutPageController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesBasicsPageController>(
        () => OnboardingScreensPagesBasicsPageController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesFinalPageController>(
        () => OnboardingScreensPagesFinalPageController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesInterestsPageController>(
        () => OnboardingScreensPagesInterestsPageController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesLocationPageController>(
        () => OnboardingScreensPagesLocationPageController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesOnboardingTopbarController>(
        () => OnboardingScreensPagesOnboardingTopbarController(),
        fenix: true);
    Get.lazyPut<OnboardingScreensPagesPhotoPageController>(
        () => OnboardingScreensPagesPhotoPageController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensAccountPrefrencesAccountPrefrencesController>(
        () => UserProfileScreensAccountPrefrencesAccountPrefrencesController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensBlockedUserBlockUserController>(
        () => UserProfileScreensBlockedUserBlockUserController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensFavouritesFavouritesController>(
        () => UserProfileScreensFavouritesFavouritesController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensFeedbackSupportFeedbackSupportController>(
        () => UserProfileScreensFeedbackSupportFeedbackSupportController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensLocationScreenLocationScreenController>(
        () => UserProfileScreensLocationScreenLocationScreenController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensManageAdsAdsScreenController>(
        () => UserProfileScreensManageAdsAdsScreenController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensManageAdsDeleteMeetupScreenController>(
        () => UserProfileScreensManageAdsDeleteMeetupScreenController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensNotificationScreensNotificationController>(
        () => UserProfileScreensNotificationScreensNotificationController(),
        fenix: true);
    Get.lazyPut<
            UserProfileScreensProfileMenuItemsScreensPersonalProfileController>(
        () =>
            UserProfileScreensProfileMenuItemsScreensPersonalProfileController(),
        fenix: true);
    Get.lazyPut<
            UserProfileScreensProfileMenuItemsScreensPersonalProfileSettingController>(
        () =>
            UserProfileScreensProfileMenuItemsScreensPersonalProfileSettingController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensProfileMenuItemsScreensSettingController>(
        () => UserProfileScreensProfileMenuItemsScreensSettingController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensViewProfileScreensProfileDetailsController>(
        () => UserProfileScreensViewProfileScreensProfileDetailsController(),
        fenix: true);
    Get.lazyPut<UserProfileScreensViewProfileScreensViewProfilController>(
        () => UserProfileScreensViewProfileScreensViewProfilController(),
        fenix: true);
  }
}
