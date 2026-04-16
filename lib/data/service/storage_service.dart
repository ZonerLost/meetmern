import 'dart:io';
import 'package:meetmern/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService._();

  static Future<String?> uploadProfileImage(
      String userId, File imageFile) async {
    try {
      print('StorageService: Starting upload for user: $userId');
      print('StorageService: File path: ${imageFile.path}');
      print('StorageService: File exists: ${imageFile.existsSync()}');
      
      if (!imageFile.existsSync()) {
        print('StorageService: File does not exist!');
        return null;
      }
      
      final fileName = 'profile_$userId.jpg';
      final path = 'profiles/$fileName';

      print('StorageService: Uploading to path: $path');

      await supabase.storage.from('profile-images').upload(path, imageFile,
          fileOptions: const FileOptions(upsert: true));

      print('StorageService: Upload successful');

      final publicUrl =
          supabase.storage.from('profile-images').getPublicUrl(path);

      print('StorageService: Public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('StorageService: Upload error: $e');
      return null;
    }
  }
}
