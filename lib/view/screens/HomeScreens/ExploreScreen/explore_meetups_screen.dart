import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meetmern/core/widgets/custom_text_form_field.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/view/controllers/home_controller/ExploreScreen/explore_meetups_screen_controller.dart';
import 'package:meetmern/view/screens/homescreens/CreateMeetupScreen/create_meetup.dart';
import 'package:meetmern/view/screens/homescreens/FilterScreen/filter_screen.dart';
import 'package:meetmern/view/screens/homescreens/ViewMeetupScreen/view_meetup_screen.dart';
import 'package:meetmern/view/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/view/screens/UserProfileScreens/ManageAds/ads_screen.dart';
import 'package:meetmern/core/extensions/navigation_extensions.dart';
import 'package:meetmern/core/routes/route_names.dart';
import 'package:meetmern/core/constants/app_strings.dart';
import 'package:meetmern/core/theme/theme.dart';
import 'package:meetmern/core/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/core/widgets/meetup_card.dart';

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
    _controller.loadData();
  }

  Future<void> _openFilter(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterScreen(
        options: OnboardingMockData.filterOptions,
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
                  onPressed: () {},
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
        onPressed: () async {
          final Meetup? created = await Navigator.of(context)
              .push<Meetup?>(MaterialPageRoute(builder: (_) {
            return const CreateMeetupScreen(origin: 'explore');
          }));
          if (created != null) {
            context.navigateToScreen(ManageAds(initialMeetup: created));
          }
        },
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
                                  onFavorite: () =>
                                      controller.toggleFavorite(m.id),
                                  onTap: () => _openMeetup(m),
                                );
                              },
                            )
                          : _buildEmptyState(customButtonandTextStyles),
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

  Widget _buildEmptyState(CustomButtonStyles customButtonandTextStyles) {
    const strings = Strings();
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(height: dimension.d20.h),
        Center(
          child: Text(strings.noMeetupsFound,
              style: customButtonandTextStyles.dobLabelTextStyle),
        ),
      ],
    );
  }
}
