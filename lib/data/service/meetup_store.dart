import 'package:flutter/foundation.dart';
import 'package:meetmern/data/service/api_s.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';

class MeetupStore extends ChangeNotifier {
  MeetupStore._();

  static final MeetupStore instance = MeetupStore._();

  final List<Meetup> _meetups = [];
  bool _loaded = false;

  List<Meetup> get meetups => List.unmodifiable(_meetups);

  List<Meetup> get favourites =>
      _meetups.where((m) => m.isFavorite == true).toList(growable: false);

  Meetup? byId(String id) {
    for (final meetup in _meetups) {
      if (meetup.id == id) return meetup;
    }
    return null;
  }

  Future<void> load() async {
    if (_loaded) return;

    final data = await MockApi.fetchMeetups();
    _meetups
      ..clear()
      ..addAll(data);

    _loaded = true;
    notifyListeners();
  }

  void setFavorite(String id, bool value) {
    final meetup = byId(id);
    if (meetup == null) return;

    meetup.isFavorite = value;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final meetup = byId(id);
    if (meetup == null) return;

    meetup.isFavorite = !(meetup.isFavorite ?? false);
    notifyListeners();
  }

  void setJoinRequested(String id, bool value) {
    final meetup = byId(id);
    if (meetup == null) return;

    meetup.joinRequested = value;
    notifyListeners();
  }
}
