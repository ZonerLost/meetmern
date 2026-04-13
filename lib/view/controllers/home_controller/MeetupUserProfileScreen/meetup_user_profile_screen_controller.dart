import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class HomeScreensMeetupUserProfileScreenMeetupUserProfileScreenController
    extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  Meetup? meetup;

  Future<void> init(Meetup initialMeetup) async {
    meetup = initialMeetup;
    update();
    await syncWithStore();
  }

  Future<void> syncWithStore() async {
    if (meetup == null) return;
    await _store.load();
    final synced = _store.byId(meetup!.id);
    if (synced != null) {
      meetup = synced;
      update();
    }
  }

  Meetup get currentMeetup {
    final m = meetup;
    if (m == null) {
      throw StateError('Meetup controller is not initialized');
    }
    return _store.byId(m.id) ?? m;
  }

  void toggleFavorite() {
    if (meetup == null) return;
    _store.toggleFavorite(meetup!.id);
    update();
  }

  void markJoinRequested() {
    if (meetup == null) return;
    meetup!.joinRequested = true;
    _store.setJoinRequested(meetup!.id, true);
    update();
  }
}
