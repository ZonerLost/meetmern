import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/meetup_draft.dart';
import 'package:meetmern/core/extensions/date_picker_extension.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/custom_outlined_button.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';

class ReviewMeetupScreen extends StatefulWidget {
  final MeetupDraft draft;
  final String? origin;
  const ReviewMeetupScreen({required this.draft, this.origin, super.key});

  @override
  State<ReviewMeetupScreen> createState() => _ReviewMeetupScreenState();
}

class _ReviewMeetupScreenState extends State<ReviewMeetupScreen> {
  bool _isPosting = false;

  static const Strings strings = Strings();

  String get _ownerName {
    final fromProfile = AuthService.currentProfile.value?.name?.trim() ?? '';
    if (fromProfile.isNotEmpty) return fromProfile;

    final email = AuthService.currentUser?.email?.trim() ?? '';
    if (email.contains('@')) return email.split('@').first;

    return 'You';
  }

  String get _ownerPhotoUrl {
    return AuthService.currentProfile.value?.photoUrl?.trim() ?? '';
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

  Widget _buildHeaderImage() {
    final url = _ownerPhotoUrl;
    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        width: double.infinity,
        height: dimension.d300,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          strings.img9,
          width: double.infinity,
          height: dimension.d300,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      strings.img9,
      width: double.infinity,
      height: dimension.d300,
      fit: BoxFit.cover,
    );
  }

  Future<void> _postMeetup(BuildContext context,
      CustomButtonStyles customButtonandTextStyles) async {
    final uid = AuthService.currentUser?.id;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in.')));
      return;
    }

    setState(() => _isPosting = true);

    try {
      final draft = widget.draft;
      final typeLabel = _typeLabel(draft.type);
      final dateStr = draft.date != null
          ? '${draft.date!.year}-${draft.date!.month.toString().padLeft(2, '0')}-${draft.date!.day.toString().padLeft(2, '0')}'
          : DateTime.now().toIso8601String().substring(0, 10);
      final timeStr = draft.time != null
          ? '${draft.time!.hour.toString().padLeft(2, '0')}:${draft.time!.minute.toString().padLeft(2, '0')}'
          : '00:00';

      final row = await MeetupService.createMeetup(
        userId: uid,
        type: typeLabel,
        address:
            draft.address.isNotEmpty ? draft.address : strings.notProvidedLabel,
        date: dateStr,
        time: timeStr,
        repeat: draft.repeat,
      );

      // Re-fetch with profile join so hostName and image are populated
      final enrichedRow =
          await MeetupService.fetchMeetupById(row['id'] as String);
      final created = Meetup.fromSupabase(enrichedRow ?? row);
      if (context.mounted) Navigator.of(context).pop(created);
    } catch (e) {
      debugPrint('[ReviewMeetup] _postMeetup error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to post meetup: $e')));
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
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
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          _buildHeaderImage(),
          Padding(
            padding: EdgeInsets.all(dimension.d16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${strings.meetMeForPrefix}${_typeLabel(draft.type)}',
                  style: customButtonandTextStyles.titleTextStyle),
              SizedBox(height: dimension.d12.h),
              Text(strings.hostedByLabel,
                  style: customButtonandTextStyles.dobLabelTextStyle),
              SizedBox(height: dimension.d8.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _ownerName,
                      style: customButtonandTextStyles.userNameTextStyle,
                    ),
                  ),
                ],
              ),
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
                  onPressed: _isPosting
                      ? null
                      : () => _postMeetup(context, customButtonandTextStyles),
                  buttonStyle: customButtonandTextStyles.loginButtonStyle,
                  text: _isPosting ? 'Posting...' : strings.postMeetupText,
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
}
