import 'dart:typed_data';
import 'package:meetmern/data/models/feedback_model.dart';
import 'package:meetmern/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FeedbackService {
  FeedbackService._();

  static const _bucket = 'feedback-attachments';
  static const _table = 'feedbacks';

  /// Uploads [bytes] to the feedback-attachments bucket and returns the public URL.
  static Future<String?> uploadAttachment({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final ext = fileName.contains('.') ? fileName.split('.').last : 'jpg';
      final path =
          '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName.$ext'
              .replaceAll('..$ext', '.$ext');

      await supabase.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage.from(_bucket).getPublicUrl(path);
    } catch (e) {
      return null;
    }
  }

  /// Inserts a feedback record into the feedbacks table.
  static Future<FeedbackModel> submitFeedback(FeedbackModel feedback) async {
    final response = await supabase
        .from(_table)
        .insert(feedback.toJson())
        .select()
        .single();
    return FeedbackModel.fromJson(response);
  }
}
