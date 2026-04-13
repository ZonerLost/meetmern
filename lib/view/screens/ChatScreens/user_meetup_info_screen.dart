import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/screens/HomeScreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

class UserMeetupInfoScreen extends StatefulWidget {
  final Meetup meetup;
  const UserMeetupInfoScreen({required this.meetup, super.key});

  @override
  State<UserMeetupInfoScreen> createState() => _UserMeetupInfoScreenState();
}

class _UserMeetupInfoScreenState extends State<UserMeetupInfoScreen> {
  late Meetup meetup;
  final dimension = DimensionResource();
  final strings = const Strings();
  bool isConfirmed = true;

  late String meetupStatus;

  @override
  void initState() {
    super.initState();
    meetup = widget.meetup;
    meetupStatus = meetup.status;
    isConfirmed =
        meetupStatus.toLowerCase() != strings.cancelledLabel.toLowerCase();
  }

  void _viewProfile() {
    context.navigateToScreen(
      MeetupUserProfileScreen(
        meetup: meetup,
        showRequestButton: false,
      ),
    );
  }

  void _showCancelDialog() {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;

    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return CustomModalDialog(
          showLeftIconBackground: true,
          leftIconBackgroundColor: const Color(0xFFFFE6E6),
          topLeftIcon: Icon(
            Icons.delete,
            color: appTheme.red,
            size: dimension.d18.sp,
          ),
          topRightIcon: IconButton(
            icon: Icon(Icons.close, size: dimension.d20.sp),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          title: strings.cancelMeetupDialogTitle,
          subtitle: strings.cancelMeetupDialogSubtitle,
          primaryLabel: strings.cancelMeetupPrimaryLabel,
          primaryButtonStyle: customButtonandTextStyles.cancelMeetupButtonStyle,
          primaryTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          primaryColor: appTheme.red,
          onPrimary: () {
            Navigator.of(ctx).pop();
            setState(() {
              isConfirmed = false;
              meetupStatus = strings.cancelledLabel;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.meetupCancelledSnack)),
            );
          },
          secondaryLabel: strings.closeLabel,
          secondaryButtonStyle: customButtonandTextStyles.googleButtonStyle,
          secondaryTextStyle: customButtonandTextStyles.closeButtonTextStyle,
          onSecondary: () => Navigator.of(ctx).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    Widget headerImage;
    if (widget.meetup.image.startsWith('http')) {
      headerImage = Image.network(
        widget.meetup.image,
        width: double.infinity,
        height: dimension.d300.h,
        fit: BoxFit.cover,
      );
    } else {
      headerImage = Image.asset(
        widget.meetup.image,
        width: double.infinity,
        height: dimension.d300.h,
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.blacktransparent,
        leading: SafeArea(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: appTheme.coreWhite),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        actions: [
          SafeArea(
            child: IconButton(
              icon: Icon(Icons.more_vert, color: appTheme.coreWhite),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            headerImage,
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(dimension.d16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meetup.title,
                      style: customButtonandTextStyles.titleTextStyle,
                    ),
                    SizedBox(height: dimension.d8.h),
                    Text(
                      strings.hostedByLabel,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d8.h),
                    Text(
                      meetup.hostName,
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      strings.timeLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: dimension.d16.sp,
                        ),
                        SizedBox(width: dimension.d6.w),
                        Text(
                          '${meetup.time.toLocal()}',
                          style: customButtonandTextStyles.userNameTextStyle,
                        ),
                      ],
                    ),
                    SizedBox(height: dimension.d8.h),
                    Text(
                      strings.locationLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: dimension.d16.sp,
                        ),
                        SizedBox(width: dimension.d6.w),
                        Expanded(
                          child: Text(
                            meetup.location,
                            style: customButtonandTextStyles.userNameTextStyle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: dimension.d8.h),
                    Text(
                      strings.distanceLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      '${meetup.distanceKm} km',
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      strings.meetupTypeLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Icon(
                      Icons.local_cafe,
                      size: dimension.d20.sp,
                      color: appTheme.b_Primary,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      strings.meetupStatusLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    Text(
                      meetupStatus,
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    SizedBox(height: dimension.d20.h),
                    Center(
                      child: CustomOutlinedButton(
                        buttonStyle:
                            customButtonandTextStyles.googleButtonStyle,
                        onPressed: _viewProfile,
                        text: strings.viewProfileBtn,
                      ),
                    ),
                    SizedBox(height: dimension.d10.h),
                    Center(
                      child: CustomElevatedButton(
                        buttonStyle:
                            customButtonandTextStyles.cancelMeetupButtonStyle,
                        buttonTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                        onPressed: isConfirmed ? _showCancelDialog : null,
                        text: isConfirmed
                            ? strings.cancelMeetupPrimaryLabel
                            : strings.cancelledLabel,
                      ),
                    ),
                    SizedBox(height: dimension.d28.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
