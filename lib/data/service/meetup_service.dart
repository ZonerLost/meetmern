import 'package:flutter/foundation.dart';
import 'package:meetmern/data/service/places_service.dart';
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
    double? latitude,
    double? longitude,
  }) async {
    String profilePicUrl = '';

    try {
      final profile = await _fetchProfileByUserId(
        userId: userId,
        columns: 'id, photo_url',
      );
      profilePicUrl = _text(profile?['photo_url']);
    } catch (_) {}

    // Geocode the address if no coordinates were pinned on the map.
    double? resolvedLat = latitude;
    double? resolvedLng = longitude;
    if ((resolvedLat == null || resolvedLng == null) && address.isNotEmpty) {
      try {
        final point = await PlacesService.geocode(address);
        if (point != null) {
          resolvedLat = point.latitude;
          resolvedLng = point.longitude;
        }
      } catch (_) {}
    }

    final payload = <String, dynamic>{
      'user_id': userId,
      'type': type,
      'address': address,
      'date': date,
      'time': time,
      'repeat': repeat,
      'status': 'active',
      if (profilePicUrl.isNotEmpty) 'profile_pic_url': profilePicUrl,
      if (resolvedLat != null) 'latitude': resolvedLat,
      if (resolvedLng != null) 'longitude': resolvedLng,
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

  /// Updates an existing meetup in place (used by the Edit Meetup flow).
  /// Mirrors [createMeetup]'s fields but never touches ownership/status.
  static Future<Map<String, dynamic>> updateMeetup({
    required String meetupId,
    required String type,
    required String address,
    required String date,
    required String time,
    required bool repeat,
    double? latitude,
    double? longitude,
  }) async {
    // Re-geocode only if no coordinates were pinned on the map.
    double? resolvedLat = latitude;
    double? resolvedLng = longitude;
    if ((resolvedLat == null || resolvedLng == null) && address.isNotEmpty) {
      try {
        final point = await PlacesService.geocode(address);
        if (point != null) {
          resolvedLat = point.latitude;
          resolvedLng = point.longitude;
        }
      } catch (_) {}
    }

    final payload = <String, dynamic>{
      'type': type,
      'address': address,
      'date': date,
      'time': time,
      'repeat': repeat,
      if (resolvedLat != null) 'latitude': resolvedLat,
      if (resolvedLng != null) 'longitude': resolvedLng,
    };

    try {
      debugPrint(
        '[MeetupService] updateMeetup - updating meetupId=$meetupId payload=$payload',
      );
      await supabase.from('meetups').update(payload).eq('id', meetupId);
    } catch (e, st) {
      debugPrint(
        '[MeetupService] updateMeetup - update failed: $e\n$st',
      );
      rethrow;
    }

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

  /// Returns meetup IDs that should be hidden from the explore feed for [userId].
  /// A meetup is hidden when there is an active (requested/accepted) request
  /// between the viewer and the meetup owner that has not yet expired.
  static Future<Set<String>> fetchHiddenMeetupIdsForUser(
    String userId,
  ) async {
    try {
      // Hide meetups where the current user has any non-cancelled request.
      // completed = meetup happened, hide permanently.
      // requested/accepted = active cycle, hide until terminal.
      final rows = await supabase
          .from('meetup_requests')
          .select('meetup_id, status')
          .eq('requester_id', userId)
          .not('status', 'in', '(cancelled,rejected)');

      return List<Map<String, dynamic>>.from(rows)
          .map((r) => r['meetup_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e, st) {
      debugPrint(
        '[MeetupService] fetchHiddenMeetupIdsForUser - failed: $e\n$st',
      );
      return const <String>{};
    }
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

  /// Returns meetup history for a user based on meetup_requests.
  /// The result is one row per meetup (latest request cycle first),
  /// enriched with owner profile data so it can be mapped with Meetup.fromSupabase.
  static Future<List<Map<String, dynamic>>> fetchMeetupHistoryForUser(
    String userId,
  ) async {
    final requestRowsRaw = await supabase
        .from('meetup_requests')
        .select(
            'id, meetup_id, meetup_owner_id, requester_id, status, created_at')
        .or('requester_id.eq.$userId,meetup_owner_id.eq.$userId')
        .order('created_at', ascending: false);

    final requestRows = List<Map<String, dynamic>>.from(requestRowsRaw);
    if (requestRows.isEmpty) return const <Map<String, dynamic>>[];

    final meetupIds = requestRows
        .map((r) => _text(r['meetup_id']))
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final meetupsById = <String, Map<String, dynamic>>{};
    if (meetupIds.isNotEmpty) {
      final meetupsRaw =
          await supabase.from('meetups').select().inFilter('id', meetupIds);
      final meetups = await _enrichWithProfiles(
        List<Map<String, dynamic>>.from(meetupsRaw),
      );
      for (final row in meetups) {
        final id = _text(row['id']);
        if (id.isNotEmpty) {
          meetupsById[id] = Map<String, dynamic>.from(row);
        }
      }
    }

    final seenMeetupIds = <String>{};
    final historyRows = <Map<String, dynamic>>[];

    for (final req in requestRows) {
      final requestId = _text(req['id']);
      final meetupId = _text(req['meetup_id']);
      final requestStatus = _text(req['status']);
      final createdAt = _text(req['created_at']);
      final ownerId = _text(req['meetup_owner_id']);

      // Keep only the latest request entry per meetup to avoid duplicate cards.
      if (meetupId.isNotEmpty && !seenMeetupIds.add(meetupId)) {
        continue;
      }

      final baseMeetup = meetupId.isNotEmpty ? meetupsById[meetupId] : null;
      final merged = <String, dynamic>{
        ...(baseMeetup ?? <String, dynamic>{}),
        'id': meetupId.isNotEmpty
            ? meetupId
            : (requestId.isNotEmpty
                ? requestId
                : 'history_${historyRows.length}'),
        'user_id': ownerId,
        'status': requestStatus.isNotEmpty
            ? requestStatus
            : _text(baseMeetup?['status']),
        'history_request_id': requestId,
        'history_created_at': createdAt,
      };

      if (_text(merged['type']).isEmpty) {
        merged['type'] = 'Meetup';
      }
      if (_text(merged['address']).isEmpty) {
        merged['address'] = 'Location unavailable';
      }

      // If the original meetup row is gone, fallback to request timestamp.
      if ((merged['date'] == null || _text(merged['date']).isEmpty) &&
          (merged['meetup_date'] == null ||
              _text(merged['meetup_date']).isEmpty) &&
          createdAt.isNotEmpty) {
        final dt = DateTime.tryParse(createdAt);
        if (dt != null) {
          final date = dt.toIso8601String().split('T').first;
          final hh = dt.hour.toString().padLeft(2, '0');
          final mm = dt.minute.toString().padLeft(2, '0');
          merged['meetup_date'] = date;
          merged['meetup_time'] = '$hh:$mm:00';
        }
      }

      historyRows.add(merged);
    }

    return historyRows;
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
          'id, name, photo_url, photos, location, short_bio, gender, relationship_status, religion, ethnicity, languages, interests, passion_topics, children, dob',
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
      'photos': _stringList(row['photos']),
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

  /// Returns the IDs of users who have blocked [userId] (i.e. blockers of me).
  static Future<Set<String>> fetchBlockerIds(String userId) async {
    final rows = await supabase
        .from('user_blocks')
        .select('blocker_id')
        .eq('blocked_id', userId);

    return List<Map<String, dynamic>>.from(rows)
        .map((r) => _text(r['blocker_id']))
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
        'description': (description ?? '').trim().isEmpty
            ? 'No description provided.'
            : description!.trim(),
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
  ///
  /// NOTE: pair-scoped, and therefore **not** suitable for deciding whether an
  /// ad shows "Requested" or whether a request may be sent. Two users may hold
  /// independent requests on several ads at once; use [getExistingRequest] with
  /// the specific meetup id for that. Kept only for callers that genuinely mean
  /// "do these two have anything going on at all".
  static Future<bool> hasActiveMeetupRequestBetween({
    required String userA,
    required String userB,
  }) async {
    final rows = await supabase
        .from('meetup_requests')
        .select('id, status, meetup_id')
        .or(
          'and(requester_id.eq.$userA,meetup_owner_id.eq.$userB),and(requester_id.eq.$userB,meetup_owner_id.eq.$userA)',
        )
        .inFilter('status', ['requested', 'accepted']);

    debugPrint('[MeetupService] hasActiveMeetupRequestBetween — found ${rows.length} active rows: $rows');

    if (rows.isEmpty) return false;

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
              .select('date, time, meetup_date, meetup_time')
              .eq('id', meetupId)
              .maybeSingle();
        } catch (_) {}
        if (meetupRow == null) return true;
        final dateStr =
            (meetupRow['date'] ?? meetupRow['meetup_date'])?.toString().trim() ?? '';
        final timeStr =
            (meetupRow['time'] ?? meetupRow['meetup_time'])?.toString().trim() ?? '';
        if (dateStr.isEmpty) return true;
        final dt = DateTime.tryParse(
            timeStr.isNotEmpty ? '${dateStr}T$timeStr' : dateStr);
        if (dt == null || dt.isAfter(DateTime.now())) return true;
      }
    }
    return false;
  }

  static Future<Map<String, dynamic>> sendMeetupRequest({
    required String meetupId,
    required String meetupOwnerId,
    required String requesterId,
  }) async {
    debugPrint('[MeetupService] sendMeetupRequest — meetupId=$meetupId ownerId=$meetupOwnerId requesterId=$requesterId');

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

    // Request state is scoped to THIS meetup ad, not to the user-pair: the same
    // pair may have several independent requests in flight across different ads.
    // Only a prior request for this same ad blocks a new one.
    final priorRequest = await getExistingRequest(
      meetupId: meetupId,
      requesterId: requesterId,
    );
    final priorStatus =
        priorRequest?['status']?.toString().trim().toLowerCase() ?? '';
    debugPrint('[MeetupService] sendMeetupRequest — prior status="$priorStatus"');

    switch (priorStatus) {
      case 'requested':
        throw Exception('You have already requested this meetup.');
      case 'accepted':
        throw Exception('This meetup is already confirmed between you.');
      case 'rejected':
        throw Exception('This meetup request was declined.');
      case 'completed':
        throw Exception('This meetup has already taken place.');
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
        debugPrint('[MeetupService] sendMeetupRequest — created chat id=${chatRow['id']}');
      } catch (e) {
        if (!_isUniqueViolation(e)) rethrow;
        chatRow = await getChatForUserPair(
          userA: meetupOwnerId,
          userB: requesterId,
        );
        if (chatRow == null) rethrow;
        debugPrint('[MeetupService] sendMeetupRequest — reused chat id=${chatRow['id']}');
      }
    } else {
      // An existing thread may already be open from a previously accepted
      // request. Never downgrade its status here — a new pending request must
      // not close a chat the pair is actively using. Only seed meetup_id when
      // the chat has none, and let _recomputeChatStatus decide the status.
      final existingMeetupId = _text(chatRow['meetup_id']);
      final update = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (existingMeetupId.isEmpty) {
        update['meetup_id'] = meetupId;
        chatRow['meetup_id'] = meetupId;
      }
      await supabase.from('chats').update(update).eq('id', chatRow['id']);
      debugPrint('[MeetupService] sendMeetupRequest — reused chat id=${chatRow['id']}');
    }

    final chatId = _text(chatRow['id']);
    if (chatId.isEmpty) throw Exception('Failed to create meetup chat thread.');

    // ── 2. Insert (or revive) the meetup_request row ─────────────────────────
    // One request row per (meetup_id, requester_id) — enforced by a unique
    // constraint. A previously *cancelled* row is revived rather than duplicated;
    // every other prior status was already rejected by the guard above.
    Map<String, dynamic> requestRow;
    if (priorRequest != null) {
      final revived = await supabase
          .from('meetup_requests')
          .update({'chat_id': chatId, 'status': 'requested'})
          .eq('id', priorRequest['id'])
          .select()
          .single();
      requestRow = Map<String, dynamic>.from(revived);
      debugPrint('[MeetupService] sendMeetupRequest — revived request id=${requestRow['id']}');
    } else {
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
        debugPrint('[MeetupService] sendMeetupRequest — created request id=${requestRow['id']}');
      } catch (e) {
        if (!_isUniqueViolation(e)) {
          debugPrint('[MeetupService] sendMeetupRequest — insert error: $e');
          rethrow;
        }
        // Lost a race with a concurrent request for the same ad.
        throw Exception('You have already requested this meetup.');
      }
    }

    final requestId = _text(requestRow['id']);
    if (requestId.isEmpty) throw Exception('Failed to create meetup request.');

    await supabase.from('chats').update({
      'meetup_request_id': requestId,
    }).eq('id', chatId);

    // ── 3. Insert request message ────────────────────────────────
    // A revived request already has a card in the thread from its first cycle.
    // Drop it so the re-request appears once, in chronological order.
    if (priorRequest != null) {
      await supabase
          .from('messages')
          .delete()
          .eq('meetup_request_id', requestId)
          .eq('message_type', 'meetup_request');
    }

    await supabase.from('messages').insert({
      'chat_id': chatId,
      'sender_id': requesterId,
      'message_type': 'meetup_request',
      'text': 'sent you a meetup request',
      'request_status': 'requested',
      'meetup_id': meetupId,
      'meetup_request_id': requestId,
    });

    // Never downgrades an already-accepted thread — see _recomputeChatStatus.
    await _recomputeChatStatus(chatId);

    debugPrint('[MeetupService] sendMeetupRequest — done. chatId=$chatId requestId=$requestId');
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

  static Future<Map<String, dynamic>?> getMeetupRowForSubtitle(String meetupId) async {
    try {
      final row = await supabase
          .from('meetups')
          .select('id, type, address, date, time')
          .eq('id', meetupId)
          .maybeSingle();
      if (row == null) {
        print('[getMeetupRowForSubtitle] No row found for meetupId=$meetupId');
        return null;
      }
      final r = Map<String, dynamic>.from(row);
      // Normalise to meetup_date / meetup_time for subtitle builder.
      r['meetup_date'] = r['date'];
      r['meetup_time'] = r['time'];
      print('[getMeetupRowForSubtitle] Found row: date=${r['date']} time=${r['time']} address=${r['address']}');
      return r;
    } catch (e) {
      print('[getMeetupRowForSubtitle] ERROR: $e');
    }
    return null;
  }

  /// Resolves the meetup ID for a chat by looking at meetup_requests
  /// when chat.meetup_id is null or the meetup row has been deleted.
  static Future<String?> resolveMeetupIdForChat(String chatId) async {
    try {
      final row = await supabase
          .from('meetup_requests')
          .select('meetup_id')
          .eq('chat_id', chatId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return row?['meetup_id']?.toString();
    } catch (_) {
      return null;
    }
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
    String? userOne,
    String? userTwo,
  }) async {
    if (chatStatus != 'accepted' && chatStatus != 'continue_chat') return;

    if (await isProfileDisabled(senderId)) {
      throw Exception('Your account is disabled.');
    }

    // Use passed user IDs if available to avoid an extra DB fetch.
    final uOne = userOne ?? '';
    final uTwo = userTwo ?? '';
    if (uOne.isNotEmpty && uTwo.isNotEmpty) {
      if (await areUsersBlocked(userA: uOne, userB: uTwo)) {
        throw Exception('Cannot send message because one of you has blocked the other.');
      }
    } else {
      final chatRow = await getChatById(chatId);
      final u1 = _text(chatRow?['user_one']);
      final u2 = _text(chatRow?['user_two']);
      if (u1.isNotEmpty && u2.isNotEmpty && await areUsersBlocked(userA: u1, userB: u2)) {
        throw Exception('Cannot send message because one of you has blocked the other.');
      }
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

    // 3. Breadcrumb so the other side sees which request went away.
    //    Best-effort, for the same reason as in rejectRequest.
    try {
      await supabase.from('messages').insert({
        'chat_id': chatId,
        'sender_id': cancelledByUserId,
        'message_type': 'system',
        'text': '$cancelledByUserName cancelled a meetup',
      });
    } catch (e) {
      debugPrint('[MeetupService] cancelMeetupRequest — breadcrumb failed: $e');
    }

    // 4. Derive the chat status — cancelling one request must not close a
    //    thread that another accepted request is keeping open.
    await _recomputeChatStatus(chatId);

    // 5. Keep the meetup row for history.
  }

  /// Sets the chat status to 'continue_chat' so both sides can keep messaging
  /// after a meetup completes without sending a new request.
  static Future<void> setChatContinueMode(String chatId) async {
    await supabase.from('chats').update({
      'status': 'continue_chat',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', chatId);
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

    // Only update the message for THIS specific request — preserve history.
    await supabase
        .from('messages')
        .update({
          'request_status': 'accepted',
        })
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request');

    await _recomputeChatStatus(chatId);
  }

  /// Rejects a specific meetup request by its ID.
  ///
  /// Declining one request must never close a thread another accepted request
  /// opened, so the chat status is recomputed from *all* requests rather than
  /// being forced to 'rejected'.
  static Future<void> rejectRequest({
    required String requestId,
    required String chatId,
    required String requestMessageId,
  }) async {
    await supabase
        .from('meetup_requests')
        .update({'status': 'rejected'}).eq('id', requestId);

    await supabase
        .from('messages')
        .update({
          'request_status': 'rejected',
        })
        .eq('meetup_request_id', requestId)
        .eq('message_type', 'meetup_request');

    // Breadcrumb in the thread so the requester sees why nothing else changed.
    // Best-effort: a failure here (RLS, a CHECK on message_type, a NOT NULL we
    // don't satisfy) must never stop the recompute below, or the thread would
    // be left showing whatever status the request update happened to leave —
    // which is exactly how declining one request could close a whole chat.
    try {
      final declinerId = await _ownerIdForRequest(requestId);
      if (declinerId != null) {
        await supabase.from('messages').insert({
          'chat_id': chatId,
          'sender_id': declinerId,
          'message_type': 'system',
          'text': requestDeclinedMarker,
        });
      }
    } catch (e) {
      debugPrint('[MeetupService] rejectRequest — breadcrumb failed: $e');
    }

    await _recomputeChatStatus(chatId);
  }

  /// Text stored for the decline breadcrumb. The message screen rewrites it
  /// per viewer, so keep it stable rather than user-facing prose.
  static const String requestDeclinedMarker = 'meetup_request_declined';

  static Future<String?> _ownerIdForRequest(String requestId) async {
    try {
      final row = await supabase
          .from('meetup_requests')
          .select('meetup_owner_id')
          .eq('id', requestId)
          .maybeSingle();
      final id = _text(row?['meetup_owner_id']);
      return id.isEmpty ? null : id;
    } catch (_) {
      return null;
    }
  }

  /// Meetup rows for the given ids, keyed by id. Used to decorate the agreed
  /// meetup cards in a chat thread with venue, type, time and coordinates.
  static Future<Map<String, Map<String, dynamic>>> fetchMeetupsByIds(
    List<String> meetupIds,
  ) async {
    final ids = meetupIds.where((id) => id.trim().isNotEmpty).toSet().toList();
    if (ids.isEmpty) return <String, Map<String, dynamic>>{};

    try {
      final rows = await supabase
          .from('meetups')
          .select('id, type, address, date, time, latitude, longitude')
          .inFilter('id', ids);

      final byId = <String, Map<String, dynamic>>{};
      for (final raw in List<Map<String, dynamic>>.from(rows)) {
        final id = _text(raw['id']);
        if (id.isNotEmpty) byId[id] = raw;
      }
      return byId;
    } catch (e) {
      debugPrint('[MeetupService] fetchMeetupsByIds — ERROR: $e');
      return <String, Map<String, dynamic>>{};
    }
  }

  /// All meetup_requests belonging to a chat, oldest first.
  static Future<List<Map<String, dynamic>>> fetchRequestsForChat(
    String chatId,
  ) async {
    final rows = await supabase
        .from('meetup_requests')
        .select()
        .eq('chat_id', chatId)
        .order('created_at', ascending: true);

    return List<Map<String, dynamic>>.from(rows);
  }

  /// Derives `chats.status` from every request in the thread.
  ///
  /// An accepted request outranks a pending one, which outranks any terminal
  /// status. This is what keeps a thread open after one of several requests is
  /// declined or cancelled. 'continue_chat' is left untouched — it is a user
  /// choice, not a derived state.
  static Future<void> _recomputeChatStatus(String chatId) async {
    try {
      final chatRow = await getChatById(chatId);
      if (_text(chatRow?['status']) == 'continue_chat') return;

      final requests = await fetchRequestsForChat(chatId);
      if (requests.isEmpty) return;

      final statuses = requests
          .map((r) => _text(r['status']).toLowerCase())
          .toList(growable: false);

      final next = deriveChatStatus(statuses);
      if (next.isEmpty) return;

      debugPrint(
          '[MeetupService] _recomputeChatStatus — chat=$chatId statuses=$statuses -> $next');

      await supabase.from('chats').update({
        'status': next,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', chatId);
    } catch (e) {
      debugPrint('[MeetupService] _recomputeChatStatus — ERROR: $e');
    }
  }

  /// The meetup id of the soonest *upcoming* accepted meetup in this chat,
  /// falling back to the most recently accepted one when all have passed.
  /// Drives the chat app-bar subtitle and the meetup info screen.
  static Future<String?> nextUpcomingAcceptedMeetupId(String chatId) async {
    try {
      final requests = await fetchRequestsForChat(chatId);
      final acceptedIds = requests
          .where((r) {
            final s = _text(r['status']).toLowerCase();
            return s == 'accepted' || s == 'completed';
          })
          .map((r) => _text(r['meetup_id']))
          .where((id) => id.isNotEmpty)
          .toList();

      if (acceptedIds.isEmpty) return null;

      final rows = await supabase
          .from('meetups')
          .select('id, date, time')
          .inFilter('id', acceptedIds);

      final now = DateTime.now();
      DateTime? bestUpcoming;
      String? bestUpcomingId;
      DateTime? latestPast;
      String? latestPastId;

      for (final raw in List<Map<String, dynamic>>.from(rows)) {
        final id = _text(raw['id']);
        final dateStr = _text(raw['date']);
        final timeStr = _text(raw['time']);
        if (id.isEmpty || dateStr.isEmpty) continue;

        final dt = DateTime.tryParse(
            timeStr.isNotEmpty ? '${dateStr}T$timeStr' : dateStr);
        if (dt == null) continue;

        if (dt.isAfter(now)) {
          if (bestUpcoming == null || dt.isBefore(bestUpcoming)) {
            bestUpcoming = dt;
            bestUpcomingId = id;
          }
        } else {
          if (latestPast == null || dt.isAfter(latestPast)) {
            latestPast = dt;
            latestPastId = id;
          }
        }
      }

      return bestUpcomingId ?? latestPastId ?? acceptedIds.last;
    } catch (e) {
      debugPrint('[MeetupService] nextUpcomingAcceptedMeetupId — ERROR: $e');
      return null;
    }
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
  /// Retires accepted requests whose meetup has already passed, then returns
  /// the thread's derived status.
  ///
  /// Walks **every** accepted request rather than only the newest one. Judging
  /// the thread by its newest request alone would let a single past meetup mark
  /// the whole conversation completed while another agreed meetup is still
  /// upcoming — closing a chat that should stay open.
  static Future<String> resolveLatestRequestStatus(String chatId) async {
    final requests = await fetchRequestsForChat(chatId);
    if (requests.isEmpty) return 'none';

    final now = DateTime.now();
    var completedAny = false;

    for (final req in requests) {
      if (_text(req['status']).toLowerCase() != 'accepted') continue;

      final meetupId = _text(req['meetup_id']);
      if (meetupId.isEmpty) continue;

      final dt = await _meetupStartsAt(meetupId);
      if (dt == null || !dt.isBefore(now)) continue;

      await supabase
          .from('meetup_requests')
          .update({'status': 'completed'}).eq('id', req['id']);
      await supabase
          .from('messages')
          .update({'request_status': 'completed'})
          .eq('meetup_request_id', req['id'])
          .eq('message_type', 'meetup_request');
      completedAny = true;
    }

    if (completedAny) await _recomputeChatStatus(chatId);

    final chatRow = await getChatById(chatId);
    final chatStatus = _text(chatRow?['status']);
    return chatStatus.isEmpty ? 'none' : chatStatus;
  }

  /// Start time of a meetup, tolerating both column-name variants.
  static Future<DateTime?> _meetupStartsAt(String meetupId) async {
    try {
      Map<String, dynamic>? row;
      try {
        row = await supabase
            .from('meetups')
            .select('date, time')
            .eq('id', meetupId)
            .maybeSingle();
      } catch (_) {
        row = await supabase
            .from('meetups')
            .select('meetup_date, meetup_time')
            .eq('id', meetupId)
            .maybeSingle();
      }
      if (row == null) return null;

      final dateStr = _text(row['date'] ?? row['meetup_date']);
      final timeStr = _text(row['time'] ?? row['meetup_time']);
      if (dateStr.isEmpty) return null;

      return DateTime.tryParse(
          timeStr.isNotEmpty ? '${dateStr}T$timeStr' : dateStr);
    } catch (_) {
      return null;
    }
  }

  /// The status a chat should display, derived from all of its requests.
  /// Mirrors [_recomputeChatStatus] so list and thread never disagree.
  static String deriveChatStatus(Iterable<String> requestStatuses) {
    final statuses =
        requestStatuses.map((s) => s.trim().toLowerCase()).toList();
    if (statuses.contains('accepted')) return 'accepted';
    if (statuses.contains('requested') || statuses.contains('pending')) {
      return 'requested';
    }
    if (statuses.contains('completed')) return 'completed';
    if (statuses.contains('rejected')) return 'rejected';
    if (statuses.contains('cancelled')) return 'cancelled';
    return '';
  }
}
