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
    defaultValue: 'https://rkjgwvnmjuugzdhogbra.supabase.co',
  );

  // Publishable Anon Key (Client safe)
  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJramd3dm5tanV1Z3pkaG9nYnJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM0NjYwMDQsImV4cCI6MjEwOTA0MjAwNH0.B5mt1YtTU0FJLTh9NuYJ9olW7wfSRzYhV6XPNp81Vw4',
  );

  /// Check whether valid credentials have been configured
  static bool get isConfigured =>
      url.isNotEmpty &&
      !url.contains('xyzcompany') &&
      anonKey.isNotEmpty &&
      !anonKey.contains('dummyAnonKey');
}

