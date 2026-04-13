import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class ExploreController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  List<Nearby> nearby = [];
  bool loading = true;

  List<Meetup> get meetups => _store.meetups;

  Future<void> loadData() async {
    loading = true;
    update();
    await _store.load();
    nearby = await MockApi.fetchNearbyPeople();
    loading = false;
    update();
  }

  void toggleFavorite(String meetupId) {
    _store.toggleFavorite(meetupId);
    update();
  }

  void refreshUi() => update();
}
