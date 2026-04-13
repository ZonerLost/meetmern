import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/screens/homescreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

class ViewMeetupDeleteScreen extends StatefulWidget {
  final Meetup meetup;
  const ViewMeetupDeleteScreen({required this.meetup, super.key});

  @override
  State<ViewMeetupDeleteScreen> createState() => _ViewMeetupDeleteScreenState();
}

class _ViewMeetupDeleteScreenState extends State<ViewMeetupDeleteScreen> {
  late Meetup meetup;
  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    meetup = widget.meetup;
  }

  void _viewProfile() {
    context.navigateToScreen(
      MeetupUserProfileScreen(meetup: meetup),
    );
  }

  void _confirmDelete() {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return CustomModalDialog(
          title: strings.deleteAdTitle,
          subtitle: strings.deleteAdSubtitle,
          primaryLabel: strings.deleteLabel,
          primaryButtonStyle: customButtonandTextStyles.deleteButtonStyle,
          primaryTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          secondaryLabel: strings.cancelLabel,
          secondaryButtonStyle: customButtonandTextStyles.googleButtonStyle,
          secondaryTextStyle: customButtonandTextStyles.cancelButtonTextStyle,
          onPrimary: () {
            Navigator.of(context).maybePop();
            context.popScreen({'action': 'delete', 'id': meetup.id});
          },
          onSecondary: () {
            Navigator.of(context).maybePop();
          },
          showCloseButton: true,
          centerTitle: false,
          backgroundColor: Colors.white,
        );
      },
    );
  }

  String _formatMeetupTime(DateTime dt) {
    final hour = dt.hour == 0 || dt.hour == 12 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? strings.pmText : strings.amText;
    return '${dt.day}/${dt.month}/${dt.year} ${strings.dotSeparator} $hour:$minute $period';
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
      extendBodyBehindAppBar: true,
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.blacktransparent,
        leading: SafeArea(
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: appTheme.coreWhite,
            ),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
        actions: [
          SafeArea(
            child: IconButton(
              icon: Icon(
                Icons.more_vert,
                color: appTheme.coreWhite,
              ),
              onPressed: () {
                showMenu(
                  color: appTheme.coreWhite,
                  context: context,
                  position: RelativeRect.fromLTRB(
                    dimension.d1000.w,
                    dimension.d80.h,
                    dimension.d10.w,
                    dimension.d0,
                  ),
                  items: [
                    PopupMenuItem(
                      onTap: _viewProfile,
                      child: Text(strings.userProfile),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              meetup.image,
              width: double.infinity,
              height: dimension.d300.h,
              fit: BoxFit.cover,
            ),
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
                          _formatMeetupTime(meetup.time),
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
                        Text(
                          meetup.location,
                          style: customButtonandTextStyles.userNameTextStyle,
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
                      '${meetup.distanceKm} ${strings.kmLabel}',
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      strings.meetupTypeLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      meetup.description,
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                    SizedBox(height: dimension.d12.h),
                    Text(
                      strings.meetupStatusLabelText,
                      style: customButtonandTextStyles.dobLabelTextStyle,
                    ),
                    SizedBox(height: dimension.d8.h),
                    Text(
                      meetup.status,
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                    SizedBox(height: dimension.d16.h),
                    CustomOutlinedButton(
                      buttonStyle: customButtonandTextStyles.googleButtonStyle,
                      buttonTextStyle:
                          customButtonandTextStyles.googleButtonTextStyle,
                      onPressed: _viewProfile,
                      text: strings.viewProfileBtn,
                    ),
                    SizedBox(height: dimension.d10.h),
                    CustomElevatedButton(
                      buttonStyle: customButtonandTextStyles.deleteButtonStyle,
                      buttonTextStyle:
                          customButtonandTextStyles.loginButtonTextStyle,
                      onPressed: _confirmDelete,
                      text: strings.deleteAdButton,
                    ),
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

