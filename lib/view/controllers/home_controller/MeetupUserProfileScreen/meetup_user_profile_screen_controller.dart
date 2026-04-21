import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';
import 'package:meetmern/data/service/auth_service.dart';
import 'package:meetmern/data/service/meetup_service.dart';
import 'package:meetmern/data/service/meetup_store.dart';

class MeetupUserProfileController extends GetxController {
  final MeetupStore _store = MeetupStore.instance;

  Meetup? meetup;
  bool isLoading = false;

  // All profile fields from profiles table
  String ownerName = '';
  String ownerPhotoUrl = '';
  String ownerBio = '';
  String ownerLocation = '';
  String ownerGender = '';
  String ownerRelationshipStatus = '';
  String ownerReligion = '';
  String ownerEthnicity = '';
  String ownerDob = '';
  String ownerChildren = '';
  List<String> ownerLanguages = [];
  List<String> ownerInterests = [];
  List<String> ownerPassionTopics = [];

  String? get _currentUserId => AuthService.currentUser?.id;

  @override
  void onInit() {
    super.onInit();
    _store.addListener(_onStoreChanged);
  }

  @override
  void onClose() {
    _store.removeListener(_onStoreChanged);
    super.onClose();
  }

  void _onStoreChanged() => update();

  Future<void> init(Meetup initialMeetup) async {
    debugPrint(
        '[UserProfile] init — meetupId=${initialMeetup.id} userId=${initialMeetup.userId} hostName=${initialMeetup.hostName} image=${initialMeetup.image}');
    meetup = initialMeetup;
    ownerName = '';
    ownerPhotoUrl =
        initialMeetup.image.startsWith('http') ? initialMeetup.image : '';
    ownerBio = '';
    ownerLocation = '';
    ownerGender = '';
    ownerRelationshipStatus = '';
    ownerReligion = '';
    ownerEthnicity = '';
    ownerDob = '';
    ownerChildren = '';
    ownerLanguages = [];
    ownerInterests = [];
    ownerPassionTopics = [];
    isLoading = true;
    update();

    await _loadOwnerProfile(initialMeetup.userId);
  }

  Future<void> _loadOwnerProfile(String? uid) async {
    debugPrint('[UserProfile] _loadOwnerProfile — userId=$uid');
    if (uid == null) {
      debugPrint(
          '[UserProfile] _loadOwnerProfile — userId is null, falling back to hostName=${meetup?.hostName}');
      ownerName = meetup?.hostName ?? 'Host';
      isLoading = false;
      update();
      return;
    }

    try {
      final row = await MeetupService.fetchFullOwnerProfile(uid);
      debugPrint('[UserProfile] _loadOwnerProfile — raw row=$row');
      if (row != null && meetup?.userId == uid) {
        ownerName = row['name']?.toString() ?? meetup?.hostName ?? 'Host';
        ownerPhotoUrl = row['photo_url']?.toString() ?? ownerPhotoUrl;
        ownerBio = row['short_bio']?.toString() ?? '';
        ownerLocation = row['location']?.toString() ?? '';
        ownerGender = row['gender']?.toString() ?? '';
        ownerRelationshipStatus = row['relationship_status']?.toString() ?? '';
        ownerReligion = row['religion']?.toString() ?? '';
        ownerEthnicity = row['ethnicity']?.toString() ?? '';
        ownerDob = row['dob']?.toString() ?? '';
        final childrenValue = row['children'];
        if (childrenValue is bool) {
          ownerChildren = childrenValue ? 'Yes' : 'None';
        } else {
          final text = childrenValue?.toString() ?? '';
          ownerChildren = text.isEmpty ? 'None' : text;
        }
        ownerLanguages = (row['languages'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        ownerInterests = (row['interests'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        ownerPassionTopics = (row['passion_topics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        debugPrint(
            '[UserProfile] _loadOwnerProfile — resolved name=$ownerName bio=$ownerBio gender=$ownerGender location=$ownerLocation languages=$ownerLanguages interests=$ownerInterests');
      } else {
        debugPrint(
            '[UserProfile] _loadOwnerProfile — row is null or userId mismatch, falling back');
        ownerName = meetup?.hostName ?? 'Host';
      }
    } catch (e, st) {
      debugPrint('[UserProfile] _loadOwnerProfile — ERROR: $e\n$st');
      ownerName = meetup?.hostName ?? 'Host';
    }

    isLoading = false;
    update();
  }

  Meetup get currentMeetup {
    final m = meetup;
    if (m == null) throw StateError('Meetup controller is not initialized');
    return _store.byId(m.id) ?? m;
  }

  List<Meetup> get ownerMeetups {
    final m = meetup;
    if (m == null) return const <Meetup>[];
    final all =
        _store.meetups.where((item) => item.userId == m.userId).toList();
    if (all.isEmpty) return <Meetup>[m];
    return all;
  }

  Future<void> toggleFavorite() async {
    final m = meetup;
    if (m == null) return;

    final target = _store.byId(m.id) ?? m;
    final newValue = !target.isFavorite;

    _store.setFavorite(target.id, newValue); // optimistic
    target.isFavorite = newValue;
    meetup?.isFavorite = newValue;
    update();

    final uid = _currentUserId;
    if (uid == null) return;

    try {
      if (newValue) {
        await MeetupService.addFavourite(userId: uid, meetupId: target.id);
      } else {
        await MeetupService.removeFavourite(userId: uid, meetupId: target.id);
      }
    } catch (_) {
      _store.setFavorite(target.id, !newValue); // rollback
      target.isFavorite = !newValue;
      meetup?.isFavorite = !newValue;
      update();
    }
  }

  void markJoinRequested() {
    if (meetup == null) return;
    meetup!.joinRequested = true;
    _store.setJoinRequested(meetup!.id, true);
    update();
  }
}
