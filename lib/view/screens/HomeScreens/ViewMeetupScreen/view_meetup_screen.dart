import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/home_controller/ViewMeetupScreen/view_meetup_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/repeat_meetup_dialog.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ProfileMenuItemsScreens/personal_profile.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

import '../../../../core/widgets/custom_text_form_field.dart';

class ViewMeetupScreen extends StatefulWidget {
  final Meetup meetup;
  const ViewMeetupScreen({required this.meetup, super.key});

  @override
  State<ViewMeetupScreen> createState() => _ViewMeetupScreenState();
}

class _ViewMeetupScreenState extends State<ViewMeetupScreen> {
  final ViewMeetupController _controller = Get.find<ViewMeetupController>();
  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    _controller.init(widget.meetup);
  }

  void _viewProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MeetupUserProfileScreen(meetup: _controller.currentMeetup),
      ),
    );
  }

  Future<void> _requestToJoin() async {
    if (!_controller.isRequested) {
      _controller.markRequested();

      context.showCustomSnackBar(strings.requestSentSnack);
      return;
    }

    showRepeatMeetupDialog(
      context,
      _controller.currentMeetup,
      onRepeat: () {
        _controller.markRequested();
        context.showCustomSnackBar(strings.repeatRequestSent);
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

    return GetBuilder<ViewMeetupController>(
      builder: (controller) {
        final meetup = controller.meetup ?? widget.meetup;

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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            actions: [
              SafeArea(
                child: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    showMenu(
                      color: appTheme.coreWhite,
                      context: context,
                      position: RelativeRect.fromLTRB(
                        dimension.d1000,
                        dimension.d80,
                        dimension.d10,
                        dimension.d0,
                      ),
                      items: [
                        PopupMenuItem(
                          child: Text(strings.userProfile),
                          onTap: () {
                            context.navigateToScreen(
                                const PersonalProfileScreen());
                          },
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
                  height: dimension.d300,
                  fit: BoxFit.cover,
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(dimension.d16),
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
                            Icon(Icons.calendar_today_outlined,
                                size: dimension.d16),
                            SizedBox(width: dimension.d6),
                            Text(
                              '${meetup.time.toLocal()}',
                              style:
                                  customButtonandTextStyles.userNameTextStyle,
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
                            Icon(Icons.location_on_outlined,
                                size: dimension.d16),
                            SizedBox(width: dimension.d6),
                            Text(
                              meetup.location,
                              style:
                                  customButtonandTextStyles.userNameTextStyle,
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
                        Text(
                          meetup.description,
                          style: customButtonandTextStyles.userNameTextStyle,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Text(
                          strings.meetupStatusLabelText,
                          style: customButtonandTextStyles.dobLabelTextStyle,
                        ),
                        Text(
                          meetup.status,
                          style: customButtonandTextStyles.userNameTextStyle,
                        ),
                        SizedBox(height: dimension.d8.h),
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
                                customButtonandTextStyles.loginButtonStyle,
                            buttonTextStyle:
                                customButtonandTextStyles.loginButtonTextStyle,
                            onPressed: _requestToJoin,
                            text: controller.isRequested
                                ? strings.requestedLabel
                                : strings.requestToJoinBtn,
                          ),
                        ),
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
}

