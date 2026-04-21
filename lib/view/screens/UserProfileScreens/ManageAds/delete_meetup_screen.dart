import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/delete_meetup_screen_controller.dart';
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
  late final DeleteMeetupController _controller;
  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    _controller = Get.find<DeleteMeetupController>();
    _controller.init(widget.meetup);
  }

  void _viewProfile() {
    context.navigateToScreen(MeetupUserProfileScreen(meetup: widget.meetup));
  }

  void _confirmDelete() {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => CustomModalDialog(
        title: strings.deleteAdTitle,
        subtitle: strings.deleteAdSubtitle,
        primaryLabel: strings.deleteLabel,
        primaryButtonStyle: styles.deleteButtonStyle,
        primaryTextStyle: styles.loginButtonTextStyle,
        secondaryLabel: strings.cancelLabel,
        secondaryButtonStyle: styles.googleButtonStyle,
        secondaryTextStyle: styles.cancelButtonTextStyle,
        onPrimary: () async {
          Navigator.of(dialogContext).pop(); // close dialog
          final success = await _controller.deleteMeetup();
          if (!mounted) return;
          if (success) {
            // Pop the detail screen and signal the list to remove this item
            Navigator.of(context)
                .pop({'action': 'delete', 'id': widget.meetup.id});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete. Try again.')),
            );
          }
        },
        onSecondary: () => Navigator.of(dialogContext).pop(),
        showCloseButton: true,
        centerTitle: false,
        backgroundColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<DeleteMeetupController>(
      builder: (c) => Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: appTheme.coreWhite,
        appBar: AppBar(
          backgroundColor: appTheme.blacktransparent,
          leading: SafeArea(
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: appTheme.coreWhite),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          // actions: [
          //   SafeArea(
          //     child: IconButton(
          //       icon: Icon(Icons.more_vert, color: appTheme.coreWhite),
          //       onPressed: () {
          //         showMenu(
          //           color: appTheme.coreWhite,
          //           context: context,
          //           position: RelativeRect.fromLTRB(dimension.d1000.w,
          //               dimension.d80.h, dimension.d10.w, dimension.d0),
          //           items: [
          //             PopupMenuItem(
          //               onTap: _viewProfile,
          //               child: Text(strings.userProfile),
          //             ),
          //           ],
          //         );
          //       },
          //     ),
          //   ),
          // ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                widget.meetup.image,
                width: double.infinity,
                height: dimension.d400.h,
                fit: BoxFit.cover,
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.all(dimension.d16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.meetup.title, style: styles.titleTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.hostedByLabel,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(widget.meetup.hostName,
                          style: styles.userNameTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.timeLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: dimension.d16.sp),
                        SizedBox(width: dimension.d6.w),
                        Text(c.formatMeetupTime(widget.meetup.time),
                            style: styles.userNameTextStyle),
                      ]),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.locationLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Row(children: [
                        Icon(Icons.location_on_outlined,
                            size: dimension.d16.sp),
                        SizedBox(width: dimension.d6.w),
                        Text(widget.meetup.location,
                            style: styles.userNameTextStyle),
                      ]),
                      SizedBox(height: dimension.d8.h),
                      Text(strings.distanceLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text('${widget.meetup.distanceKm} ${strings.kmLabel}',
                          style: styles.userNameTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.meetupTypeLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text(widget.meetup.type, style: styles.userNameTextStyle),
                      SizedBox(height: dimension.d12.h),
                      Text(strings.meetupStatusLabelText,
                          style: styles.dobLabelTextStyle),
                      SizedBox(height: dimension.d8.h),
                      Text(widget.meetup.status,
                          style: styles.userNameTextStyle),
                      SizedBox(height: dimension.d16.h),
                      CustomOutlinedButton(
                        buttonStyle: styles.googleButtonStyle,
                        buttonTextStyle: styles.googleButtonTextStyle,
                        onPressed: _viewProfile,
                        text: strings.viewProfileBtn,
                      ),
                      SizedBox(height: dimension.d10.h),
                      CustomElevatedButton(
                        buttonStyle: styles.deleteButtonStyle,
                        buttonTextStyle: styles.loginButtonTextStyle,
                        // Show spinner while deleting, disable button
                        onPressed: c.isDeleting ? null : _confirmDelete,
                        text: c.isDeleting
                            ? 'Deleting...'
                            : strings.deleteAdButton,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
