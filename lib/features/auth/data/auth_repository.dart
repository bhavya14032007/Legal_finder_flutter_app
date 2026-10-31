import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

abstract class AuthRepository {
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  });

  Future<void> resetPassword({required String email});

  Future<void> signOut();

  User? get currentUser;
  bool get isAuthenticated;
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient? _client;

  SupabaseAuthRepository([SupabaseClient? client])
      : _client = client ?? SupabaseService.client;

  @override
  User? get currentUser => _client?.auth.currentUser;

  @override
  bool get isAuthenticated => currentUser != null;

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (_client == null) {
      // Offline/Local mock simulation
      await Future.delayed(const Duration(milliseconds: 600));
      debugPrint('[AuthRepository] Local simulated login for $email');
      return;
    }

    try {
      await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } catch (e) {
      debugPrint('[AuthRepository] Sign in error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (_client == null) {
      // Offline/Local mock simulation
      await Future.delayed(const Duration(milliseconds: 600));
      debugPrint('[AuthRepository] Local simulated signup for $email');
      return;
    }

    try {
      await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
    } catch (e) {
      debugPrint('[AuthRepository] Sign up error: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    if (_client == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    try {
      await _client.auth.resetPasswordForEmail(email.trim());
    } catch (e) {
      debugPrint('[AuthRepository] Reset password error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (_client == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      return;
    }

    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('[AuthRepository] Sign out error: $e');
      rethrow;
    }
  }
}
