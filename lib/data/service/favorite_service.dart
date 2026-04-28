import 'package:get/get.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';
import 'package:meetmern/view/controllers/home_controller/ExploreScreen/explore_meetups_screen_controller.dart';
import 'package:meetmern/view/controllers/userprofile_controller/Favourites/favourites_controller.dart';

class FavoriteService {
  FavoriteService._();
  static final FavoriteService instance = FavoriteService._();

  final MeetupStore _store = MeetupStore.instance;

  /// Toggles the favorite state for [meetupId], persists to Supabase,
  /// and instantly notifies every registered controller.
  Future<void> toggle(String meetupId) async {
    final meetup = _store.byId(meetupId);
    if (meetup == null) return;

    final newValue = !meetup.isFavorite;

    // 1. Update store immediately (single source of truth).
    _store.setFavorite(meetupId, newValue);

    // 2. Notify all controllers that observe favorites.
    _notifyAll();

    // 3. Persist to Supabase.
    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    try {
      if (newValue) {
        await MeetupService.addFavourite(userId: uid, meetupId: meetupId);
      } else {
        await MeetupService.removeFavourite(userId: uid, meetupId: meetupId);
      }
    } catch (_) {
      // Revert on failure.
      _store.setFavorite(meetupId, !newValue);
      _notifyAll();
    }
  }

  /// Sets a specific favorite value (used by FavouritesController for undo).
  Future<void> set(String meetupId, bool value) async {
    final meetup = _store.byId(meetupId);
    if (meetup == null) return;
    if (meetup.isFavorite == value) return;

    _store.setFavorite(meetupId, value);
    _notifyAll();

    final uid = AuthService.currentUser?.id;
    if (uid == null) return;

    try {
      if (value) {
        await MeetupService.addFavourite(userId: uid, meetupId: meetupId);
      } else {
        await MeetupService.removeFavourite(userId: uid, meetupId: meetupId);
      }
    } catch (_) {
      _store.setFavorite(meetupId, !value);
      _notifyAll();
    }
  }

  void _notifyAll() {
    if (Get.isRegistered<ExploreController>()) {
      Get.find<ExploreController>().update();
    }
    if (Get.isRegistered<FavouritesController>()) {
      final fc = Get.find<FavouritesController>();
      fc.syncFromStore();
    }
  }
}
