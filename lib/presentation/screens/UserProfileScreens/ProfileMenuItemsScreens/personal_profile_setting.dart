import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/AccountPrefrences/account_prefrences.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/BlockedUser/block_user.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/Favourites/favourites.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/Feedback&Support/feedback&support.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/LocationScreen/location_screen.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/ManageAds/ads_screen.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/NotificationScreens/notification.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/ViewProfileScreens/view_profil.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_dialog_widget.dart';
import 'package:meetmern/utils/widgets/custom_rounded_tile.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: dimension.d30.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.defaultName,
                subtitle: strings.defaultEmail,
                leadingImage: strings.img9,
                trailingText: strings.viewProfileText,
                trailingTextStyle: TextStyle(
                  color: appTheme.orange,
                  fontSize: dimension.d14.sp,
                  fontWeight: FontWeight.w600,
                ),
                onTrailingTap: () {
                  context.navigateToScreen(const ViewProfileScreen());
                },
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
              ),
              SizedBox(height: dimension.d20.h),
              _sectionTitle(strings.accountText, customButtonandTextStyles),
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
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const AccountPreferencesScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              _sectionTitle(strings.meetupsText, customButtonandTextStyles),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.manageExistingAdsText,
                leadingIcon: Icons.person_pin_sharp,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const ManageAds());
                },
              ),
              SizedBox(height: dimension.d20.h),
              _sectionTitle(strings.activityText, customButtonandTextStyles),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.favoritesText,
                leadingIcon: Icons.favorite_border,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const FavouritesScreen());
                },
              ),

              SizedBox(height: dimension.d20.h),

              CustomRoundedTile(
                title: strings.blockedUsersText,
                leadingIcon: Icons.lock_outline,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const BlockedUsersScreen());
                },
              ),

              SizedBox(height: dimension.d20.h),

              CustomRoundedTile(
                title: strings.notificationsText,
                leadingIcon: Icons.notifications_active,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const NotificationsScreen());
                },
              ),

              SizedBox(height: dimension.d20.h),

              _sectionTitle(strings.extraText, customButtonandTextStyles),

              SizedBox(height: dimension.d20.h),

              CustomRoundedTile(
                title: strings.myLocationText,
                leadingIcon: Icons.location_on_outlined,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const LocationScreen());
                },
              ),

              SizedBox(height: dimension.d20.h),

              CustomRoundedTile(
                title: strings.supportFeedbackText,
                leadingIcon: Icons.question_mark_outlined,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const FeedbackSupportScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              _sectionTitle(strings.supportText, customButtonandTextStyles),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.shareAppText,
                leadingIcon: Icons.share,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
              ),
              // CustomRoundedTile(
              //   title: 'Share App',
              //   leadingIcon: Icons.share_location_outlined,
              //   backgroundColor: appTheme.infieldColor,
              //   borderColor: appTheme.borderColor,
              //   borderWidth: 1.sp,
              //   borderRadius: BorderRadius.circular(100),
              //   iconBackgroundColor: appTheme.b_Primary,
              //   iconBoxHeight: 44.h,
              //   iconBoxWidth: 44.h,
              //   iconColor: appTheme.coreWhite,
              //   textStyle: customButtonandTextStyles.dobLabelTextStyle,
              //   onTap: () async {
              //     try {
              //       // The simplest share (text + link)
              //       await Share.share(shareText, subject: shareTitle);
              //       // Optional: you can show a snackbar or analytics event
              //     } catch (e) {
              //       // handle gracefully
              //       ScaffoldMessenger.of(context).showSnackBar(
              //         const SnackBar(
              //             content: Text('Unable to share at this time')),
              //       );
              //     }
              //   },
              // ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.logoutText,
                leadingIcon: Icons.logout,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),

              SizedBox(height: dimension.d24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, CustomButtonStyles styles) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        title,
        style: styles.titleTextStyle,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return CustomModalDialog(
          title: strings.logoutDialogTitle,
          subtitle: strings.logoutDialogSubtitle,
          primaryLabel: strings.logoutButtonText,
          secondaryLabel: strings.cancelLabel,
          onPrimary: () => Navigator.pop(ctx),
          onSecondary: () => Navigator.pop(ctx),
        );
      },
    );
  }
}
