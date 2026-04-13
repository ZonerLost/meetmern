import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/view/screens/ChatScreens/chat_screen.dart';
import 'package:meetmern/view/screens/UserProfileScreens/Favourites/favourites.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ManageAds/ads_screen.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ProfileMenuItemsScreens/personal_profile_setting.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ProfileMenuItemsScreens/setting.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_rounded_tile.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class PersonalProfileScreen extends StatelessWidget {
  const PersonalProfileScreen({super.key});

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
                  strings.userProfile,
                  style: customButtonandTextStyles.titleTextStyle,
                ),
              ),
              SizedBox(height: dimension.d32.h),
              CustomRoundedTile(
                title: strings.profileMenuText,
                leadingIcon: Icons.settings,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const ProfileSettingsScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.messagesText,
                leadingIcon: Icons.message_outlined,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const ChatScreen());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.favoritesText,
                leadingIcon: Icons.favorite_border,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
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
                title: strings.manageExistingAdsText,
                leadingIcon: Icons.person_pin_sharp,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const ManageAds());
                },
              ),
              SizedBox(height: dimension.d20.h),
              CustomRoundedTile(
                title: strings.settingsText,
                leadingIcon: Icons.settings,
                backgroundColor: appTheme.infieldColor,
                borderColor: appTheme.borderColor,
                borderWidth: dimension.d1.w,
                borderRadius: BorderRadius.circular(dimension.d100.r),
                iconBackgroundColor: appTheme.b_Primary,
                iconColor: appTheme.coreWhite,
                titletextStyle: customButtonandTextStyles.dobLabelTextStyle,
                trailingIcon: Icons.chevron_right,
                onTap: () {
                  context.navigateToScreen(const SettingsScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
