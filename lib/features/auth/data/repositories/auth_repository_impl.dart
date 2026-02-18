import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:luxe/core/network/supa_service.dart';
import 'package:luxe/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client = SupaService.client;

  @override
  Future<AuthResponse> signInWithEmail(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUpWithEmail(String email, String password, {Map<String, dynamic>? metadata}) {
    return _client.auth.signUp(password: password, email: email, data: metadata);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  User? get currentUser => _client.auth.currentUser;
}
