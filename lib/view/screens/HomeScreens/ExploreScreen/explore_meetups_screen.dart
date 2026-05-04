import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/home_controller/ExploreScreen/explore_meetups_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/create_meetup.dart';
import 'package:meetmern/view/screens/homescreens/FilterScreen/filter_screen.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/view_meetup_screen.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ManageAds/ads_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/custom_elevated_button.dart';
import 'package:meetmern/core/widgets/meetup_card.dart';
import 'package:meetmern/view/screens/homescreens/MeetupUserProfileScreen/meetup_user_profile_screen.dart';

class ExploreMeetupsScreen extends StatefulWidget {
  const ExploreMeetupsScreen({super.key});

  @override
  State<ExploreMeetupsScreen> createState() => _ExploreMeetupsScreenState();
}

class _ExploreMeetupsScreenState extends State<ExploreMeetupsScreen> {
  final ExploreController _controller = Get.find<ExploreController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadData();
    });
  }

  Future<void> _openFilter(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterScreen(
        options: _controller.filterOptions,
        initialValues: _controller.activeFilters,
      ),
    );
    if (result != null) {
      _controller.applyFilters(result);
    }
  }

  void _openMeetup(Meetup m) async {
    final res = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ViewMeetupScreen(meetup: m)));
    if (res == true) _controller.refreshUi();
  }

  Future<void> _openCreateMeetupFlow() async {
    final Meetup? created = await Navigator.of(context)
        .push<Meetup?>(MaterialPageRoute(builder: (_) {
      return const CreateMeetupScreen(origin: 'explore');
    }));
    if (created != null) {
      if (!mounted) return;
      context.navigateToScreen(ManageAds(initialMeetup: created));
    }
  }

  @override
  Widget build(BuildContext context) {
    const strings = Strings();
    final customThemeData =
        ThemeHelper(appThemeName: strings.lightCode).themeData;

    final customButtonandTextStyles = CustomButtonStyles(
      apppTheme: Theme.of(context),
      theme: customThemeData,
    );

    return Scaffold(
      backgroundColor: appTheme.coreWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: appTheme.coreWhite,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.location_on_outlined),
                  onPressed: () {
                    Get.toNamed(Routes.locationScreen);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _openFilter(context),
                )
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  onPressed: () => Get.toNamed(Routes.chat),
                ),
                IconButton(
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
                          onTap: () => Get.toNamed(Routes.personalProfile),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateMeetupFlow,
        shape: const CircleBorder(),
        backgroundColor: appTheme.b_Primary,
        tooltip: strings.createMeetup,
        child: Icon(Icons.add, color: appTheme.coreWhite),
      ),
      body: SafeArea(
        child: GetBuilder<ExploreController>(
          builder: (controller) {
            if (controller.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Failed to load meetups',
                        style: customButtonandTextStyles.dobLabelTextStyle),
                    SizedBox(height: dimension.d12.h),
                    ElevatedButton(
                      onPressed: _controller.loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dimension.d10.w,
                vertical: dimension.d12.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.exploreMeetupsTitle,
                    style: customButtonandTextStyles.titleTextStyle,
                  ),
                  SizedBox(height: dimension.d12.h),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async => _controller.loadData(),
                      child: controller.meetups.isNotEmpty
                          ? ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: controller.meetups.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: dimension.d12.h),
                              itemBuilder: (context, index) {
                                final m = controller.meetups[index];
                                return MeetupCard(
                                  meetup: m,
                                  locationLabel:
                                      controller.approximateLocationForFeed(m),
                                  onFavorite: () =>
                                      controller.toggleFavorite(m.id),
                                  onTap: () => _openMeetup(m),
                                );
                              },
                            )
                          : _buildEmptyState(
                              controller,
                              customButtonandTextStyles,
                            ),
                    ),
                  ),
                  SizedBox(height: dimension.d12.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    ExploreController controller,
    CustomButtonStyles customButtonandTextStyles,
  ) {
    const strings = Strings();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: dimension.d20.h),
        Center(
          child: Text('No meetup posts available right now.',
              style: customButtonandTextStyles.dobLabelTextStyle),
        ),
        SizedBox(height: dimension.d8.h),
        Center(
          child: Text(
            'Be the first to post a meetup near you.',
            textAlign: TextAlign.center,
            style: customButtonandTextStyles.locationTextStyle,
          ),
        ),
        SizedBox(height: dimension.d16.h),
        CustomElevatedButton(
          onPressed: _openCreateMeetupFlow,
          buttonStyle: customButtonandTextStyles.loginButtonStyle,
          buttonTextStyle: customButtonandTextStyles.loginButtonTextStyle,
          text: strings.createMeetup,
        ),
        if (controller.activeUsers.isNotEmpty) ...[
          SizedBox(height: dimension.d24.h),
          Text(
            'Active users',
            style: customButtonandTextStyles.dobLabelTextStyle,
          ),
          SizedBox(height: dimension.d8.h),
          ...controller.activeUsers.map(
            (user) => Card(
              color: appTheme.coreWhite,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dimension.d12.r),
                side: BorderSide(color: appTheme.borderColor, width: 1),
              ),
              margin: EdgeInsets.only(bottom: dimension.d10.h),
              child: ListTile(
                onTap: () => context.navigateToScreen(
                  MeetupUserProfileScreen(
                    meetup: user,
                    showRequestButton: true,
                  ),
                ),
                leading: CircleAvatar(
                  backgroundImage: user.image.startsWith('http')
                      ? NetworkImage(user.image)
                      : AssetImage(user.image) as ImageProvider,
                ),
                title: Text(
                  user.name,
                  style: customButtonandTextStyles.dobLabelTextStyle,
                ),
                subtitle: Text(
                  '${user.locationShort ?? user.location} - ${user.favMeetupType ?? user.type}',
                  style: customButtonandTextStyles.locationTextStyle,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
