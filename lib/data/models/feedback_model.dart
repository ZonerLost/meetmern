class FeedbackModel {
  final String? id;
  final String userId;
  final String title;
  final String type;
  final String urgency;
  final String description;
  final List<String> attachmentUrls;
  final DateTime? createdAt;

  const FeedbackModel({
    this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.urgency,
    required this.description,
    this.attachmentUrls = const [],
    this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'title': title,
        'type': type,
        'urgency': urgency,
        'description': description,
        'attachment_urls': attachmentUrls,
        'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        id: json['id'] as String?,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        type: json['type'] as String,
        urgency: json['urgency'] as String,
        description: json['description'] as String,
        attachmentUrls: (json['attachment_urls'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );
}
