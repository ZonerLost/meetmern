import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';

class AdsScreenController extends GetxController {
  List<Meetup> meetups = <Meetup>[];
  bool isLoading = true;
  String? error;

  Future<void> loadMeetups({Meetup? initialMeetup}) async {
    isLoading = true;
    error = null;
    update();

    final uid = AuthService.currentUser?.id;
    if (uid == null) {
      isLoading = false;
      update();
      return;
    }

    try {
      final rows = await MeetupService.fetchMeetupsForUser(uid);
      final List<Meetup> loaded = rows.map(Meetup.fromSupabase).toList();

      if (initialMeetup != null) {
        loaded.removeWhere((m) => m.id == initialMeetup.id);
        loaded.insert(0, initialMeetup);
      }

      meetups = loaded;
    } catch (_) {
      error = 'Failed to load ads.';
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Deletes from Supabase via [MeetupService] then removes from local list.
  Future<bool> deleteMeetup(String id) async {
    try {
      await MeetupService.deleteMeetup(id);
      meetups.removeWhere((m) => m.id == id);
      update();
      return true;
    } catch (_) {
      return false;
    }
  }

  void removeById(String id) {
    meetups.removeWhere((m) => m.id == id);
    update();
  }

  void addNewMeetup(Meetup meetup) {
    meetups.removeWhere((m) => m.id == meetup.id);
    meetups.insert(0, meetup);
    update();
  }

  void toggleFavorite(String id) {
    final index = meetups.indexWhere((m) => m.id == id);
    if (index < 0) return;
    meetups[index].isFavorite = !meetups[index].isFavorite;
    update();
  }
}
