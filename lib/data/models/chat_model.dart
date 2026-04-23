import 'package:meetmern/data/models/explore_meetup_model.dart';

enum RequestStatus { none, accepted, rejected, requested, completed, cancelled }

/// Maps DB status strings to [RequestStatus].
RequestStatus requestStatusFromDbString(String? s) {
  switch (s?.toLowerCase()) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'rejected':
      return RequestStatus.rejected;
    case 'completed':
      return RequestStatus.completed;
    case 'cancelled':
      return RequestStatus.cancelled;
    case 'pending':
    case 'requested':
      return RequestStatus.requested;
    default:
      return RequestStatus.none;
  }
}

RequestStatus requestStatusFromString(String? s) {
  if (s == null) return RequestStatus.none;
  switch (s.toLowerCase()) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'rejected':
      return RequestStatus.rejected;
    case 'completed':
      return RequestStatus.completed;
    case 'cancelled':
      return RequestStatus.cancelled;
    case 'requested':
    case 'pending':
      return RequestStatus.requested;
    case 'none':
    default:
      return RequestStatus.none;
  }
}

String requestStatusToString(RequestStatus status) {
  switch (status) {
    case RequestStatus.accepted:
      return 'accepted';
    case RequestStatus.rejected:
      return 'rejected';
    case RequestStatus.completed:
      return 'completed';
    case RequestStatus.cancelled:
      return 'cancelled';
    case RequestStatus.requested:
      return 'requested';
    case RequestStatus.none:
      return 'none';
  }
}

class Chat {
  String name;
  String message;
  String subtitle;
  String type;
  String time;
  String avatarUrl;
  RequestStatus status;

  // Supabase-backed fields (null for mock/local chats)
  final String? id; // chats.id
  final String? chatType; // 'meetup' | 'direct'
  final String? dbStatus; // raw DB status: pending/accepted/rejected
  final String? meetupId;
  final String? meetupRequestId;
  final String? userOne;
  final String? userTwo;

  Chat({
    required this.name,
    required this.message,
    this.subtitle = '',
    required this.time,
    required this.type,
    this.avatarUrl = '',
    this.status = RequestStatus.requested,
    this.id,
    this.chatType,
    this.dbStatus,
    this.meetupId,
    this.meetupRequestId,
    this.userOne,
    this.userTwo,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      name: json['name'] as String? ?? '',
      message: json['message'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      time: json['time'] as String? ?? '',
      type: json['type'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      status: requestStatusFromString(json['status'] as String?),
    );
  }

  /// Build a [Chat] from a Supabase `chats` row.
  /// [otherUserName] and [otherUserAvatar] must be resolved by the caller.
  factory Chat.fromSupabase(
    Map<String, dynamic> row, {
    required String otherUserName,
    String otherUserAvatar = '',
    String lastMessage = '',
    String subtitle = '',
  }) {
    final dbStatus = row['status']?.toString() ?? 'pending';
    return Chat(
      id: row['id']?.toString(),
      name: otherUserName,
      message: lastMessage,
      subtitle: subtitle,
      time: row['updated_at']?.toString() ?? '',
      type: row['chat_type']?.toString() ?? 'meetup',
      avatarUrl: otherUserAvatar,
      status: requestStatusFromDbString(dbStatus),
      chatType: row['chat_type']?.toString(),
      dbStatus: dbStatus,
      meetupId: row['meetup_id']?.toString(),
      meetupRequestId: row['meetup_request_id']?.toString(),
      userOne: row['user_one']?.toString(),
      userTwo: row['user_two']?.toString(),
    );
  }

  /// Returns true when normal messaging is allowed.
  bool get canSendMessages {
    if (chatType == 'meetup') return dbStatus == 'accepted';
    return true;
  }

  /// True when the chat is in a terminal state (no further messaging).
  bool get isTerminal =>
      dbStatus == 'closed' ||
      dbStatus == 'completed' ||
      dbStatus == 'cancelled';

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
      'subtitle': subtitle,
      'time': time,
      'type': type,
      'avatarUrl': avatarUrl,
      'status': requestStatusToString(status),
    };
  }
}

extension ChatMeetupMapper on Chat {
  Meetup toMeetup() {
    final parsedTime = DateTime.tryParse(time) ?? DateTime.now();

    return Meetup(
      id: 'chat_$name',
      title: 'Meet me for $type',
      hostName: name,
      time: parsedTime,
      location: message.isNotEmpty ? message : 'Not provided',
      distanceKm: 0.0,
      type: type.isNotEmpty ? type : 'Chat',
      status: requestStatusToString(status),
      image: avatarUrl.isNotEmpty ? avatarUrl : 'assets/images/img9.jpg',
      description: message.isNotEmpty ? message : 'No description provided',
      icon: 'assets/icons/coffe_icon.png',
      languages: const [],
      interests: const [],
    );
  }
}
