import 'package:flutter/foundation.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';

class MeetupStore extends ChangeNotifier {
  MeetupStore._();

  static final MeetupStore instance = MeetupStore._();

  final List<Meetup> _meetups = [];
  bool _loaded = false;
  String? lastError;

  List<Meetup> get meetups => List.unmodifiable(_meetups);

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
      final rows = await MeetupService.fetchMeetups();
      _meetups
        ..clear()
        ..addAll(rows.map(Meetup.fromSupabase));

      // Sync favourite flags from Supabase
      final uid = AuthService.currentUser?.id;
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
    notifyListeners();
  }

  Future<void> reload() => load(forceReload: true);

  void setFavorite(String id, bool value) {
    byId(id)?.isFavorite = value;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final m = byId(id);
    if (m == null) return;
    m.isFavorite = !m.isFavorite;
    notifyListeners();
  }

  void setJoinRequested(String id, bool value) {
    byId(id)?.joinRequested = value;
    notifyListeners();
  }
}
