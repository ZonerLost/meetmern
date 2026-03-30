import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meetmern/data/data_source/api_s.dart';
import 'package:meetmern/data/data_source/meetup_store.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/presentation/screens/ChatScreens/chat_screen.dart';
import 'package:meetmern/presentation/screens/HomeScreens/CreateMeetupScreen/create_meetup.dart';
import 'package:meetmern/presentation/screens/HomeScreens/FilterScreen/filter_screen.dart';
import 'package:meetmern/presentation/screens/HomeScreens/ViewMeetupScreen/view_meetup_screen.dart';
import 'package:meetmern/presentation/screens/OnboardingScreens/dummy_data/onboarding_mock_data.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/ManageAds/ads_screen.dart';
import 'package:meetmern/presentation/screens/UserProfileScreens/ProfileMenuItemsScreens/personal_profile.dart';
import 'package:meetmern/utils/extensions/navigation_extensions.dart';
import 'package:meetmern/utils/strings/strings.dart';
import 'package:meetmern/utils/theme/theme.dart';
import 'package:meetmern/utils/widgets/custom_button_style_text_style.dart';
import 'package:meetmern/utils/widgets/custom_text_form_field.dart';
import 'package:meetmern/utils/widgets/meetup_card.dart';
import 'package:meetmern/utils/widgets/near_by_card.dart';

class ExploreMeetupsScreen extends StatefulWidget {
  const ExploreMeetupsScreen({super.key});

  @override
  State<ExploreMeetupsScreen> createState() => _ExploreMeetupsScreenState();
}

class _ExploreMeetupsScreenState extends State<ExploreMeetupsScreen> {
  final MeetupStore _store = MeetupStore.instance;

  List<Nearby> _nearby = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    await _store.load();
    final nearby = await MockApi.fetchNearbyPeople();

    if (!mounted) return;
    setState(() {
      _nearby = nearby;
      _loading = false;
    });
  }

  void _openFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterScreen(
        options: OnboardingMockData.filterOptions,
      ),
    );
  }

  void _openMeetup(Meetup m) async {
    final res = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ViewMeetupScreen(meetup: m)));
    if (res == true) setState(() {});
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
                  onPressed: () {
                    context.navigateToScreen(const ChatScreen());
                  },
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
                          onTap: () {
                            context.navigateToScreen(
                                const PersonalProfileScreen());
                          },
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (_loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: dimension.d10.w,
                vertical: dimension.d12.h,
              ),
              child: AnimatedBuilder(
                animation: _store,
                builder: (context, _) {
                  final meetups = _store.meetups;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.exploreMeetupsTitle,
                        style: customButtonandTextStyles.titleTextStyle,
                      ),
                      SizedBox(height: dimension.d12.h),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => _loadData(),
                          child: meetups.isNotEmpty
                              ? ListView.separated(
                                  padding: EdgeInsets.zero,
                                  itemCount: meetups.length,
                                  separatorBuilder: (_, __) =>
                                      SizedBox(height: dimension.d12.h),
                                  itemBuilder: (context, index) {
                                    final m = meetups[index];
                                    return MeetupCard(
                                      meetup: m,
                                      onFavorite: () =>
                                          _store.toggleFavorite(m.id),
                                      onTap: () => _openMeetup(m),
                                    );
                                  },
                                )
                              : _buildFallbackNearbyList(
                                  customButtonandTextStyles,
                                ),
                        ),
                      ),
                      SizedBox(height: dimension.d12.h),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFallbackNearbyList(
    CustomButtonStyles customButtonandTextStyles,
  ) {
    const strings = Strings();

    if (_nearby.isEmpty) {
      return ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(height: dimension.d20.h),
          Center(child: Text(strings.noMeetupsFound)),
          SizedBox(height: dimension.d12.h),
          Center(
            child: Text(
              strings.peopleNearbyTitle,
              style: customButtonandTextStyles.titleTextStyle,
            ),
          ),
          SizedBox(height: dimension.d12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dimension.d16.w),
            child: Text(strings.noNearbyPeople),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: 2 + _nearby.length,
      separatorBuilder: (_, __) => SizedBox(height: dimension.d12.h),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: dimension.d4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: dimension.d6.h),
                SizedBox(height: dimension.d12.h),
                Text(
                  strings.peopleNearbyTitle,
                  style: customButtonandTextStyles.titleTextStyle,
                ),
              ],
            ),
          );
        }

        if (index == 1) return const SizedBox.shrink();

        final n = _nearby[index - 2];
        return NearbyCard(
          nearby: n,
          onRequest: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text(strings.requestSentTitle),
                content: Text("${strings.requestSentMessage} ${n.name}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(strings.ok),
                  )
                ],
              ),
            );
          },
          onTap: () {
            _openMeetup(n as dynamic);
          },
        );
      },
    );
  }
}
