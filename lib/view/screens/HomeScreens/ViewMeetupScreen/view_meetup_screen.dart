import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/chat_controller/chat_screen_controller.dart';
import 'package:meetmern/view/controllers/home_controller/ViewMeetupScreen/view_meetup_screen_controller.dart';
import 'package:meetmern/view/screens/chatscreens/message_screen.dart';
import 'package:meetmern/view/screens/homescreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/repeat_meetup_dialog.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';

class ViewMeetupScreen extends StatefulWidget {
  final Meetup meetup;

  const ViewMeetupScreen({
    required this.meetup,
    super.key,
  });

  @override
  State<ViewMeetupScreen> createState() => _ViewMeetupScreenState();
}

class _ViewMeetupScreenState extends State<ViewMeetupScreen> {
  final ViewMeetupController _controller = Get.find<ViewMeetupController>();
  final DimensionResource dimension = DimensionResource();
  final Strings strings = const Strings();

  @override
  void initState() {
    super.initState();
    _controller.init(widget.meetup);
  }

  void _viewProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MeetupUserProfileScreen(
          meetup: _controller.currentMeetup,
        ),
      ),
    );
  }

  Future<void> _requestToJoin() async {
    if (_controller.isOwnMeetup) return;

    if (_controller.isRequested) {
      showRepeatMeetupDialog(
        context,
        _controller.currentMeetup,
        onRepeat: () {
          _controller.markRequested();
          context.showCustomSnackBar(strings.repeatRequestSent);
        },
      );
      return;
    }

    final chat = await _controller.requestToJoin();

    if (!mounted) return;

    if (chat != null) {
      context.showCustomSnackBar(strings.requestSentSnack);
      if (Get.isRegistered<ChatListController>()) {
        Get.find<ChatListController>().loadChats(showLoader: false);
      }
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MessageScreen(chat: chat),
        ),
      );
    } else if (_controller.errorMessage != null &&
        _controller.errorMessage!.isNotEmpty) {
      context.showCustomSnackBar(_controller.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;

    final customButtonAndTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );
    return GetBuilder<ViewMeetupController>(
      builder: (controller) {
        final meetup = controller.meetup ?? widget.meetup;
        final String hostPhotoUrl = controller.hostPhotoUrl;
        final String hostName = controller.hostName.isNotEmpty
            ? controller.hostName
            : (meetup.hostName.isNotEmpty ? meetup.hostName : 'Host');
        final types = meetup.type.toLowerCase() == "coffee"
            ? {"icon": Icons.coffee, "label": strings.typeCoffee}
            : meetup.type.toLowerCase() == "drink"
                ? {"icon": Icons.local_bar, "label": strings.typeDrink}
                : {"icon": Icons.restaurant, "label": strings.typeMeal};
        final Widget headerImage =
            hostPhotoUrl.isNotEmpty && hostPhotoUrl.startsWith('http')
                ? Image.network(
                    hostPhotoUrl,
                    width: double.infinity,
                    height: dimension.d300,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallbackImage(meetup.image),
                  )
                : _fallbackImage(meetup.image);

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
            // actions: [
            //   SafeArea(
            //     child: IconButton(
            //       icon: const Icon(Icons.more_vert),
            //       onPressed: () {
            //         showMenu(
            //           color: appTheme.coreWhite,
            //           context: context,
            //           position: RelativeRect.fromLTRB(
            //             dimension.d1000,
            //             dimension.d80,
            //             dimension.d10,
            //             dimension.d0,
            //           ),
            //           items: [
            //             PopupMenuItem(
            //               child: Text(strings.userProfile),
            //               onTap: () {
            //                 context.navigateToScreen(
            //                   const PersonalProfileScreen(),
            //                 );
            //               },
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
                headerImage,
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.all(dimension.d16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meetup.title,
                          style: customButtonAndTextStyles.titleTextStyle,
                        ),
                        SizedBox(height: dimension.d8.h),
                        Text(
                          strings.hostedByLabel,
                          style: customButtonAndTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d8.h),
                        controller.isProfileLoading
                            ? SizedBox(
                                height: dimension.d20,
                                width: dimension.d20,
                                child: CircularProgressIndicator(
                                  strokeWidth: dimension.d2,
                                ),
                              )
                            : Text(
                                hostName,
                                style:
                                    customButtonAndTextStyles.userNameTextStyle,
                              ),
                        SizedBox(height: dimension.d12.h),
                        Text(
                          strings.timeLabelText,
                          style: customButtonAndTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: dimension.d16,
                            ),
                            SizedBox(width: dimension.d6),
                            Expanded(
                              child: Text(
                                controller.formattedTime,
                                style:
                                    customButtonAndTextStyles.userNameTextStyle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: dimension.d8.h),
                        Text(
                          strings.locationLabelText,
                          style: customButtonAndTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: dimension.d16,
                            ),
                            SizedBox(width: dimension.d6),
                            Expanded(
                              child: Text(
                                meetup.location,
                                style:
                                    customButtonAndTextStyles.userNameTextStyle,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: dimension.d8.h),
                        Text(
                          strings.distanceLabelText,
                          style: customButtonAndTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d12.h),
                        controller.distanceText.isEmpty
                            ? Row(children: [
                                SizedBox(width: dimension.d8),
                                Text('Calculating ...',
                                    style: customButtonAndTextStyles
                                        .locationTextStyle),
                              ])
                            : Text(
                                controller.distanceText,
                                style:
                                    customButtonAndTextStyles.userNameTextStyle,
                              ),
                        SizedBox(height: dimension.d12.h),
                        Text(
                          strings.meetupTypeLabelText,
                          style: customButtonAndTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d12.h),
                        Container(
                          width: dimension.d80,
                          height: dimension.d80,
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFCFCFCF)),
                            borderRadius: BorderRadius.circular(dimension.d8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(types['icon'] as IconData,
                                  size: dimension.d28.sp,
                                  color: appTheme.b_Primary),
                              SizedBox(height: dimension.d8.h),
                              Text(types['label'] as String,
                                  style: TextStyle(fontSize: dimension.d14.sp)),
                            ],
                          ),
                        ),
                        if (meetup.description.isNotEmpty) ...[
                          SizedBox(height: dimension.d12.h),
                          Text(
                            meetup.description,
                            style: customButtonAndTextStyles.userNameTextStyle,
                          ),
                        ],
                        SizedBox(height: dimension.d12.h),
                        Text(
                          strings.meetupStatusLabelText,
                          style: customButtonAndTextStyles.dobLabelTextStyle,
                        ),
                        SizedBox(height: dimension.d4.h),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDE9FE),
                            borderRadius: BorderRadius.circular(dimension.d20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.date_range,
                                color: Color.fromARGB(255, 123, 93, 255),
                              ),
                              SizedBox(height: dimension.d4.w),
                              Text(
                                _formatStatus(meetup.status),
                                style:
                                    customButtonAndTextStyles.userNameTextStyle,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: dimension.d8.h),
                        Center(
                          child: CustomOutlinedButton(
                            buttonStyle:
                                customButtonAndTextStyles.googleButtonStyle,
                            onPressed: _viewProfile,
                            text: strings.viewProfileBtn,
                          ),
                        ),
                        SizedBox(height: dimension.d10.h),
                        if (!controller.isOwnMeetup)
                          Center(
                            child: controller.isLoading
                                ? const CircularProgressIndicator()
                                : CustomElevatedButton(
                                    buttonStyle: customButtonAndTextStyles
                                        .loginButtonStyle,
                                    buttonTextStyle: customButtonAndTextStyles
                                        .loginButtonTextStyle,
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

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'active':
        return 'Ongoing';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'closed':
        return 'Closed';
      default:
        return status.isNotEmpty
            ? '${status[0].toUpperCase()}${status.substring(1)}'
            : '';
    }
  }

  Widget _fallbackImage(String path) {
    if (path.isNotEmpty && path.startsWith('http')) {
      return Image.network(
        path,
        width: double.infinity,
        height: dimension.d300,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          'assets/images/img9.jpg',
          width: double.infinity,
          height: dimension.d300,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      path.isNotEmpty ? path : 'assets/images/img9.jpg',
      width: double.infinity,
      height: dimension.d300,
      fit: BoxFit.cover,
    );
  }
}
