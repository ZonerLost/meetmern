import 'package:flutter/foundation.dart';
import 'package:meetmern/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  static bool _isUniqueViolation(Object e) {
    if (e is PostgrestException) {
      return e.code == '23505';
    }
    final text = e.toString();
    return text.contains('23505') ||
        text.toLowerCase().contains('duplicate key');
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
      'status': 'active',
      if (profilePicUrl.isNotEmpty) 'profile_pic_url': profilePicUrl,
    };
    Map<String, dynamic>? inserted;

    try {
      debugPrint(
        '[MeetupService] createMeetup - inserting meetup payload=$payload',
      );
      final row =
          await supabase.from('meetups').insert(payload).select('id').single();
      inserted = Map<String, dynamic>.from(row);
    } catch (e, st) {
      debugPrint(
        '[MeetupService] createMeetup - insert failed: $e\n$st',
      );
      rethrow;
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

  // -- Moderation (Blocks / Reports / Disabled) ------------------------------

  static Future<bool> isProfileDisabled(String userId) async {
    try {
      final result = await supabase.rpc(
        'is_profile_disabled',
        params: {'p_user_id': userId},
      );
      if (result is bool) return result;
      return result?.toString().toLowerCase() == 'true';
    } catch (_) {
      try {
        final row = await supabase
            .from('profiles')
            .select('is_disabled')
            .eq('id', userId)
            .maybeSingle();
        return row?['is_disabled'] == true;
      } catch (_) {
        return false;
      }
    }
  }

  static Future<bool> areUsersBlocked({
    required String userA,
    required String userB,
  }) async {
    if (userA.isEmpty || userB.isEmpty) return false;
    if (userA == userB) return false;

    try {
      final result = await supabase.rpc(
        'is_user_blocked_between',
        params: {
          'p_user_a': userA,
          'p_user_b': userB,
        },
      );
      if (result is bool) return result;
      if (result is num) return result != 0;
      return result?.toString().toLowerCase() == 'true';
    } catch (_) {
      final rows = await supabase
          .from('user_blocks')
          .select('id')
          .or(
            'and(blocker_id.eq.$userA,blocked_id.eq.$userB),and(blocker_id.eq.$userB,blocked_id.eq.$userA)',
          )
          .limit(1);
      return rows.isNotEmpty;
    }
  }

  static Future<void> blockUser({
    required String blockerId,
    required String blockedId,
    String? reason,
  }) async {
    if (blockerId.trim().isEmpty || blockedId.trim().isEmpty) {
      throw Exception('Invalid users for block action.');
    }
    if (blockerId == blockedId) {
      throw Exception('You cannot block yourself.');
    }

    await supabase.from('user_blocks').upsert(
      {
        'blocker_id': blockerId,
        'blocked_id': blockedId,
        if ((reason ?? '').trim().isNotEmpty) 'reason': reason!.trim(),
      },
      onConflict: 'blocker_id,blocked_id',
    );
  }

  static Future<void> unblockUser({
    required String blockerId,
    required String blockedId,
  }) async {
    await supabase
        .from('user_blocks')
        .delete()
        .eq('blocker_id', blockerId)
        .eq('blocked_id', blockedId);
  }

  static Future<Set<String>> fetchBlockedUserIds(String blockerId) async {
    final rows = await supabase
        .from('user_blocks')
        .select('blocked_id')
        .eq('blocker_id', blockerId);

    return List<Map<String, dynamic>>.from(rows)
        .map((r) => _text(r['blocked_id']))
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  static Future<List<Map<String, dynamic>>> fetchBlockedUsers(
    String blockerId,
  ) async {
    final blockRows = await supabase
        .from('user_blocks')
        .select('blocked_id, created_at, reason')
        .eq('blocker_id', blockerId)
        .order('created_at', ascending: false);

    final rows = List<Map<String, dynamic>>.from(blockRows);
    final blockedIds = rows
        .map((r) => _text(r['blocked_id']))
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    if (blockedIds.isEmpty) return const <Map<String, dynamic>>[];

    final profileRows = await supabase
        .from('profiles')
        .select('id, name, photo_url')
        .inFilter('id', blockedIds);

    final profileMap = <String, Map<String, dynamic>>{};
    for (final raw in List<Map<String, dynamic>>.from(profileRows)) {
      final row = Map<String, dynamic>.from(raw);
      final id = _text(row['id']);
      if (id.isNotEmpty) {
        profileMap[id] = row;
      }
    }

    return rows.map((row) {
      final blockedId = _text(row['blocked_id']);
      final p = profileMap[blockedId];
      final name = _text(p?['name']);
      final photo = _text(p?['photo_url']);
      return <String, dynamic>{
        'user_id': blockedId,
        'name': name.isNotEmpty ? name : 'User',
        'photo_url': photo,
        'reason': _text(row['reason']),
        'created_at': _text(row['created_at']),
      };
    }).toList(growable: false);
  }

  static Future<bool> reportUser({
    required String reporterId,
    required String reportedUserId,
    required String reason,
    String? description,
  }) async {
    if (reporterId.trim().isEmpty || reportedUserId.trim().isEmpty) {
      throw Exception('Invalid users for report action.');
    }
    if (reporterId == reportedUserId) {
      throw Exception('You cannot report yourself.');
    }

    try {
      await supabase.from('user_reports').insert({
        'reporter_id': reporterId,
        'reported_user_id': reportedUserId,
        'reason': reason.trim().isEmpty ? 'other' : reason.trim(),
        'description': (description ?? '').trim(),
      });
      return true;
    } catch (e) {
      if (_isUniqueViolation(e)) {
        // Already reported by this user. Do not increment counter again.
        return false;
      }
      rethrow;
    }
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

  /// Removes all favourites the current user has for meetups owned by [ownerId].
  static Future<void> removeFavouritesByOwner({
    required String currentUserId,
    required String ownerId,
  }) async {
    // Get all meetup ids owned by the blocked user
    final rows =
        await supabase.from('meetups').select('id').eq('user_id', ownerId);

    final meetupIds = List<Map<String, dynamic>>.from(rows)
        .map((r) => r['id'] as String)
        .toList();

    if (meetupIds.isEmpty) return;

    await supabase
        .from('meetup_favourites')
        .delete()
        .eq('user_id', currentUserId)
        .inFilter('meetup_id', meetupIds);
  }

  // ── Requests / Chats ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getExistingRequest({
    required String meetupId,
    required String requesterId,
  }) async {
    // Returns the most recent non-terminal request for this meetup+requester pair.
    final rows = await supabase
        .from('meetup_requests')
        .select()
        .eq('meetup_id', meetupId)
        .eq('requester_id', requesterId)
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  /// Returns the existing chat for a user-pair, regardless of meetup cycle.
  static Future<Map<String, dynamic>?> getChatForUserPair({
    required String userA,
    required String userB,
  }) async {
    // Try both orderings since user_one/user_two assignment is fixed at creation.
    final rows = await supabase
        .from('chats')
        .select()
        .or(
          'and(user_one.eq.$userA,user_two.eq.$userB),and(user_one.eq.$userB,user_two.eq.$userA)',
        )
        .order('created_at', ascending: true)
        .limit(1);

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  /// Checks whether the pair has an active (non-terminal, non-expired) meetup request.
  static Future<bool> hasActiveMeetupRequestBetween({
    required String userA,
    required String userB,
  }) async {
    try {
      final result = await supabase.rpc(
        'has_active_meetup_request_between',
        params: {'p_user_a': userA, 'p_user_b': userB},
      );
      if (result is bool) return result;
      return result?.toString().toLowerCase() == 'true';
    } catch (_) {
      // Fallback: query directly
      final rows = await supabase
          .from('meetup_requests')
          .select('id, status, meetup_id')
          .or(
            'and(requester_id.eq.$userA,meetup_owner_id.eq.$userB),and(requester_id.eq.$userB,meetup_owner_id.eq.$userA)',
          )
          .inFilter('status', ['requested', 'accepted']);

      if (rows.isEmpty) return false;

      // For accepted ones, check if meetup date has passed.
      for (final raw in List<Map<String, dynamic>>.from(rows)) {
        final status = raw['status']?.toString() ?? '';
        if (status == 'requested') return true;
        if (status == 'accepted') {
          final meetupId = raw['meetup_id']?.toString() ?? '';
          if (meetupId.isEmpty) return true;
          Map<String, dynamic>? meetupRow;
          try {
            meetupRow = await supabase
                .from('meetups')
                .select('date, time')
                .eq('id', meetupId)
                .maybeSingle();
          } catch (_) {
            meetupRow = await supabase
                .from('meetups')
                .select('meetup_date, meetup_time')
                .eq('id', meetupId)
                .maybeSingle();
          }
          if (meetupRow == null) return true;
          final dateStr = (meetupRow['date'] ?? meetupRow['meetup_date'])
                  ?.toString()
                  .trim() ??
              '';
          final timeStr = (meetupRow['time'] ?? meetupRow['meetup_time'])
                  ?.toString()
                  .trim() ??
              '';
          if (dateStr.isEmpty) return true;
          final dt = DateTime.tryParse(
              timeStr.isNotEmpty ? '${dateStr}T$timeStr' : dateStr);
          if (dt == null || dt.isAfter(DateTime.now())) return true;
          // Meetup date passed — treat as completed, not active.
        }
      }
      return false;
    }
  }

  static Future<Map<String, dynamic>> sendMeetupRequest({
    required String meetupId,
    required String meetupOwnerId,
    required String requesterId,
  }) async {
    if (await isProfileDisabled(requesterId)) {
      throw Exception('Your account is disabled.');
    }
    if (await isProfileDisabled(meetupOwnerId)) {
      throw Exception('This account is disabled.');
    }
    if (await areUsersBlocked(userA: requesterId, userB: meetupOwnerId)) {
      throw Exception(
        'Cannot send meetup request because one of you has blocked the other.',
      );
    }

    // Block if there is already an active/pending/accepted meetup between them.
    final hasActive = await hasActiveMeetupRequestBetween(
      userA: requesterId,
      userB: meetupOwnerId,
    );
    if (hasActive) {
      throw Exception(
        'A meetup request is already active between you. Wait for it to complete before sending a new one.',
      );
    }

    // ── 1. Find or create the single chat for this user-pair ─────────────────
    Map<String, dynamic>? chatRow = await getChatForUserPair(
      userA: meetupOwnerId,
      userB: requesterId,
    );

    if (chatRow == null) {
      try {
        final inserted = await supabase
            .from('chats')
            .insert({
              'meetup_id': meetupId,
              'user_one': meetupOwnerId,
              'user_two': requesterId,
              'chat_type': 'meetup',
              'status': 'requested',
            })
            .select()
            .single();
        chatRow = Map<String, dynamic>.from(inserted);
      } catch (e) {
        if (!_isUniqueViolation(e)) rethrow;
        // Race condition: another insert won — fetch it.
        chatRow = await getChatForUserPair(
          userA: meetupOwnerId,
          userB: requesterId,
        );
        if (chatRow == null) rethrow;
      }
    } else {
      // Reopen the chat for the new meetup cycle.
      await supabase.from('chats').update({
        'meetup_id': meetupId,
        'status': 'requested',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', chatRow['id']);
      chatRow['status'] = 'requested';
      chatRow['meetup_id'] = meetupId;
    }

    final chatId = _text(chatRow['id']);
    if (chatId.isEmpty) throw Exception('Failed to create meetup chat thread.');

    // ── 2. Create a new meetup_request row for this cycle ────────────────────
    Map<String, dynamic> requestRow;
    try {
      final inserted = await supabase
          .from('meetup_requests')
          .insert({
            'meetup_id': meetupId,
            'meetup_owner_id': meetupOwnerId,
            'requester_id': requesterId,
            'chat_id': chatId,
            'status': 'requested',
          })
          .select()
          .single();
      requestRow = Map<String, dynamic>.from(inserted);
    } catch (e) {
      if (!_isUniqueViolation(e)) rethrow;
      // Idempotent: same meetup+requester+chat already exists.
      final existing = await supabase
          .from('meetup_requests')
          .select()
          .eq('chat_id', chatId)
          .eq('meetup_id', meetupId)
          .eq('requester_id', requesterId)
          .maybeSingle();
      if (existing == null) rethrow;
      requestRow = Map<String, dynamic>.from(existing);
    }

    final requestId = _text(requestRow['id']);
    if (requestId.isEmpty) throw Exception('Failed to create meetup request.');

    // Update chat to reference the latest request.
    await supabase.from('chats').update({
      'meetup_request_id': requestId,
    }).eq('id', chatId);

    // ── 3. Insert a meetup_request message for this cycle ────────────────────
    // Check if a message for THIS specific request already exists.
    final existingMsg = await supabase
        .from('messages')
        .select('id')
        .eq('chat_id', chatId)
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request')
        .limit(1);

    if (existingMsg.isEmpty) {
      await supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': requesterId,
        'message_type': 'meetup_request',
        'text': 'sent you a meetup request',
        'request_status': 'requested',
        'meetup_id': meetupId,
        'meetup_request_id': requestId,
      });
    }

    return chatRow;
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
    // Only allow sending when the latest request is accepted and not yet completed.
    if (chatStatus != 'accepted') return;

    if (await isProfileDisabled(senderId)) {
      throw Exception('Your account is disabled.');
    }

    final chat = await getChatById(chatId);
    final userOne = _text(chat?['user_one']);
    final userTwo = _text(chat?['user_two']);

    if (userOne.isNotEmpty &&
        userTwo.isNotEmpty &&
        await areUsersBlocked(userA: userOne, userB: userTwo)) {
      throw Exception(
        'Cannot send message because one of you has blocked the other.',
      );
    }

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

  /// Cancels a specific meetup request and inserts a system message.
  /// The chat remains open but the meetup is removed/cancelled.
  static Future<void> cancelMeetupRequest({
    required String requestId,
    required String chatId,
    required String cancelledByUserId,
    required String cancelledByUserName,
  }) async {
    // 1. Mark the request as cancelled.
    await supabase
        .from('meetup_requests')
        .update({'status': 'cancelled'}).eq('id', requestId);

    // 2. Update the meetup_request message to show cancelled.
    await supabase
        .from('messages')
        .update({
          'request_status': 'cancelled',
        })
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request');

    // 3. Insert a system message showing who cancelled.
    await supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': cancelledByUserId,
      'message_type': 'system',
      'text': '$cancelledByUserName cancelled the meetup',
    });

    // 4. Update chat status to cancelled so messaging is blocked until new request.
    await supabase.from('chats').update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', chatId);

    // 5. Optionally delete the meetup from the meetups table.
    //    (Or mark it cancelled if you want to keep history.)
    final reqRow = await supabase
        .from('meetup_requests')
        .select('meetup_id')
        .eq('id', requestId)
        .maybeSingle();
  }

  /// Only updates the message tied to that specific request_id.
  static Future<void> acceptRequest({
    required String requestId,
    required String chatId,
    required String requestMessageId,
  }) async {
    await supabase
        .from('meetup_requests')
        .update({'status': 'accepted'}).eq('id', requestId);

    // Update chat status to accepted for the active cycle.
    await supabase
        .from('chats')
        .update({'status': 'accepted'}).eq('id', chatId);

    // Only update the message for THIS specific request — preserve history.
    await supabase
        .from('messages')
        .update({
          'request_status': 'accepted',
        })
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request');
  }

  /// Rejects a specific meetup request by its ID.
  static Future<void> rejectRequest({
    required String requestId,
    required String chatId,
    required String requestMessageId,
  }) async {
    await supabase
        .from('meetup_requests')
        .update({'status': 'rejected'}).eq('id', requestId);

    // Revert chat to a neutral state so a new request can be sent later.
    await supabase
        .from('chats')
        .update({'status': 'rejected'}).eq('id', chatId);

    await supabase
        .from('messages')
        .update({
          'request_status': 'rejected',
        })
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request');
  }

  /// Returns the latest meetup_request for a chat (most recent by created_at).
  static Future<Map<String, dynamic>?> getLatestRequestForChat(
    String chatId,
  ) async {
    final rows = await supabase
        .from('meetup_requests')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  /// Legacy alias kept for callers that haven't been updated yet.
  static Future<Map<String, dynamic>?> getRequestForChat(String chatId) =>
      getLatestRequestForChat(chatId);

  /// Returns the meetup_request message for a specific request_id.
  static Future<Map<String, dynamic>?> getRequestMessageForRequest(
    String requestId,
  ) async {
    final rows = await supabase
        .from('messages')
        .select()
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request')
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  /// Legacy: returns the latest meetup_request message in a chat.
  static Future<Map<String, dynamic>?> getRequestMessage(String chatId) async {
    final rows = await supabase
        .from('messages')
        .select()
        .eq('chat_id', chatId)
        .eq('message_type', 'meetup_request')
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  // ── Delete conversation ────────────────────────────────────────────────────

  /// Deletes a chat and all its messages from Supabase.
  /// meetup_requests rows have chat_id set to null via FK on delete set null.
  static Future<void> deleteConversation(String chatId) async {
    // Messages are deleted via ON DELETE CASCADE on chats.id.
    await supabase.from('chats').delete().eq('id', chatId);
  }

  // ── Block with side-effects ────────────────────────────────────────────────

  /// Blocks a user and cancels all active meetup requests + closes the chat.
  /// The DB trigger handles cancellation; this method also deletes the chat.
  static Future<void> blockUserAndCleanup({
    required String blockerId,
    required String blockedId,
    String? reason,
    bool deleteChat = true,
  }) async {
    await blockUser(
      blockerId: blockerId,
      blockedId: blockedId,
      reason: reason,
    );

    if (deleteChat) {
      final chatRow = await getChatForUserPair(
        userA: blockerId,
        userB: blockedId,
      );
      if (chatRow != null) {
        final chatId = _text(chatRow['id']);
        if (chatId.isNotEmpty) {
          await deleteConversation(chatId);
        }
      }
    }
  }

  // ── Computed chat permission ───────────────────────────────────────────────

  /// Returns the effective status of the latest meetup request for a chat,
  /// auto-completing accepted requests whose meetup date has passed.
  static Future<String> resolveLatestRequestStatus(String chatId) async {
    final reqRow = await getLatestRequestForChat(chatId);
    if (reqRow == null) return 'none';

    final status = reqRow['status']?.toString() ?? 'requested';
    if (status == 'accepted') {
      final meetupId = reqRow['meetup_id']?.toString() ?? '';
      if (meetupId.isNotEmpty) {
        try {
          // Try both column name variants: (date,time) and (meetup_date,meetup_time)
          Map<String, dynamic>? meetupRow;
          try {
            meetupRow = await supabase
                .from('meetups')
                .select('date, time')
                .eq('id', meetupId)
                .maybeSingle();
          } catch (_) {
            meetupRow = await supabase
                .from('meetups')
                .select('meetup_date, meetup_time')
                .eq('id', meetupId)
                .maybeSingle();
          }
          if (meetupRow != null) {
            final dateStr = (meetupRow['date'] ?? meetupRow['meetup_date'])
                    ?.toString()
                    .trim() ??
                '';
            final timeStr = (meetupRow['time'] ?? meetupRow['meetup_time'])
                    ?.toString()
                    .trim() ??
                '';
            if (dateStr.isNotEmpty) {
              final dt = DateTime.tryParse(
                  timeStr.isNotEmpty ? '${dateStr}T$timeStr' : dateStr);
              if (dt != null && dt.isBefore(DateTime.now())) {
                await supabase
                    .from('meetup_requests')
                    .update({'status': 'completed'}).eq('id', reqRow['id']);
                await supabase
                    .from('chats')
                    .update({'status': 'completed'}).eq('id', chatId);
                await supabase
                    .from('messages')
                    .update({'request_status': 'completed'})
                    .eq('meetup_request_id', reqRow['id'])
                    .eq('message_type', 'meetup_request');
                return 'completed';
              }
            }
          }
        } catch (_) {}
      }
    }
    return status;
  }
}
