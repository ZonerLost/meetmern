import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class FavouritesController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  bool isLoading = true;
  List<Meetup> favourites = [];

  String? get _uid => AuthService.currentUser?.id;

  Future<void> loadFavourites() async {
    isLoading = true;
    update();

    final uid = _uid;
    if (uid == null) {
      isLoading = false;
      update();
      return;
    }

    try {
      // Ensure meetups are loaded in the store
      await _store.load();

      // Fetch the user's favourited meetup ids from Supabase
      final favIds = await MeetupService.fetchFavouriteMeetupIds(uid);

      // Sync isFavorite flag on store meetups
      for (final m in _store.meetups) {
        m.isFavorite = favIds.contains(m.id);
      }

      // Build the favourites list from the store
      favourites = _store.meetups
          .where((m) => favIds.contains(m.id))
          .toList(growable: false);
    } catch (_) {
      // Fallback to in-memory store favourites
      favourites = _store.favourites;
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Adds or removes a favourite and persists to Supabase.
  Future<void> setFavorite(String meetupId, bool value) async {
    final uid = _uid;

    // Optimistic local update
    _store.setFavorite(meetupId, value);
    favourites =
        _store.meetups.where((m) => m.isFavorite).toList(growable: false);
    update();

    if (uid == null) return;

    try {
      if (value) {
        await MeetupService.addFavourite(userId: uid, meetupId: meetupId);
      } else {
        await MeetupService.removeFavourite(userId: uid, meetupId: meetupId);
      }
    } catch (_) {
      // Revert on failure
      _store.setFavorite(meetupId, !value);
      favourites =
          _store.meetups.where((m) => m.isFavorite).toList(growable: false);
      update();
    }
  }
}
