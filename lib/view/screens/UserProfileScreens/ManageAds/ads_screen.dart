import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/screens/HomeScreens/CreateMeetupScreen/create_meetup.dart';
import 'package:meetmern/view/screens/OnboardingScreens/pages/onboarding_topbar.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ManageAds/delete_meetup_screen.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/extensions/snackbar_extensions.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/meetup_card.dart';

class ManageAds extends StatefulWidget {
  final Meetup? initialMeetup;
  const ManageAds({super.key, this.initialMeetup});

  @override
  State<ManageAds> createState() => _ManageAdsState();
}

class _ManageAdsState extends State<ManageAds> {
  final ScrollController _scrollController = ScrollController();
  final DimensionResource dimension = DimensionResource();
  final Strings strings = const Strings();

  List<Meetup> _meetups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMeetups();
  }

  Future<void> _loadMeetups() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final data = await MockApi.fetchMeetups();
      final List<Meetup> merged = List<Meetup>.from(data);

      if (widget.initialMeetup != null) {
        merged.removeWhere((m) => m.id == widget.initialMeetup!.id);
        merged.insert(0, widget.initialMeetup!);
      }

      if (!mounted) return;
      setState(() {
        _meetups = merged;
      });
    } catch (e) {
      debugPrint('Failed to load meetups: $e');
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _onAddNewAd() async {
    final Meetup? created = await context.navigateToScreen<Meetup?>(
      const CreateMeetupScreen(origin: 'manage_ads'),
    );

    if (!mounted) return;

    if (created != null) {
      setState(() => _meetups.insert(0, created));

      await Future.delayed(const Duration(milliseconds: 50));
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      context.showCustomSnackBar(strings.meetupPostedSnackText);
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
        _meetups.removeWhere((m) => m.id == deletedId);
      });
      context.showCustomSnackBar(strings.adDeletedSnackText);
    }
  }

  void _toggleFavorite(String id) {
    setState(() {
      final idx = _meetups.indexWhere((m) => m.id == id);
      if (idx >= 0) {
        _meetups[idx].isFavorite = !_meetups[idx].isFavorite;
      }
    });
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
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appTheme.neutral_800,
            size: dimension.d24.sp,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d16.w,
            vertical: dimension.d12.h,
          ),
          child: RefreshIndicator(
            onRefresh: _loadMeetups,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                Text(
                  strings.manageAdsTitle,
                  style: customButtonandTextStyles.titleTextStyle,
                ),
                SizedBox(height: dimension.d15.h),
                if (_loading)
                  Padding(
                    padding: EdgeInsets.only(top: dimension.d120.h),
                    child: const Center(child: CircularProgressIndicator()),
                  )
                else if (_meetups.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: dimension.d120.h),
                    child: Center(
                      child: Text(
                        strings.noAdsFoundText,
                        style: TextStyle(
                          fontSize: dimension.d16.sp,
                          color: appTheme.neutral_800,
                        ),
                      ),
                    ),
                  )
                else
                  ..._meetups.map(
                    (meetup) => Padding(
                      padding: EdgeInsets.only(bottom: dimension.d12.h),
                      child: MeetupCard(
                        meetup: meetup,
                        onTap: () => _openMeetupDetails(meetup),
                        onFavorite: () => _toggleFavorite(meetup.id),
                        showFavorite: false,
                      ),
                    ),
                  ),
                SizedBox(height: dimension.d16.h),
                SizedBox(
                  height: dimension.d56.h,
                  child: CustomElevatedButton(
                    onPressed: _onAddNewAd,
                    buttonStyle: customButtonandTextStyles.deleteButtonStyle,
                    text: strings.addNewAdText,
                    buttonTextStyle:
                        customButtonandTextStyles.loginButtonTextStyle,
                  ),
                ),
                SizedBox(height: dimension.d12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
