import 'package:get/get.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/view/screens/authscreens/SplashScreens/splash_screen_1.dart';
import 'package:meetmern/view/screens/authscreens/SplashScreens/splash_screen_2.dart';
import 'package:meetmern/view/screens/authscreens/loginScreen/login_screen.dart';
import 'package:meetmern/view/screens/authscreens/SignupScreen/signup_screen.dart';
import 'package:meetmern/view/screens/authscreens/ForgetPasswordScreens/forget_password_screen.dart';
import 'package:meetmern/view/screens/authscreens/ForgetPasswordScreens/setnew_password_screen.dart';
import 'package:meetmern/view/screens/authscreens/OTPScreens/otp_verify_screen.dart';
import 'package:meetmern/view/screens/onboardingscreens/OnboardingScreen/onboarding_screen.dart';
import 'package:meetmern/view/screens/chatscreens/chat_screen.dart';
import 'package:meetmern/view/screens/homescreens/ExploreScreen/explore_meetups_screen.dart';
import 'package:meetmern/view/screens/homescreens/RequestMeetupScreen/request_meetup_screen.dart';
import 'package:meetmern/view/screens/userprofilescreens/ViewProfileScreens/view_profil.dart';
import 'package:meetmern/view/screens/userprofilescreens/ViewProfileScreens/profile_details.dart';
import 'package:meetmern/view/screens/userprofilescreens/ProfileMenuItemsScreens/personal_profile.dart';
import 'package:meetmern/view/screens/userprofilescreens/ProfileMenuItemsScreens/personal_profile_setting.dart';
import 'package:meetmern/view/screens/userprofilescreens/ProfileMenuItemsScreens/setting.dart';
import 'package:meetmern/view/screens/userprofilescreens/AccountPrefrences/account_prefrences.dart';
import 'package:meetmern/view/screens/userprofilescreens/BlockedUser/block_user.dart';
import 'package:meetmern/view/screens/userprofilescreens/Favourites/favourites.dart';
import 'package:meetmern/view/screens/userprofilescreens/Feedback&Support/feedback&support.dart';
import 'package:meetmern/view/screens/userprofilescreens/LocationScreen/location_screen.dart';
import 'package:meetmern/view/screens/userprofilescreens/ManageAds/ads_screen.dart';
import 'package:meetmern/view/screens/userprofilescreens/NotificationScreens/notification.dart';

class AppRoutes {
  AppRoutes._();

  static final pages = <GetPage>[
    GetPage(name: Routes.splash1, page: () => const SplashScreen1()),
    GetPage(name: Routes.splash2, page: () => const SplashScreen2()),
    GetPage(name: Routes.login, page: () => const LoginScreen()),
    GetPage(name: Routes.signup, page: () => const SignupScreen()),
    GetPage(
        name: Routes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(
        name: Routes.resetPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: Routes.otpVerify, page: () => const VerifyOtpScreen()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: Routes.chat, page: () => const ChatScreen()),
    GetPage(name: Routes.explore, page: () => const ExploreMeetupsScreen()),
    GetPage(
        name: Routes.requestMeetup, page: () => const RequestMeetupScreen()),
    GetPage(name: Routes.viewProfile, page: () => const ViewProfileScreen()),
    GetPage(
        name: Routes.profileDetails, page: () => const ProfileDetailsScreen()),
    GetPage(
        name: Routes.personalProfile,
        page: () => const PersonalProfileScreen()),
    GetPage(
        name: Routes.personalProfileSetting,
        page: () => const ProfileSettingsScreen()),
    GetPage(name: Routes.setting, page: () => const SettingsScreen()),
    GetPage(
        name: Routes.accountPreferences,
        page: () => const AccountPreferencesScreen()),
    GetPage(name: Routes.blockedUsers, page: () => const BlockedUsersScreen()),
    GetPage(name: Routes.favourites, page: () => const FavouritesScreen()),
    GetPage(
        name: Routes.feedbackSupport,
        page: () => const FeedbackSupportScreen()),
    GetPage(name: Routes.locationScreen, page: () => const LocationScreen()),
    GetPage(name: Routes.manageAds, page: () => const ManageAds()),
    GetPage(
        name: Routes.notifications, page: () => const NotificationsScreen()),
  ];
}
