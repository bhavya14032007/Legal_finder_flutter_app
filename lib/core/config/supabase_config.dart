/// Supabase Configuration
///
/// SECURE IMPLEMENTATION NOTE:
/// - Only Supabase URL and Publishable (anon) Key are used in the client.
/// - Never expose service_role or admin secret keys in client-side code.
/// - In production, these should be supplied via compile-time `--dart-define` parameters:
///   flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
class SupabaseConfig {
  SupabaseConfig._();

  // Project URL
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://xyzcompany.supabase.co',
  );

  // Publishable Anon Key (Client safe)
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.e30.dummyAnonKeyLegalHelperClientToken',
  );

  /// Check whether valid credentials have been configured
  static bool get isConfigured =>
      url.isNotEmpty &&
      !url.contains('xyzcompany') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('dummyAnonKey');
}
