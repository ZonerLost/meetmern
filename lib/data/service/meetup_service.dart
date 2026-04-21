import 'package:flutter/foundation.dart';
import 'package:meetmern/main.dart';

class MeetupService {
  MeetupService._();

  // ── Helpers ────────────────────────────────────────────────────────────────

  static String _text(dynamic value) => value?.toString().trim() ?? '';

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return const <String>[];
  }

  static Future<Map<String, dynamic>?> _fetchProfileByUserId({
    required String userId,
    required String columns,
  }) async {
    try {
      final row = await supabase
          .from('profiles')
          .select(columns)
          .eq('id', userId)
          .maybeSingle();

      return row == null ? null : Map<String, dynamic>.from(row);
    } catch (e, st) {
      debugPrint(
        '[MeetupService] _fetchProfileByUserId - failed for id=$userId: $e\n$st',
      );
      return null;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> _fetchProfilesForUserIds(
    List<String> userIds,
  ) async {
    final profileMap = <String, Map<String, dynamic>>{};
    if (userIds.isEmpty) return profileMap;

    const baseColumns =
        'id, name, photo_url, location, short_bio, languages, interests';
    const extendedColumns =
        '$baseColumns, gender, orientation, relationship_status, religion, dob';

    try {
      dynamic rows;
      try {
        rows = await supabase
            .from('profiles')
            .select(extendedColumns)
            .inFilter('id', userIds);
      } catch (_) {
        rows = await supabase
            .from('profiles')
            .select(baseColumns)
            .inFilter('id', userIds);
      }

      for (final raw in List<Map<String, dynamic>>.from(rows)) {
        final row = Map<String, dynamic>.from(raw);
        final id = _text(row['id']);
        if (id.isNotEmpty) {
          profileMap[id] = row;
        }
      }
    } catch (e, st) {
      debugPrint(
        '[MeetupService] _fetchProfilesForUserIds - failed: $e\n$st',
      );
    }

    return profileMap;
  }

  static Map<String, dynamic> _attachProfileToMeetupRow(
    Map<String, dynamic> row,
    Map<String, dynamic>? profile,
  ) {
    final profileName = _text(profile?['name']);
    final profilePhoto = _text(profile?['photo_url']);
    final profileLocation = _text(profile?['location']);
    final profileBio = _text(profile?['short_bio']);

    final rowHostName = _text(row['host_name']);
    final rowPhoto = _text(row['profile_pic_url']);

    final resolvedName = profileName.isNotEmpty
        ? profileName
        : (rowHostName.isNotEmpty ? rowHostName : 'Host');

    final resolvedPhoto = profilePhoto.isNotEmpty ? profilePhoto : rowPhoto;

    return {
      ...row,
      'host_name': resolvedName,
      'profile_pic_url': resolvedPhoto,
      'owner_profile': {
        'id': _text(profile?['id']).isNotEmpty
            ? _text(profile?['id'])
            : _text(row['user_id']),
        'name': profileName,
        'photo_url': resolvedPhoto,
        'location': profileLocation,
        'short_bio': profileBio,
        'languages': _stringList(profile?['languages']),
        'interests': _stringList(profile?['interests']),
        'gender': _text(profile?['gender']),
        'orientation': _text(profile?['orientation']),
        'relationship_status': _text(profile?['relationship_status']),
        'religion': _text(profile?['religion']),
        'dob': _text(profile?['dob']),
      },
    };
  }

  static Future<List<Map<String, dynamic>>> _enrichWithProfiles(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return rows;

    final userIds = rows
        .map((r) => _text(r['user_id']))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    debugPrint(
      '[MeetupService] _enrichWithProfiles - rows=${rows.length} userIds=$userIds',
    );

    final profileMap = await _fetchProfilesForUserIds(userIds);

    return rows.map((row) {
      final uid = _text(row['user_id']);
      final profile = uid.isNotEmpty ? profileMap[uid] : null;

      if (profile == null) {
        debugPrint(
          '[MeetupService] _enrichWithProfiles - no profile found for meetupId=${row['id']} userId=$uid',
        );
      }

      return _attachProfileToMeetupRow(
        Map<String, dynamic>.from(row),
        profile,
      );
    }).toList();
  }

  // ── Meetups ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> createMeetup({
    required String userId,
    required String type,
    required String address,
    required String date,
    required String time,
    required bool repeat,
  }) async {
    String profilePicUrl = '';

    try {
      final profile = await _fetchProfileByUserId(
        userId: userId,
        columns: 'id, photo_url',
      );
      profilePicUrl = _text(profile?['photo_url']);
    } catch (_) {}

    final payload = <String, dynamic>{
      'user_id': userId,
      'type': type,
      'address': address,
      'date': date,
      'time': time,
      'repeat': repeat,
      'status': 'open',
      if (profilePicUrl.isNotEmpty) 'profile_pic_url': profilePicUrl,
    };
    Map<String, dynamic>? inserted;
    Object? lastError;
    final candidateStatuses = <String>['open'];

    for (final status in candidateStatuses) {
      final attemptPayload = <String, dynamic>{...payload, 'status': status};
      try {
        debugPrint(
          '[MeetupService] createMeetup - inserting meetup with status=$status payload=$attemptPayload',
        );
        final row = await supabase
            .from('meetups')
            .insert(attemptPayload)
            .select('id')
            .single();
        inserted = Map<String, dynamic>.from(row);
        break;
      } catch (e, st) {
        lastError = e;
        debugPrint(
          '[MeetupService] createMeetup - insert failed for status=$status: $e\n$st',
        );
      }
    }

    if (inserted == null) {
      throw lastError ?? Exception('Failed to insert meetup');
    }

    final meetupId = inserted['id'] as String;
    final enriched = await fetchMeetupById(meetupId);

    return enriched ?? <String, dynamic>{...payload, 'id': meetupId};
  }

  static Future<List<Map<String, dynamic>>> fetchMeetups() async {
    final rows = await supabase
        .from('meetups')
        .select()
        .order('created_at', ascending: false);

    return _enrichWithProfiles(List<Map<String, dynamic>>.from(rows));
  }

  static Future<List<Map<String, dynamic>>> fetchMeetupsForUser(
    String userId,
  ) async {
    final rows = await supabase
        .from('meetups')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return _enrichWithProfiles(List<Map<String, dynamic>>.from(rows));
  }

  static Future<Map<String, dynamic>?> fetchMeetupById(String meetupId) async {
    final row = await supabase
        .from('meetups')
        .select()
        .eq('id', meetupId)
        .maybeSingle();

    if (row == null) return null;

    final enriched = await _enrichWithProfiles(
      [Map<String, dynamic>.from(row)],
    );

    return enriched.isNotEmpty ? enriched.first : null;
  }

  static Future<void> deleteMeetup(String meetupId) async {
    await supabase.from('meetups').delete().eq('id', meetupId);
  }

  // ── Owner Profile ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> fetchOwnerProfile(String userId) async {
    debugPrint('[MeetupService] fetchOwnerProfile - userId=$userId');

    final row = await _fetchProfileByUserId(
      userId: userId,
      columns: 'id, name, photo_url, location, short_bio, languages, interests',
    );

    if (row == null) {
      debugPrint(
        '[MeetupService] fetchOwnerProfile - no profile row found for id=$userId',
      );
      return null;
    }

    final normalized = <String, dynamic>{
      'id': _text(row['id']),
      'name': _text(row['name']),
      'photo_url': _text(row['photo_url']),
      'location': _text(row['location']),
      'short_bio': _text(row['short_bio']),
      'languages': _stringList(row['languages']),
      'interests': _stringList(row['interests']),
    };

    debugPrint('[MeetupService] fetchOwnerProfile - result=$normalized');
    return normalized;
  }

  static Future<Map<String, dynamic>?> fetchFullOwnerProfile(
    String userId,
  ) async {
    debugPrint('[MeetupService] fetchFullOwnerProfile - userId=$userId');

    final row = await _fetchProfileByUserId(
      userId: userId,
      columns:
          'id, name, photo_url, location, short_bio, gender, relationship_status, religion, ethnicity, languages, interests, passion_topics, children, dob',
    );

    if (row == null) {
      debugPrint(
        '[MeetupService] fetchFullOwnerProfile - no profile row found for id=$userId',
      );
      return null;
    }

    final normalized = <String, dynamic>{
      'id': _text(row['id']),
      'name': _text(row['name']),
      'photo_url': _text(row['photo_url']),
      'location': _text(row['location']),
      'short_bio': _text(row['short_bio']),
      'gender': _text(row['gender']),
      'relationship_status': _text(row['relationship_status']),
      'religion': _text(row['religion']),
      'ethnicity': _text(row['ethnicity']),
      'children': row['children'],
      'dob': _text(row['dob']),
      'languages': _stringList(row['languages']),
      'interests': _stringList(row['interests']),
      'passion_topics': _stringList(row['passion_topics']),
    };

    debugPrint(
      '[MeetupService] fetchFullOwnerProfile - result=$normalized',
    );
    return normalized;
  }

  // ── Favourites ─────────────────────────────────────────────────────────────

  static Future<Set<String>> fetchFavouriteMeetupIds(String userId) async {
    final rows = await supabase
        .from('meetup_favourites')
        .select('meetup_id')
        .eq('user_id', userId);

    return List<Map<String, dynamic>>.from(rows)
        .map((r) => r['meetup_id'] as String)
        .toSet();
  }

  static Future<void> addFavourite({
    required String userId,
    required String meetupId,
  }) async {
    await supabase.from('meetup_favourites').upsert({
      'user_id': userId,
      'meetup_id': meetupId,
    });
  }

  static Future<void> removeFavourite({
    required String userId,
    required String meetupId,
  }) async {
    await supabase
        .from('meetup_favourites')
        .delete()
        .eq('user_id', userId)
        .eq('meetup_id', meetupId);
  }

  // ── Requests / Chats ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getExistingRequest({
    required String meetupId,
    required String requesterId,
  }) async {
    final row = await supabase
        .from('meetup_requests')
        .select()
        .eq('meetup_id', meetupId)
        .eq('requester_id', requesterId)
        .maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }

  static Future<Map<String, dynamic>> sendMeetupRequest({
    required String meetupId,
    required String meetupOwnerId,
    required String requesterId,
  }) async {
    final existing = await getExistingRequest(
      meetupId: meetupId,
      requesterId: requesterId,
    );

    if (existing != null) {
      final existingChatId = _text(existing['chat_id']);
      if (existingChatId.isNotEmpty) {
        final existingChat = await getChatById(existingChatId);
        if (existingChat != null) {
          return existingChat;
        }
      }
    }

    final requestRow = await supabase
        .from('meetup_requests')
        .insert({
          'meetup_id': meetupId,
          'meetup_owner_id': meetupOwnerId,
          'requester_id': requesterId,
          'status': 'pending',
        })
        .select()
        .single();

    final requestId = requestRow['id'] as String;

    final chatRow = await supabase
        .from('chats')
        .insert({
          'meetup_id': meetupId,
          'meetup_request_id': requestId,
          'user_one': meetupOwnerId,
          'user_two': requesterId,
          'chat_type': 'meetup',
          'status': 'pending',
        })
        .select()
        .single();

    final chatId = chatRow['id'] as String;

    await supabase
        .from('meetup_requests')
        .update({'chat_id': chatId}).eq('id', requestId);

    await supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': requesterId,
      'message_type': 'meetup_request',
      'text': 'sent you a meetup request',
      'request_status': 'pending',
      'meetup_id': meetupId,
      'meetup_request_id': requestId,
    });

    return Map<String, dynamic>.from(chatRow);
  }

  static Future<List<Map<String, dynamic>>> fetchChatsForUser(
    String userId,
  ) async {
    final response = await supabase
        .from('chats')
        .select()
        .or('user_one.eq.$userId,user_two.eq.$userId')
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Map<String, dynamic>?> getChatById(String chatId) async {
    final row =
        await supabase.from('chats').select().eq('id', chatId).maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> fetchMessages(String chatId) async {
    final response = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> sendTextMessage({
    required String chatId,
    required String senderId,
    required String text,
    required String chatStatus,
  }) async {
    if (chatStatus != 'accepted') return;

    await supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': senderId,
      'message_type': 'text',
      'text': text,
    });

    await supabase.from('chats').update({
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
  }

  // ── Accept / Reject ────────────────────────────────────────────────────────

  static Future<void> acceptRequest({
    required String requestId,
    required String chatId,
    required String requestMessageId,
  }) async {
    await supabase
        .from('meetup_requests')
        .update({'status': 'accepted'}).eq('id', requestId);

    await supabase
        .from('chats')
        .update({'status': 'accepted'}).eq('id', chatId);

    await supabase
        .from('messages')
        .update({'request_status': 'accepted'}).eq('id', requestMessageId);
  }

  static Future<void> rejectRequest({
    required String requestId,
    required String chatId,
    required String requestMessageId,
  }) async {
    await supabase
        .from('meetup_requests')
        .update({'status': 'rejected'}).eq('id', requestId);

    await supabase
        .from('chats')
        .update({'status': 'rejected'}).eq('id', chatId);

    await supabase
        .from('messages')
        .update({'request_status': 'rejected'}).eq('id', requestMessageId);
  }

  static Future<Map<String, dynamic>?> getRequestForChat(String chatId) async {
    final row = await supabase
        .from('meetup_requests')
        .select()
        .eq('chat_id', chatId)
        .maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }

  static Future<Map<String, dynamic>?> getRequestMessage(String chatId) async {
    final row = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('message_type', 'meetup_request')
        .maybeSingle();

    return row == null ? null : Map<String, dynamic>.from(row);
  }
}
