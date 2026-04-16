import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ProfileMenuItemsScreens/setting_controller.dart';
import 'package:meetmern/view/screens/UserProfileScreens/BlockedUser/block_user.dart';
import 'package:meetmern/view/screens/UserProfileScreens/Feedback&Support/feedback&support.dart';
import 'package:meetmern/view/screens/UserProfileScreens/LocationScreen/location_screen.dart';
import 'package:meetmern/view/screens/UserProfileScreens/NotificationScreens/notification.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_rounded_tile.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/screens/userprofilescreens/AccountPrefrences/account_prefrences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );
    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: dimension.d22.sp),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dimension.d30.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: dimension.d20.h),
              SizedBox(
                width: double.infinity,
                child: Text(
                  strings.settingsText,
                  style: customButtonandTextStyles.titleTextStyle,
                ),
              ),
              SizedBox(height: dimension.d32.h),
              CustomRoundedTile(
                title: strings.blockedUsersText,
                leadingIcon: Icons.lock_outline,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                onTap: () {
                  context.navigateToScreen(const BlockedUsersScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.accountPreferencesText,
                leadingIcon: Icons.settings,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                onTap: () {
                  context.navigateToScreen(const AccountPreferencesScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.myLocationText,
                leadingIcon: Icons.location_on_outlined,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                onTap: () {
                  context.navigateToScreen(const LocationScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.supportFeedbackText,
                leadingIcon: Icons.question_mark_outlined,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                onTap: () {
                  context.navigateToScreen(const FeedbackSupportScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.notificationsText,
                leadingIcon: Icons.notifications_active,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                onTap: () {
                  context.navigateToScreen(const NotificationsScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.shareAppText,
                leadingIcon: Icons.share,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.logoutButtonText,
                leadingIcon: Icons.logout,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                onTap: () => _showLogoutDialog(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final controller = Get.find<SettingController>();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomModalDialog(
        topRightIcon: IconButton(
          icon: Icon(Icons.close, size: dimension.d20.sp),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        topLeftIcon: Icon(Icons.logout, color: appTheme.b_Primary),
        title: strings.logoutDialogTitle,
        subtitle: strings.logoutDialogSubtitle,
        primaryLabel: strings.logoutButtonText,
        primaryButtonStyle: customButtonandTextStyles.loginButtonStyle,
        primaryTextStyle: customButtonandTextStyles.loginButtonTextStyle,
        onPrimary: () {
          Navigator.of(ctx).pop();
          controller.performLogout();
        },
        secondaryLabel: strings.cancelLabel,
        secondaryButtonStyle: customButtonandTextStyles.googleButtonStyle,
        secondaryTextStyle: customButtonandTextStyles.cancelButtonTextStyle,
        onSecondary: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}
