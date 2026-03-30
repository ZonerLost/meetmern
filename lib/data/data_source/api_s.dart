import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:meetmern/data/models/chat_model.dart';
import 'package:meetmern/data/models/explore_meetup_model.dart';

class MockApi {
  static Future<Map<String, dynamic>> loadMockJson() async {
    final data = await rootBundle.loadString('assets/json/mock_meetups.json');
    final Map<String, dynamic> parsed =
        json.decode(data) as Map<String, dynamic>;
    return parsed;
  }

  static Future<List<Meetup>> fetchMeetups() async {
    final jsonMap = await loadMockJson();
    final List<dynamic>? meetupsJson = jsonMap['meetups'] as List<dynamic>?;
    if (meetupsJson == null) return <Meetup>[];

    final List<Meetup> arr = meetupsJson
        .map((e) => Meetup.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return arr;
  }

  static Future<List<Nearby>> fetchNearbyPeople() async {
    final jsonMap = await loadMockJson();
    final List<dynamic>? nearbyJson = jsonMap['nearby'] as List<dynamic>?;
    if (nearbyJson == null) return <Nearby>[];

    final List<Nearby> arr = nearbyJson
        .map((e) => Nearby.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    return arr;
  }

  static Future<List<Chat>> fetchChats() async {
    final jsonMap = await loadMockJson();
    final List<dynamic>? chatsJson = jsonMap['chats'] as List<dynamic>?;
    if (chatsJson == null) return <Chat>[];

    final List<Chat> arr = chatsJson
        .map((e) => Chat.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return arr;
  }

  static Future<List<_BlockedUserData>> fetchBlockedUsers() async {
    final nearby = await fetchNearbyPeople();

    return nearby
        .map(
          (p) => _BlockedUserData(
            name: p.name,
            subtitle: '${p.favMeetupType} • ${p.locationShort}',
            avatar: p.image,
          ),
        )
        .toList();
  }
}

class _BlockedUserData {
  final String name;
  final String subtitle;
  final String? avatar;

  const _BlockedUserData({
    required this.name,
    required this.subtitle,
    this.avatar,
  });
}
