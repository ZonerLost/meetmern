import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/api_s.dart';

class BlockedUserItem {
  final String name;
  final String subtitle;
  final String? avatar;

  const BlockedUserItem({
    required this.name,
    required this.subtitle,
    this.avatar,
  });
}

class UserProfileScreensBlockedUserBlockUserController extends GetxController {
  List<BlockedUserItem> users = <BlockedUserItem>[];
  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    loadBlockedUsers();
  }

  Future<void> loadBlockedUsers() async {
    isLoading = true;
    update();

    try {
      final List<Nearby> nearby = await MockApi.fetchNearbyPeople();
      users = nearby
          .map(
            (item) => BlockedUserItem(
              name: item.name,
              subtitle: '${item.favMeetupType} - ${item.locationShort}',
              avatar: item.image,
            ),
          )
          .toList();
    } catch (_) {
      users = <BlockedUserItem>[];
    } finally {
      isLoading = false;
      update();
    }
  }

  void unblockAt(int index) {
    if (index < 0 || index >= users.length) return;
    users.removeAt(index);
    update();
  }
}
