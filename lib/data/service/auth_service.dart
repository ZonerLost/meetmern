import 'package:get/get.dart';
import 'package:meetmern/data/models/profile_model.dart';
import 'package:meetmern/data/service/profile_service.dart';
import 'package:meetmern/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final Rx<ProfileModel?> currentProfile = Rx<ProfileModel?>(null);

  // Held temporarily between signup and first login
  static String? pendingName;
  static String? pendingPhone;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'com.example.meetmern://login-callback/',
    );
  }

  static Future<void> sendPasswordResetEmail({required String email}) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'com.example.meetmern://reset-callback/',
    );
  }

  static Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    return await supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  static Future<void> verifyOtp({
    required String email,
    required String token,
  }) async {
    await supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  static Future<void> signOut() async {
    await supabase.auth.signOut();
    currentProfile.value = null;
  }

  /// Loads profile from Supabase. If pendingName/pendingPhone exist from signup,
  /// upserts the profile row first (now that a valid session exists).
  static Future<ProfileModel?> loadProfile() async {
    final user = currentUser;
    if (user == null) {
      currentProfile.value = null;
      return null;
    }
    try {
      // If we have pending signup data, upsert the profile row now
      if (pendingName != null || pendingPhone != null) {
        print('AuthService: Applying pending signup data for user: ${user.id}');
        final profile = ProfileModel(
          id: user.id,
          name: pendingName,
          email: user.email,
          phoneNumber: pendingPhone,
          showOnboarding: true,
        );
        await ProfileService.upsertProfile(profile);
        pendingName = null;
        pendingPhone = null;
        print('AuthService: Pending signup data saved successfully');
      }

      final profile = await ProfileService.getProfile(user.id);
      currentProfile.value = profile;
      return profile;
    } catch (e) {
      print('AuthService: Error loading profile: $e');
      currentProfile.value = null;
      return null;
    }
  }

  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
}
