import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Future<AuthResponse> signInWithEmail(String email, String password);
  Future<AuthResponse> signUpWithEmail(String email, String password, {Map<String, dynamic>? metadata});
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  User? get currentUser;
}
