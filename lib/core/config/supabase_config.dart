import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase configuration and initialization
///
/// IMPORTANT: Replace these values with your actual Supabase credentials
/// before deploying to production. Consider using environment variables
/// or a .env file for sensitive data.
class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'https://ovrifglkufdjjvcxbxis.supabase.co';

  // TODO: Replace with your Supabase anon key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im92cmlmZ2xrdWZkamp2Y3hieGlzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjYwNDk3NzcsImV4cCI6MjA4MTYyNTc3N30.T0A4ig2WRkXhZO04wDpc_0fIMQXCVdl5wuTuiUgkTcc';

  /// Initialize Supabase client
  /// Call this in main() before runApp()
  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  /// Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  /// Get current authenticated user (nullable)
  static User? get currentUser => client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;
}
