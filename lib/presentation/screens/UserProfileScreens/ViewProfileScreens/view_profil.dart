import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/data_source/api_s.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/presentation/screens/HomeScreens/ViewMeetupScreen/view_meetup_screen.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/ManageAds/delete_meetup_screen.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/ViewProfileScreens/profile_details.dart';
import 'package:meetmern/utils/dimension_resource/dimension_resource.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/extensions/snackbar_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_elevated_button.dart';
import 'package:meetmern/utils/widgets/meetup_card.dart';

class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  final DimensionResource dimension = DimensionResource();
  final Strings strings = const Strings();

  String _profileName = '';
  String _email = '';
  String _bio = '';
  String _gender = '';
  String _relationship = '';
  String _dob = '';
  String _children = '';
  String _religion = '';
  List<String> _languages = [];
  String _passionTopics = '';
  List<String> _interests = OnboardingMockData.interests.take(6).toList();

  List<Meetup> _allMeetups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _profileName = strings.initialProfileNameText;
    _email = strings.initialProfileEmailText;
    _bio = strings.initialProfileBioText;
    _gender = strings.initialProfileGenderText;
    _relationship = strings.initialProfileRelationshipText;
    _dob = strings.initialProfileDobText;
    _children = strings.initialProfileChildrenText;
    _religion = strings.initialProfileReligionText;
    _languages = List<String>.from(strings.initialProfileLanguages);
    _passionTopics = strings.initialProfilePassionTopicsText;
    _loadMeetups();
  }

  Future<void> _loadMeetups() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final meetups = await MockApi.fetchMeetups();
      if (!mounted) return;
      setState(() {
        _allMeetups = meetups;
      });
    } catch (e) {
      debugPrint('Failed to load meetups: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openMeetupDetails(Meetup meetup) async {
    final res = await context.navigateToScreen1<dynamic>(
      ViewMeetupDeleteScreen(meetup: meetup),
    );

    if (!mounted) return;

    if (res is Map<String, dynamic> &&
        res['action'] == 'delete' &&
        res['id'] != null) {
      final String deletedId = res['id'].toString();

      setState(() {
        _allMeetups.removeWhere((m) => m.id == deletedId);
      });

      context.showCustomSnackBar(strings.adDeletedSnackText);
    }
  }

  void _toggleFavorite(String id) {
    setState(() {
      final idx = _allMeetups.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _allMeetups[idx].isFavorite = !_allMeetups[idx].isFavorite;
      }
    });
  }

  void _openMeetup(Meetup meetup) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ViewMeetupScreen(meetup: meetup)),
    );
  }

  Future<void> _editProfile() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => ProfileDetailsScreen(
          initialName: _profileName,
          initialEmail: _email,
          initialBio: _bio,
          initialDob: _dob,
          initialGender: _gender,
          initialEthnicity: null,
          initialLanguages: _languages,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _profileName = result['name']?.toString() ?? _profileName;
        _email = result['email']?.toString() ?? _email;
        _bio = result['bio']?.toString() ?? _bio;
        _dob = result['dob']?.toString() ?? _dob;
        _gender = result['gender']?.toString() ?? _gender;
        _relationship = result['relationship']?.toString() ?? _relationship;
        _children = result['children']?.toString() ?? _children;
        _passionTopics = result['passionTopics']?.toString() ?? _passionTopics;

        final langs = result['languages'];
        if (langs is List<String>) {
          _languages = langs;
        } else if (langs is List<dynamic>) {
          _languages = langs.map((e) => e.toString()).toList();
        }

        final ints = result['interests'];
        if (ints is List<String>) {
          _interests = ints;
        } else if (ints is List<dynamic>) {
          _interests = ints.map((e) => e.toString()).toList();
        }
      });

      context.showCustomSnackBar(strings.profileUpdatedSnackText);
    }
  }

  Widget _pill(String label) => Container(
        padding: EdgeInsets.symmetric(
          horizontal: dimension.d12.w,
          vertical: dimension.d6.h,
        ),
        margin: EdgeInsets.only(
          right: dimension.d8.w,
          bottom: dimension.d8.h,
        ),
        decoration: BoxDecoration(
          color: appTheme.coreWhite,
          borderRadius: BorderRadius.circular(dimension.d18.r),
          border: Border.all(
            color: appTheme.b_Primary,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: dimension.d12.sp,
            fontWeight: FontWeight.w600,
            color: appTheme.b_Primary,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    final hostMeetups = _allMeetups
        .where(
          (m) =>
              m.hostName.toLowerCase().trim() ==
              _profileName.toLowerCase().trim(),
        )
        .toList();

    final showMeetups = hostMeetups.isNotEmpty ? hostMeetups : _allMeetups;

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMeetups,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  strings.img9,
                  width: double.infinity,
                  height: dimension.d300.h,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: EdgeInsets.all(dimension.d16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_profileName, ${strings.profileAgeText}',
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.bioLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d8.h),
                      Text(
                        _bio,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.genderLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        _gender,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.relationshipStatusLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        _relationship,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.childrenLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        _children,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.religionLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        _religion,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        strings.languagesLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        _languages.join(', '),
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.passionTopicsLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d6.h),
                      Text(
                        _passionTopics,
                        style: customButtonandTextStyles.subtitleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.interestsLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Wrap(
                        children: _interests.map((i) => _pill(i)).toList(),
                      ),
                      SizedBox(height: dimension.d12.h),
                      Text(
                        strings.meetupsLabel,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d10.h),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_allMeetups.isEmpty)
                        Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: dimension.d20.h),
                          child: Text(strings.noMeetupsAvailableText),
                        )
                      else
                        ...showMeetups.map(
                          (m) => MeetupCard(
                            meetup: m,
                            onFavorite: () => _toggleFavorite(m.id),
                            onTap: () => _openMeetupDetails(m),
                            showFavorite: false,
                          ),
                        ),
                      SizedBox(height: dimension.d20.h),
                      CustomElevatedButton(
                        onPressed: _editProfile,
                        buttonStyle: customButtonandTextStyles.loginButtonStyle,
                        text: strings.editProfileText,
                        buttonTextStyle:
                            customButtonandTextStyles.loginButtonTextStyle,
                      ),
                      SizedBox(height: dimension.d20.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
