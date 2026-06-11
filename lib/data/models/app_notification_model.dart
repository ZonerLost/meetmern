class AppNotification {
  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.actorId,
    this.data = const <String, dynamic>{},
    this.sentAt,
  });

  final String id;
  final String userId;
  final String? actorId;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? sentAt;

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    final payload = rawData is Map
        ? rawData.cast<String, dynamic>()
        : <String, dynamic>{};

    return AppNotification(
      id: (map['id'] ?? '').toString(),
      userId: (map['user_id'] ?? '').toString(),
      actorId: map['actor_id']?.toString(),
      type: (map['type'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      body: (map['body'] ?? '').toString(),
      data: payload,
      isRead: map['is_read'] == true,
      createdAt: DateTime.tryParse((map['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      sentAt: DateTime.tryParse((map['sent_at'] ?? '').toString()),
    );
  }
}

