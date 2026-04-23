import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/view/controllers/chat_controller/user_meetup_info_screen_controller.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/screens/homescreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_dialog_widget.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

class UserMeetupInfoScreen extends StatelessWidget {
  final Meetup meetup;
  final String? chatId;
  final String? requestId;

  const UserMeetupInfoScreen({
    required this.meetup,
    this.chatId,
    this.requestId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return GetBuilder<UserMeetupInfoController>(
      initState: (_) => Get.find<UserMeetupInfoController>()
          .init(meetup, chatId: chatId, requestId: requestId),
      builder: (c) {
        Widget headerImage = meetup.image.startsWith('http')
            ? Image.network(meetup.image,
                width: double.infinity,
                height: dimension.d300.h,
                fit: BoxFit.cover)
            : Image.asset(meetup.image,
                width: double.infinity,
                height: dimension.d300.h,
                fit: BoxFit.cover);

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: appTheme.coreWhite,
          appBar: AppBar(
            backgroundColor: appTheme.blacktransparent,
            leading: SafeArea(
                child: IconButton(
                    icon: Icon(Icons.arrow_back, color: appTheme.coreWhite),
                    onPressed: () => Navigator.of(context).pop())),
            actions: [
              SafeArea(
                  child: IconButton(
                      icon: Icon(Icons.more_vert, color: appTheme.coreWhite),
                      onPressed: () {}))
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
                        Text(c.meetup?.title ?? meetup.title,
                            style: styles.titleTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.hostedByLabel,
                            style: styles.dobLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Text(meetup.hostName, style: styles.userNameTextStyle),
                        SizedBox(height: dimension.d12.h),
                        Text(strings.timeLabelText,
                            style: styles.dobLabelTextStyle),
                        SizedBox(height: dimension.d8.h),
                        Row(children: [
                          Icon(Icons.calendar_today_outlined,
                              size: dimension.d16.sp),
                          SizedBox(width: dimension.d6.w),
                          Text('${meetup.time.toLocal()}',
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
                          Expanded(
                              child: Text(meetup.location,
                                  style: styles.userNameTextStyle)),
                        ]),
                        SizedBox(height: dimension.d8.h),
                        Text(strings.distanceLabelText,
                            style: styles.dobLabelTextStyle),
                        SizedBox(height: dimension.d12.h),
                        Text('${meetup.distanceKm} km',
                            style: styles.userNameTextStyle),
                        SizedBox(height: dimension.d12.h),
                        Text(strings.meetupTypeLabelText,
                            style: styles.dobLabelTextStyle),
                        SizedBox(height: dimension.d12.h),
                        Icon(Icons.local_cafe,
                            size: dimension.d20.sp, color: appTheme.b_Primary),
                        SizedBox(height: dimension.d12.h),
                        Text(strings.meetupStatusLabelText,
                            style: styles.dobLabelTextStyle),
                        Text(c.meetupStatus, style: styles.userNameTextStyle),
                        SizedBox(height: dimension.d20.h),
                        Center(
                          child: CustomOutlinedButton(
                            buttonStyle: styles.googleButtonStyle,
                            onPressed: () => context.navigateToScreen(
                                MeetupUserProfileScreen(
                                    meetup: meetup, showRequestButton: false)),
                            text: strings.viewProfileBtn,
                          ),
                        ),
                        SizedBox(height: dimension.d10.h),
                        Center(
                          child: c.isCancelling
                              ? const CircularProgressIndicator()
                              : CustomElevatedButton(
                                  buttonStyle: styles.cancelMeetupButtonStyle,
                                  buttonTextStyle: styles.loginButtonTextStyle,
                                  onPressed: c.isConfirmed
                                      ? () => _showCancelDialog(
                                          context, c, styles, strings)
                                      : null,
                                  text: c.isConfirmed
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
      },
    );
  }

  void _showCancelDialog(BuildContext context, UserMeetupInfoController c,
      CustomButtonStyles styles, Strings strings) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CustomModalDialog(
        showLeftIconBackground: true,
        leftIconBackgroundColor: const Color(0xFFFFE6E6),
        topLeftIcon:
            Icon(Icons.delete, color: appTheme.red, size: dimension.d18.sp),
        topRightIcon: IconButton(
            icon: Icon(Icons.close, size: dimension.d20.sp),
            onPressed: () => Navigator.of(ctx).pop()),
        title: strings.cancelMeetupDialogTitle,
        subtitle: strings.cancelMeetupDialogSubtitle,
        primaryLabel: strings.cancelMeetupPrimaryLabel,
        primaryButtonStyle: styles.cancelMeetupButtonStyle,
        primaryTextStyle: styles.loginButtonTextStyle,
        primaryColor: appTheme.red,
        onPrimary: () async {
          Navigator.of(ctx).pop();
          final success = await c.cancelMeetup();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(success
                  ? strings.meetupCancelledSnack
                  : (c.errorMessage ?? 'Failed to cancel meetup.')),
            ),
          );
          if (success) Navigator.of(context).pop();
        },
        secondaryLabel: strings.closeLabel,
        secondaryButtonStyle: styles.googleButtonStyle,
        secondaryTextStyle: styles.closeButtonTextStyle,
        onSecondary: () => Navigator.of(ctx).pop(),
      ),
    );
  }
}

