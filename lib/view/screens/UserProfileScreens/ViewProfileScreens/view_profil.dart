import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ViewProfileScreens/view_profil_controller.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ManageAds/delete_meetup_screen.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ViewProfileScreens/profile_details.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/meetup_card.dart';

class ViewProfileScreen extends StatelessWidget {
  const ViewProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return GetBuilder<ViewProfileController>(
      builder: (controller) {
        return Scaffold(
          backgroundColor: appTheme.coreWhite,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await controller.refreshProfile();
                await controller.loadMeetups();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image header
                    _ProfileHeader(controller: controller),

                    Padding(
                      padding: EdgeInsets.all(dimension.d16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          if (controller.profileName.isNotEmpty)
                            Text(
                              controller.profileName,
                              style: styles.titleTextStyle,
                            ),

                          // Email
                          if (controller.email.isNotEmpty) ...[
                            SizedBox(height: dimension.d4.h),
                            Text(
                              controller.email,
                              style: styles.subtitleTextStyle,
                            ),
                          ],

                          SizedBox(height: dimension.d12.h),

                          // Bio
                          _Section(
                            label: strings.bioLabel,
                            value: controller.bio,
                            styles: styles,
                          ),

                          // Gender
                          _Section(
                            label: strings.genderLabel,
                            value: controller.gender,
                            styles: styles,
                          ),

                          // DOB
                          _Section(
                            label: strings.dateOfBirthLabel,
                            value: controller.dob,
                            styles: styles,
                          ),

                          // Relationship
                          _Section(
                            label: strings.relationshipStatusLabel,
                            value: controller.relationship,
                            styles: styles,
                          ),

                          // Children
                          _Section(
                            label: strings.childrenLabel,
                            value: controller.children,
                            styles: styles,
                          ),

                          // Religion
                          _Section(
                            label: strings.religionLabel,
                            value: controller.religion,
                            styles: styles,
                          ),

                          // Languages
                          if (controller.languages.isNotEmpty) ...[
                            Text(strings.languagesLabel,
                                style: styles.titleTextStyle),
                            SizedBox(height: dimension.d6.h),
                            _PillWrap(items: controller.languages),
                            SizedBox(height: dimension.d12.h),
                          ],

                          // Passion Topics
                          if (controller.passionTopics.isNotEmpty) ...[
                            Text(strings.passionTopicsLabel,
                                style: styles.titleTextStyle),
                            SizedBox(height: dimension.d6.h),
                            _PillWrap(items: controller.passionTopics),
                            SizedBox(height: dimension.d12.h),
                          ],

                          // Interests
                          if (controller.interests.isNotEmpty) ...[
                            Text(strings.interestsLabel,
                                style: styles.titleTextStyle),
                            SizedBox(height: dimension.d8.h),
                            _PillWrap(items: controller.interests),
                            SizedBox(height: dimension.d12.h),
                          ],

                          // Meetups
                          Text(strings.meetupsLabel,
                              style: styles.titleTextStyle),
                          SizedBox(height: dimension.d10.h),

                          if (controller.loading)
                            const Center(child: CircularProgressIndicator())
                          else if (controller.allMeetups.isEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: dimension.d20.h),
                              child: Text(
                                strings.noMeetupsAvailableText,
                                style: styles.subtitleTextStyle,
                              ),
                            )
                          else
                            ...controller.allMeetups.map(
                              (m) => MeetupCard(
                                meetup: m,
                                onFavorite: () =>
                                    controller.toggleFavorite(m.id),
                                onTap: () =>
                                    _openMeetupDetails(context, m, controller),
                                showFavorite: false,
                              ),
                            ),

                          SizedBox(height: dimension.d20.h),

                          // Edit Profile button
                          CustomElevatedButton(
                            onPressed: () => _editProfile(context, controller),
                            buttonStyle: styles.loginButtonStyle,
                            text: strings.editProfileText,
                            buttonTextStyle: styles.loginButtonTextStyle,
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
      },
    );
  }

  Future<void> _openMeetupDetails(
    BuildContext context,
    Meetup meetup,
    ViewProfileController controller,
  ) async {
    final res = await context.navigateToScreen1<dynamic>(
      ViewMeetupDeleteScreen(meetup: meetup),
    );
    if (res is Map<String, dynamic> &&
        res['action'] == 'delete' &&
        res['id'] != null) {
      controller.removeMeetupById(res['id'].toString());
      if (context.mounted) {
        context.showCustomSnackBar(const Strings().adDeletedSnackText);
      }
    }
  }

  Future<void> _editProfile(
    BuildContext context,
    ViewProfileController controller,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileDetailsScreen()),
    );
    // Refresh profile data after returning from edit screen
    await controller.refreshProfile();
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final ViewProfileController controller;
  const _ProfileHeader({required this.controller});

  @override
  Widget build(BuildContext context) {
    final photoUrl = controller.photoUrl;
    return SizedBox(
      width: double.infinity,
      height: 300.h,
      child: photoUrl.isNotEmpty
          ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            )
          : _placeholder(),
    );
  }

  Widget _placeholder() => Container(
        color: appTheme.borderColor,
        child: Center(
          child: Icon(Icons.person, size: 80.sp, color: appTheme.neutral_600),
        ),
      );
}

class _Section extends StatelessWidget {
  final String label;
  final String value;
  final CustomButtonStyles styles;

  const _Section({
    required this.label,
    required this.value,
    required this.styles,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: dimension.d12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: styles.titleTextStyle),
          SizedBox(height: dimension.d6.h),
          Text(value, style: styles.subtitleTextStyle),
        ],
      ),
    );
  }
}

class _PillWrap extends StatelessWidget {
  final List<String> items;
  const _PillWrap({required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: items.map((label) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d12.w,
            vertical: dimension.d6.h,
          ),
          margin:
              EdgeInsets.only(right: dimension.d8.w, bottom: dimension.d8.h),
          decoration: BoxDecoration(
            color: appTheme.coreWhite,
            borderRadius: BorderRadius.circular(dimension.d18.r),
            border: Border.all(color: appTheme.b_Primary),
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
      }).toList(),
    );
  }
}
