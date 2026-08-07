import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/userprofile_controller/ManageAds/ads_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/create_meetup.dart';
import 'package:meetmern/view/screens/userprofilescreens/ManageAds/delete_meetup_screen.dart';
import 'package:meetmern/core/constants/dimension_resource.dart';
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
  final DimensionResource dimension = DimensionResource();
  final Strings strings = const Strings();
  late final AdsScreenController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AdsScreenController>();
    // Defer to after the current frame: loadMeetups() calls update()
    // synchronously before its first await, and calling that directly from
    // initState() can hit a GetBuilder<AdsScreenController> while the
    // framework is still mid-build (route transitions keep the previous
    // route's widgets mounted), triggering "setState() or markNeedsBuild()
    // called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadMeetups(initialMeetup: widget.initialMeetup);
    });
  }

  Future<void> _openCreateMeetup() async {
    final Meetup? created = await Navigator.of(context).push<Meetup?>(
      MaterialPageRoute(
        builder: (_) => const CreateMeetupScreen(origin: 'manage_ads'),
      ),
    );
    if (!mounted) return;
    if (created != null) {
      _controller.addNewMeetup(created);
      context.showCustomSnackBar(strings.adCreatedSnackText);
    }
  }

  Future<void> _openMeetupDetails(Meetup meetup) async {
    final res = await Navigator.of(context).push<dynamic>(
      MaterialPageRoute(
        builder: (_) => ViewMeetupDeleteScreen(meetup: meetup),
      ),
    );

    if (!mounted) return;
    if (res is Map<String, dynamic> &&
        res['action'] == 'delete' &&
        res['id'] != null) {
      _controller.removeById(res['id'].toString());
      context.showCustomSnackBar(strings.adDeletedSnackText);
    } else if (res is Map<String, dynamic> &&
        res['action'] == 'update' &&
        res['meetup'] is Meetup) {
      _controller.addNewMeetup(res['meetup'] as Meetup);
      context.showCustomSnackBar('Meetup updated');
    }
  }

  @override
  Widget build(BuildContext context) {
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;
    final styles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        backgroundColor: appTheme.coreWhite,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: appTheme.neutral_800, size: dimension.d24.sp),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: dimension.d16.w,
            vertical: dimension.d12.h,
          ),
          child: GetBuilder<AdsScreenController>(
            builder: (c) => RefreshIndicator(
              onRefresh: () => c.loadMeetups(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(bottom: dimension.d80.h),
                children: [
                  Text(
                    strings.manageAdsTitle,
                    style: styles.titleTextStyle,
                  ),
                  SizedBox(height: dimension.d15.h),
                  if (c.isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: dimension.d120.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (c.meetups.isEmpty)
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
                    ...c.meetups.map(
                      (meetup) => Padding(
                        padding: EdgeInsets.only(bottom: dimension.d12.h),
                        child: MeetupCard(
                          meetup: meetup,
                          onTap: () => _openMeetupDetails(meetup),
                          onFavorite: () {},
                          showFavorite: false,
                        ),
                      ),
                    ),
                  SizedBox(height: dimension.d16.h),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(
            dimension.d20.w, dimension.d8.h, dimension.d20.w, dimension.d12.h),
        child: SizedBox(
          height: dimension.d56.h,
          width: double.infinity,
          child: CustomElevatedButton(
            onPressed: _openCreateMeetup,
            buttonStyle: styles.loginButtonStyle,
            text: strings.addNewAdText,
            buttonTextStyle: styles.loginButtonTextStyle,
          ),
        ),
      ),
    );
  }
}
