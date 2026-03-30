import 'package:meetmern/data/models/explore_meetup_model.dart';

enum RequestStatus { none, accepted, rejected, requested }

RequestStatus requestStatusFromString(String? s) {
  if (s == null) return RequestStatus.none;
  switch (s.toLowerCase()) {
    case 'accepted':
      return RequestStatus.accepted;
    case 'rejected':
      return RequestStatus.rejected;
    case 'requested':
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
    case RequestStatus.requested:
      return 'requested';
    case RequestStatus.none:
    default:
      return 'none';
  }
}

class Chat {
  String name;
  String message;
  String type;
  String time;
  String avatarUrl;
  RequestStatus status;

  Chat({
    required this.name,
    required this.message,
    required this.time,
    required this.type,
    this.avatarUrl = '',
    this.status = RequestStatus.requested,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      name: json['name'] as String? ?? '',
      message: json['message'] as String? ?? '',
      time: json['time'] as String? ?? '',
      type: json['type'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      status: requestStatusFromString(json['status'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'message': message,
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
