import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/api_s.dart';

class AdsScreenController extends GetxController {
  List<Meetup> meetups = <Meetup>[];
  bool isLoading = true;

  Future<void> loadMeetups({Meetup? initialMeetup}) async {
    isLoading = true;
    update();
    try {
      final List<Meetup> data = await MockApi.fetchMeetups();
      final List<Meetup> merged = List<Meetup>.from(data);
      if (initialMeetup != null) {
        merged.removeWhere((m) => m.id == initialMeetup.id);
        merged.insert(0, initialMeetup);
      }
      meetups = merged;
    } finally {
      isLoading = false;
      update();
    }
  }

  void addNewMeetup(Meetup meetup) {
    meetups.insert(0, meetup);
    update();
  }

  void removeMeetupById(String id) {
    meetups.removeWhere((m) => m.id == id);
    update();
  }

  void toggleFavorite(String id) {
    final index = meetups.indexWhere((m) => m.id == id);
    if (index < 0) return;
    meetups[index].isFavorite = !meetups[index].isFavorite;
    update();
  }
}
