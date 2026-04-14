import 'package:meetmern/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

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
  }

  static User? get currentUser => supabase.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
}
