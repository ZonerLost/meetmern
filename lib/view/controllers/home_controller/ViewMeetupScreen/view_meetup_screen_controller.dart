import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class HomeScreensViewMeetupScreenViewMeetupScreenController
    extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  Meetup? meetup;
  bool isRequested = false;

  void init(Meetup initialMeetup) {
    meetup = initialMeetup;
    isRequested = initialMeetup.joinRequested;
    update();
  }

  Meetup get currentMeetup {
    final m = meetup;
    if (m == null) {
      throw StateError('View meetup controller is not initialized');
    }
    return m;
  }

  void markRequested() {
    if (meetup == null) return;
    isRequested = true;
    meetup!.joinRequested = true;
    _store.setJoinRequested(meetup!.id, true);
    update();
  }
}
