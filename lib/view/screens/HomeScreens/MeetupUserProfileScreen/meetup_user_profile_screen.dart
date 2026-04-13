import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/home_controller/MeetupUserProfileScreen/meetup_user_profile_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/RequestMeetupScreen/request_meetup_screen.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/view_meetup_screen.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ProfileMenuItemsScreens/personal_profile.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/meetup_card.dart';

import '../../../../core/theme/theme.dart';

class MeetupUserProfileScreen extends StatefulWidget {
  final Meetup meetup;
  final bool showRequestButton;

  const MeetupUserProfileScreen({
    required this.meetup,
    this.showRequestButton = true,
    super.key,
  });

  @override
  State<MeetupUserProfileScreen> createState() =>
      _MeetupUserProfileScreenState();
}

class _MeetupUserProfileScreenState extends State<MeetupUserProfileScreen> {
  final MeetupUserProfileController _controller = Get.find<MeetupUserProfileController>();
  final dimension = DimensionResource();
  final strings = const Strings();

  @override
  void initState() {
    super.initState();
    _controller.init(widget.meetup);
  }

  Future<void> _requestToJoin() async {
    if (!_controller.currentMeetup.joinRequested) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (_) => const RequestMeetupScreen()),
      );
      if (!mounted) return;

      if (result == true) {
        _controller.markJoinRequested();
        context.showCustomSnackBar(strings.requestSentSnack);
      }
      return;
    }

    context.showCustomSnackBar('Request already sent');
  }

  void _toggleFavorite() {
    _controller.toggleFavorite();
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return GetBuilder<MeetupUserProfileController>(
      builder: (controller) {
        final currentMeetup = _controller.meetup ?? widget.meetup;

        return Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: appTheme.coreWhite,
          appBar: AppBar(
            backgroundColor: appTheme.blacktransparent,
            elevation: dimension.d0,
            leading: SafeArea(
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: appTheme.coreWhite,
                ),
                onPressed: () {
                  context.popScreen();
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
                              const PersonalProfileScreen(),
                            );
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
                  currentMeetup.image,
                  width: double.infinity,
                  height: dimension.d300,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.all(dimension.d16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: dimension.d12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentMeetup.hostName,
                                style: customButtonandTextStyles.titleTextStyle,
                              ),
                              SizedBox(height: dimension.d4.h),
                              Text(
                                '${currentMeetup.status} ${strings.dotSeparator} ${currentMeetup.distanceKm} ${strings.kmAwayLabel}',
                                style:
                                    customButtonandTextStyles.userNameTextStyle,
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              currentMeetup.isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                              color: currentMeetup.isFavorite
                                  ? appTheme.blue
                                  : appTheme.b_300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.bioLabel,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        currentMeetup.description.isNotEmpty
                            ? currentMeetup.description
                            : strings.notProvidedLabel,
                        style: TextStyle(fontSize: dimension.d14),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.meetupTypeLabelText,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        currentMeetup.type.isNotEmpty
                            ? currentMeetup.type
                            : strings.notProvidedLabel,
                        style: TextStyle(fontSize: dimension.d14),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.statusLabel,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        currentMeetup.status.isNotEmpty
                            ? currentMeetup.status
                            : strings.notProvidedLabel,
                        style: TextStyle(fontSize: dimension.d14),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.languagesLabel,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        (currentMeetup.languages.isNotEmpty)
                            ? currentMeetup.languages.join(', ')
                            : strings.notProvidedLabel,
                        style: TextStyle(fontSize: dimension.d14),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.interestsLabel,
                        style: customButtonandTextStyles.dobLabelTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        (currentMeetup.interests.isNotEmpty)
                            ? currentMeetup.interests.join(', ')
                            : strings.notProvidedLabel,
                        style: TextStyle(fontSize: dimension.d14),
                      ),
                      SizedBox(height: dimension.d12.h),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.meetupsLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      MeetupCard(
                        meetup: currentMeetup,
                        onTap: () {
                          context.navigateToScreen(
                            ViewMeetupScreen(meetup: currentMeetup),
                          );
                        },
                      ),
                      SizedBox(height: dimension.d30.h),
                      if (widget.showRequestButton)
                        Center(
                          child: CustomElevatedButton(
                            buttonStyle:
                                customButtonandTextStyles.loginButtonStyle,
                            buttonTextStyle:
                                customButtonandTextStyles.loginButtonTextStyle,
                            onPressed: _requestToJoin,
                            text: currentMeetup.joinRequested
                                ? strings.requestedLabel
                                : strings.requestSentTitle,
                          ),
                        ),
                      if (widget.showRequestButton)
                        SizedBox(height: dimension.d30.h),
                    ],
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

