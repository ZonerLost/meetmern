import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';

class MeetupStore {
  MeetupStore._();

  static final MeetupStore instance = MeetupStore._();

  final List<Meetup> _meetups = [];
  final Set<String> _hiddenMeetupIds = {};
  bool _loaded = false;
  String? lastError;

  List<Meetup> get meetups => List.unmodifiable(_meetups);
  Set<String> get hiddenMeetupIds => Set.unmodifiable(_hiddenMeetupIds);

  List<Meetup> get favourites =>
      _meetups.where((m) => m.isFavorite).toList(growable: false);

  Meetup? byId(String id) {
    for (final m in _meetups) {
      if (m.id == id) return m;
    }
    return null;
  }

  Future<void> load({bool forceReload = false}) async {
    if (_loaded && !forceReload) return;
    lastError = null;
    try {
      final uid = AuthService.currentUser?.id;
      final results = await Future.wait([
        MeetupService.fetchMeetups(),
        if (uid != null)
          MeetupService.fetchHiddenMeetupIdsForUser(uid)
        else
          Future.value(<String>{}),
        if (uid != null)
          MeetupService.fetchBlockedUserIds(uid)
        else
          Future.value(<String>{}),
        if (uid != null)
          MeetupService.fetchBlockerIds(uid)
        else
          Future.value(<String>{}),
      ]);

      final rows = results[0] as List<Map<String, dynamic>>;
      final hiddenIds = results[1] as Set<String>;
      final blockedByMe = results[2] as Set<String>;
      final blockedMe = results[3] as Set<String>;
      // Hide meetups from anyone in either direction of a block relationship.
      final allBlockedUserIds = {...blockedByMe, ...blockedMe};

      _meetups
        ..clear()
        ..addAll(
          rows
              .map(Meetup.fromSupabase)
              .where((m) => m.userId == null || !allBlockedUserIds.contains(m.userId)),
        );

      _hiddenMeetupIds
        ..clear()
        ..addAll(hiddenIds);

      if (uid != null) {
        try {
          final favIds = await MeetupService.fetchFavouriteMeetupIds(uid);
          for (final m in _meetups) {
            m.isFavorite = favIds.contains(m.id);
          }
        } catch (_) {}
      }

      _loaded = true;
    } catch (e) {
      lastError = e.toString();
      _loaded = false;
    }
  }

  Future<void> reload() => load(forceReload: true);

  void setFavorite(String id, bool value) {
    byId(id)?.isFavorite = value;
  }

  void toggleFavorite(String id) {
    final m = byId(id);
    if (m == null) return;
    m.isFavorite = !m.isFavorite;
  }

  void setJoinRequested(String id, bool value) {
    byId(id)?.joinRequested = value;
  }

  void removeFavouritesByUser(String blockedUserId) {
    for (final m in _meetups) {
      if (m.userId == blockedUserId) m.isFavorite = false;
    }
  }
}
