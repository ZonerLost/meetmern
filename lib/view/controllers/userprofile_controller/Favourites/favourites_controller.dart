import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/favorite_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class FavouritesController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  bool isLoading = true;
  List<Meetup> favourites = [];

  String? get _uid => AuthService.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    loadFavourites();
  }
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
      await _store.load();
      // Fetch fresh fav IDs from DB and sync into store.
      final favIds = await MeetupService.fetchFavouriteMeetupIds(uid);
      for (final m in _store.meetups) {
        m.isFavorite = favIds.contains(m.id);
      }
      syncFromStore();
    } catch (_) {
      syncFromStore();
    } finally {
      isLoading = false;
      update();
    }
  }

  /// Called by FavoriteService whenever any favorite changes anywhere in the app.
  void syncFromStore() {
    favourites = _store.meetups
        .where((m) => m.isFavorite)
        .toList(growable: false);
    update();
  }

  /// Toggle favorite — delegates to FavoriteService so all screens update.
  Future<void> setFavorite(String meetupId, bool value) =>
      FavoriteService.instance.set(meetupId, value);
}
