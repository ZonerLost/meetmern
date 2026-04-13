import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/meetup_draft.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ProfileMenuItemsScreens/personal_profile.dart';
import 'package:meetmern/core/extensions/date_picker_extension.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class ReviewMeetupScreen extends StatelessWidget {
  final MeetupDraft draft;
  final String? origin;
  const ReviewMeetupScreen({required this.draft, this.origin, super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
        apppTheme: Theme.of(context), theme: customThemeData);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.blacktransparent,
        leading: SafeArea(
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: appTheme.coreWhite),
            onPressed: () => context.popScreen(),
          ),
        ),
        actions: [
          SafeArea(
            child: IconButton(
              icon: Icon(Icons.more_vert, color: appTheme.coreWhite),
              onPressed: () {
                showMenu(
                  color: appTheme.coreWhite,
                  context: context,
                  position: RelativeRect.fromLTRB(dimension.d1000,
                      dimension.d80, dimension.d10, dimension.d0),
                  items: [
                    PopupMenuItem(
                      child: Text(strings.userProfile),
                      onTap: () {
                        context.navigateToScreen(const PersonalProfileScreen());
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
        child: Column(children: [
          Image.asset(strings.img9,
              width: double.infinity,
              height: dimension.d300,
              fit: BoxFit.cover),
          Padding(
            padding: EdgeInsets.all(dimension.d16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${strings.meetMeForPrefix}${_typeLabel(draft.type)}',
                  style: customButtonandTextStyles.titleTextStyle),
              SizedBox(height: dimension.d12.h),
              Text(strings.timeLabelText,
                  style: customButtonandTextStyles.dobLabelTextStyle),
              SizedBox(height: dimension.d8.h),
              Text(
                  draft.dateTime != null
                      ? draft.dateTime!.toDateTimeRangeString()
                      : strings.notSet,
                  style: customButtonandTextStyles.dateFieldTextStyle),
              SizedBox(height: dimension.d12.h),
              SizedBox(height: dimension.d8.h),
              Text(strings.locationLabelText,
                  style: customButtonandTextStyles.dobLabelTextStyle),
              SizedBox(height: dimension.d8.h),
              Text(draft.address.isNotEmpty
                  ? draft.address
                  : strings.notProvidedLabel),
              SizedBox(height: dimension.d8.h),
              Text(strings.distanceLabelText,
                  style: customButtonandTextStyles.dobLabelTextStyle),
              SizedBox(height: dimension.d8.h),
              Text('21 ${strings.kmAwayLabel}'),
              SizedBox(height: dimension.d12.h),
              Text(strings.repetitionLabel,
                  style: customButtonandTextStyles.dobLabelTextStyle),
              SizedBox(height: dimension.d8.h),
              Text(
                  draft.repeat ? draft.repeatRule : strings.doesNotRepeatLabel),
              SizedBox(height: dimension.d12.h),
              Text(strings.meetupTypeLabelText,
                  style: customButtonandTextStyles.dobLabelTextStyle),
              SizedBox(height: dimension.d8.h),
              Wrap(children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: dimension.d12.w, vertical: dimension.d10.h),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(dimension.d12),
                      color: appTheme.infieldColor),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_typeIcon(draft.type), color: appTheme.b_Primary),
                    SizedBox(height: dimension.d8.h),
                    Text(_typeLabel(draft.type),
                        style: customButtonandTextStyles.userNameTextStyle),
                  ]),
                ),
              ]),
              SizedBox(height: dimension.d12.h),
              SizedBox(
                child: CustomOutlinedButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.savedAsDraftSnack))),
                    buttonStyle: customButtonandTextStyles.googleButtonStyle,
                    text: strings.saveAsDraftText,
                    buttonTextStyle:
                        customButtonandTextStyles.googleButtonTextStyle),
              ),
              SizedBox(height: dimension.d12.h),
              SizedBox(
                width: double.infinity,
                child: CustomElevatedButton(
                  onPressed: () {
                    final created = Meetup(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title:
                          '${strings.meetMeForPrefix}${_typeLabel(draft.type)}',
                      hostName: 'You',
                      time: draft.dateTime ?? DateTime.now(),
                      location: draft.address.isNotEmpty
                          ? draft.address
                          : strings.notProvidedLabel,
                      distanceKm: dimension.d0,
                      type: _typeLabel(draft.type),
                      status: 'Open',
                      image: strings.img9,
                      description: '',
                      icon: _defaultIconForType(draft.type),
                      languages: const <String>[],
                      interests: const <String>[],
                      isFavorite: false,
                      joinRequested: false,
                    );

                    Navigator.of(context).pop(created);
                  },
                  buttonStyle: customButtonandTextStyles.loginButtonStyle,
                  text: strings.postMeetupText,
                  buttonTextStyle:
                      customButtonandTextStyles.loginButtonTextStyle,
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  String _typeLabel(MeetupType? t) {
    switch (t) {
      case MeetupType.coffee:
        return strings.typeCoffee;
      case MeetupType.drink:
        return strings.typeDrink;
      case MeetupType.meal:
        return strings.typeMeal;
      default:
        return strings.typeCoffee;
    }
  }

  IconData _typeIcon(MeetupType? t) {
    switch (t) {
      case MeetupType.coffee:
        return Icons.coffee;
      case MeetupType.drink:
        return Icons.local_bar;
      case MeetupType.meal:
        return Icons.set_meal;
      default:
        return Icons.coffee;
    }
  }

  String _defaultIconForType(MeetupType? t) {
    switch (t) {
      case MeetupType.coffee:
        return 'assets/icons/coffe_icon.png';
      case MeetupType.drink:
        return 'assets/icons/drinks_icon.png';
      case MeetupType.meal:
        return 'assets/icons/meals_icon.png';
      default:
        return 'assets/icons/coffe_icon.png';
    }
  }
}
