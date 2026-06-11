import 'package:get/get.dart';
import 'package:meetmern/core/services/notification_service.dart';
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
    await NotificationService.instance.deactivateCurrentToken();
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

  /// Deletes all user data across every table then removes the auth account.
  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final uid = user.id;

    // Delete in dependency order (children before parents).
    // Messages are cascade-deleted when chats are deleted.
    await supabase.from('user_reports').delete().eq('reporter_id', uid);
    await supabase.from('user_reports').delete().eq('reported_user_id', uid);
    await supabase.from('user_blocks').delete().eq('blocker_id', uid);
    await supabase.from('user_blocks').delete().eq('blocked_id', uid);
    await supabase.from('meetup_favourites').delete().eq('user_id', uid);
    await supabase.from('meetup_requests')
        .delete()
        .or('requester_id.eq.$uid,meetup_owner_id.eq.$uid');
    // Deleting chats cascades messages.
    await supabase.from('chats')
        .delete()
        .or('user_one.eq.$uid,user_two.eq.$uid');
    await supabase.from('meetups').delete().eq('user_id', uid);
    await supabase.from('profiles').delete().eq('id', uid);

    // Delete the auth user via RPC (requires a server-side function or service role).
    // Falls back to sign-out if the RPC is not available.
    try {
      await supabase.rpc('delete_user', params: {'user_id': uid});
    } catch (_) {
      // If no RPC exists, sign out - the account data is already wiped.
    }
    await NotificationService.instance.deactivateCurrentToken();
    await supabase.auth.signOut();
    currentProfile.value = null;
  }
}

