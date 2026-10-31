import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Centralized Supabase Service Provider
class SupabaseService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static SupabaseClient? get client {
    if (!_initialized) return null;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase Flutter SDK
  static Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('[SupabaseService] Real credentials not set; running in local resilient offline mode.');
      return;
    }

    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _initialized = true;
      debugPrint('[SupabaseService] Initialized successfully.');
    } catch (e) {
      debugPrint('[SupabaseService] Initialization error: $e. Operating in resilient fallback mode.');
      _initialized = false;
    }
  }

  /// Current authenticated user
  static User? get currentUser => client?.auth.currentUser;

  /// Check whether user is logged in
  static bool get isAuthenticated => currentUser != null;

  /// Stream of Auth State Changes
  static Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;
}
