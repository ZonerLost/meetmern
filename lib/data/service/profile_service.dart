import 'package:meetmern/data/models/profile_model.dart';
import 'package:meetmern/main.dart';

class ProfileService {
  ProfileService._();

  static Future<ProfileModel?> getProfile(String userId) async {
    try {
      print('ProfileService: Fetching profile for user: $userId');
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        print('ProfileService: No profile found for user: $userId');
        return null;
      }
      print('ProfileService: Profile fetched successfully');
      return ProfileModel.fromJson(response);
    } catch (e) {
      print('ProfileService: Error fetching profile: $e');
      throw Exception('Failed to fetch profile: $e');
    }
  }

  static Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    try {
      print('ProfileService: Upserting profile for user: ${profile.id}');
      final data = profile.toJson();
      print('ProfileService: Profile data: $data');
      
      final response = await supabase
          .from('profiles')
          .upsert(data)
          .select()
          .single();
      
      print('ProfileService: Profile upserted successfully');
      return ProfileModel.fromJson(response);
    } catch (e) {
      print('ProfileService: Error upserting profile: $e');
      throw Exception('Failed to save profile: $e');
    }
  }

  static Future<void> updateProfile(String userId, Map<String, dynamic> updates) async {
    try {
      print('ProfileService: Updating profile for user: $userId');
      print('ProfileService: Updates: $updates');
      
      updates['updated_at'] = DateTime.now().toIso8601String();
      
      // First check if profile exists
      final existing = await getProfile(userId);
      
      if (existing == null) {
        // Profile doesn't exist, create it with upsert
        print('ProfileService: Profile does not exist, creating new profile');
        final newProfile = ProfileModel(
          id: userId,
          showOnboarding: true,
        );
        await upsertProfile(newProfile);
      }
      
      // Now update with the new data
      final result = await supabase
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select();
      
      print('ProfileService: Profile updated successfully: $result');
    } catch (e) {
      print('ProfileService: Error updating profile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  static Future<void> markOnboardingComplete(String userId) async {
    try {
      print('ProfileService: Marking onboarding complete for user: $userId');
      await supabase
          .from('profiles')
          .update({'show_onboarding': false, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
      print('ProfileService: Onboarding marked complete');
    } catch (e) {
      print('ProfileService: Error marking onboarding complete: $e');
      throw Exception('Failed to mark onboarding complete: $e');
    }
  }
}
