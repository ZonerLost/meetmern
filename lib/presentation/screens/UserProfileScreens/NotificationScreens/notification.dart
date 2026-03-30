import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/extensions/snackbar_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final DimensionResource dimension = DimensionResource();
  final Strings strings = const Strings();

  bool newRequests = true;
  bool accepted = true;
  bool messages = true;
  bool favoritePosts = false;
  bool updates = true;

  void _saveDetails() {
    context.showCustomSnackBar(strings.detailsUpdatedSnackText);
    Navigator.of(context).pop();
  }

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
          icon: const Icon(
            Icons.arrow_back,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d16.w,
            vertical: dimension.d12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: dimension.d15.h),
              Text(
                strings.notificationsText,
                style: customButtonandTextStyles.titleTextStyle,
              ),
              SizedBox(height: dimension.d20.h),
              Card(
                color: appTheme.coreWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dimension.d12.r),
                  side: BorderSide(
                      color: appTheme.borderColor, width: dimension.d1),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: dimension.d6.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildSwitchTile(
                        title: strings.newMeetupRequestsText,
                        value: newRequests,
                        onChanged: (v) => setState(() => newRequests = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        title: strings.meetupAcceptedOrDeclinedText,
                        value: accepted,
                        onChanged: (v) => setState(() => accepted = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        title: strings.messagesNotificationText,
                        value: messages,
                        onChanged: (v) => setState(() => messages = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        title: strings.favoriteUserPostsText,
                        value: favoritePosts,
                        onChanged: (v) => setState(() => favoritePosts = v),
                      ),
                      _divider(),
                      _buildSwitchTile(
                        title: strings.meetupUpdatesText,
                        value: updates,
                        onChanged: (v) => setState(() => updates = v),
                      ),
                      SizedBox(height: dimension.d12.h),
                    ],
                  ),
                ),
              ),
              SizedBox(height: dimension.d24.h),
              SizedBox(
                height: dimension.d56.h,
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: _saveDetails,
                  buttonStyle: customButtonandTextStyles.loginButtonStyle,
                  text: strings.saveDetailsText,
                  buttonTextStyle:
                      customButtonandTextStyles.loginButtonTextStyle,
                ),
              ),
              SizedBox(height: dimension.d16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Divider(
        height: dimension.d1.h.h,
        thickness: dimension.d1,
        color: appTheme.borderColor,
      );

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return SwitchListTile(
      title: Text(
        title,
        style: customButtonandTextStyles.emailLabelTextStyle,
      ),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.symmetric(horizontal: dimension.d12.w),
      dense: true,
      activeColor: appTheme.coreWhite,
      activeTrackColor: appTheme.b_Primary,
      inactiveTrackColor: appTheme.borderColor,
      inactiveThumbColor: appTheme.coreWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(dimension.d20.r),
      ),
      visualDensity: const VisualDensity(vertical: -1),
    );
  }
}
