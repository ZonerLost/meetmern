import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  // ---- Google Sign-In (google_sign_in v7 API) ----
  // serverClientId MUST be the Web client ID so Google returns an idToken
  // whose audience Supabase can verify.
  static const String _googleWebClientId =
      '925940972492-ra5qffje9c2g6ihblcol44addv1bqmfc.apps.googleusercontent.com';
  static bool _googleInitialized = false;

  /// Signs in with Google natively and exchanges the Google idToken for a
  /// Supabase session. Mirrors the email/password path so the rest of the
  /// app (profile load, onboarding check, routing) is unchanged.
  static Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await googleSignIn.initialize(serverClientId: _googleWebClientId);
      _googleInitialized = true;
    }

    // v7: authenticate() throws GoogleSignInException(canceled) if the user
    // dismisses the picker — handled by the caller.
    final googleUser = await googleSignIn.authenticate();
    print('Google: authenticated as ${googleUser.email}');

    final idToken = googleUser.authentication.idToken;
    print('Google: idToken is ${idToken == null ? "NULL" : "present (len ${idToken.length})"}');
    if (idToken == null) {
      throw Exception('No ID token received from Google');
    }

    final response = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    print('Google: Supabase session user = ${response.user?.id}');

    // Seed the profiles table with the Google name/email/avatar.
    await _syncGoogleProfile(response.user, googleUser);

    return response;
  }

  /// Persists Google's display name, email and avatar into the profiles table.
  /// New users get a fresh row (showOnboarding: true → onboarding flow).
  /// Returning users only have *missing* fields backfilled — never overwriting
  /// anything they already set during onboarding.
  static Future<void> _syncGoogleProfile(
    User? user,
    GoogleSignInAccount googleUser,
  ) async {
    if (user == null) return;
    final googleName = googleUser.displayName;
    final googlePhoto = googleUser.photoUrl;
    try {
      final existing = await ProfileService.getProfile(user.id);

      if (existing == null) {
        // Brand-new Google user — create the profile row with Google details.
        await ProfileService.upsertProfile(ProfileModel(
          id: user.id,
          name: googleName,
          email: user.email ?? googleUser.email,
          photoUrl: googlePhoto,
          showOnboarding: true,
        ));
        print('Google: seeded new profile for ${user.id}');
        return;
      }

      // Returning user — only backfill fields that are still empty.
      final updates = <String, dynamic>{};
      if ((existing.name == null || existing.name!.isEmpty) &&
          googleName != null) {
        updates['name'] = googleName;
      }
      if ((existing.photoUrl == null || existing.photoUrl!.isEmpty) &&
          googlePhoto != null) {
        updates['photo_url'] = googlePhoto;
      }
      if ((existing.email == null || existing.email!.isEmpty) &&
          user.email != null) {
        updates['email'] = user.email;
      }
      if (updates.isNotEmpty) {
        await ProfileService.updateProfile(user.id, updates);
        print('Google: backfilled profile fields $updates');
      }
    } catch (e) {
      // Non-fatal: sign-in already succeeded. Onboarding can still collect data.
      print('Google: profile sync failed: $e');
    }
  }

  /// Clears the cached Google account so the picker reappears next time.
  static Future<void> signOutGoogle() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // Ignore — Google SDK may not be initialized if user never used it.
    }
  }

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
    await supabase.auth.signInWithOtp(
      email: email,
      shouldCreateUser: false,
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
    await signOutGoogle();
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

  /// Deletes all user data across every table and storage bucket, then removes
  /// the auth account. Deletion order respects FK dependencies so no constraint
  /// violation can leave the operation in a partial state.
  ///
  /// Tables covered (in deletion order):
  ///   messages → chats → meetup_requests → meetup_favourites (own + on own meetups)
  ///   → user_reports → user_blocks → user_fcm_tokens → feedbacks
  ///   → meetups → profiles
  ///
  /// Storage buckets covered:
  ///   profile-images  (profiles/profile_<uid>.jpg, profiles/photo_<uid>_*.jpg)
  ///   feedback-attachments  (<uid>/*)
  static Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw Exception('No authenticated user.');
    final uid = user.id;

    // ── 1. Storage ────────────────────────────────────────────────────────────
    // Errors here are non-fatal; orphaned files cause no FK violations.
    await _deleteProfileStorageFiles(uid);
    await _deleteFeedbackStorageFiles(uid);

    // ── 2. Leaf records with no dependents ───────────────────────────────────
    await supabase.from('user_fcm_tokens').delete().eq('user_id', uid);
    await supabase.from('feedbacks').delete().eq('user_id', uid);
    await supabase.from('user_reports').delete().eq('reporter_id', uid);
    await supabase.from('user_reports').delete().eq('reported_user_id', uid);
    await supabase.from('user_blocks').delete().eq('blocker_id', uid);
    await supabase.from('user_blocks').delete().eq('blocked_id', uid);

    // ── 3. Messages (before chats) ────────────────────────────────────────────
    // Delete by sender first, then sweep any remaining messages in user's chats.
    await supabase.from('messages').delete().eq('sender_id', uid);
    final chatRows = await supabase
        .from('chats')
        .select('id')
        .or('user_one.eq.$uid,user_two.eq.$uid');
    final chatIds = List<Map<String, dynamic>>.from(chatRows as List)
        .map((r) => r['id'].toString())
        .toList();
    if (chatIds.isNotEmpty) {
      await supabase.from('messages').delete().inFilter('chat_id', chatIds);
    }

    // ── 4. Chats ──────────────────────────────────────────────────────────────
    await supabase
        .from('chats')
        .delete()
        .or('user_one.eq.$uid,user_two.eq.$uid');

    // ── 5. Meetup requests ────────────────────────────────────────────────────
    await supabase
        .from('meetup_requests')
        .delete()
        .or('requester_id.eq.$uid,meetup_owner_id.eq.$uid');

    // ── 6. Meetup favourites ──────────────────────────────────────────────────
    // Remove favourites added by this user.
    await supabase.from('meetup_favourites').delete().eq('user_id', uid);
    // Remove favourites other users added to this user's meetups.
    final meetupRows = await supabase
        .from('meetups')
        .select('id')
        .eq('user_id', uid);
    final meetupIds = List<Map<String, dynamic>>.from(meetupRows as List)
        .map((r) => r['id'].toString())
        .toList();
    if (meetupIds.isNotEmpty) {
      await supabase
          .from('meetup_favourites')
          .delete()
          .inFilter('meetup_id', meetupIds);
    }

    // ── 7. Meetups ────────────────────────────────────────────────────────────
    await supabase.from('meetups').delete().eq('user_id', uid);

    // ── 8. Profile ────────────────────────────────────────────────────────────
    await supabase.from('profiles').delete().eq('id', uid);

    // ── 9. Auth account ───────────────────────────────────────────────────────
    // Requires a Supabase Edge Function or DB function with service-role rights.
    try {
      await supabase.rpc('delete_user', params: {'user_id': uid});
    } catch (_) {
      // No RPC available — data is already wiped; sign-out invalidates the session.
    }

    // ── 10. Local cleanup ─────────────────────────────────────────────────────
    await NotificationService.instance.deactivateCurrentToken();
    await signOutGoogle();
    await supabase.auth.signOut();
    currentProfile.value = null;
  }

  /// Lists every file in the `profile-images` bucket that belongs to [uid]
  /// and removes them all. Silently ignores errors (storage is non-critical).
  static Future<void> _deleteProfileStorageFiles(String uid) async {
    try {
      final bucket = supabase.storage.from('profile-images');
      final files = await bucket.list(path: 'profiles');
      final toDelete = files
          .where((f) => f.name.contains(uid))
          .map((f) => 'profiles/${f.name}')
          .toList();
      if (toDelete.isNotEmpty) await bucket.remove(toDelete);
    } catch (_) {}
  }

  /// Deletes the entire `<uid>/` folder inside the `feedback-attachments` bucket.
  static Future<void> _deleteFeedbackStorageFiles(String uid) async {
    try {
      final bucket = supabase.storage.from('feedback-attachments');
      final files = await bucket.list(path: uid);
      final toDelete = files.map((f) => '$uid/${f.name}').toList();
      if (toDelete.isNotEmpty) await bucket.remove(toDelete);
    } catch (_) {}
  }
}

