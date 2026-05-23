import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supabase configuration — reads credentials from .env
//
// Required keys in .env (see .env.example):
//   SUPABASE_URL      → https://YOUR_PROJECT_ID.supabase.co
//   SUPABASE_ANON_KEY → your project anon/public key
//
// .env is loaded in main() before runApp() via dotenv.load().
// .env is listed in pubspec.yaml under flutter.assets so it is
// bundled into the app. Add .env to .gitignore — never commit secrets.
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConfig {
  SupabaseConfig._(); // prevent instantiation

  /// Reads credentials from the loaded .env and initialises the client.
  ///
  /// Must be awaited in [main] after [dotenv.load()]:
  /// ```dart
  /// await dotenv.load(fileName: '.env');
  /// await SupabaseConfig.initialize();
  /// ```
  static Future<void> initialize() async {
    final url     = dotenv.env['SUPABASE_URL']      ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    assert(url.isNotEmpty,     'SUPABASE_URL is missing from .env');
    assert(anonKey.isNotEmpty, 'SUPABASE_ANON_KEY is missing from .env');

    await Supabase.initialize(
      url:     url,
      anonKey: anonKey,
    );
  }
}

/// Convenience getter for the Supabase client.
///
/// Available anywhere after [SupabaseConfig.initialize] has been called:
/// ```dart
/// final user = supabase.auth.currentUser;
/// final data = await supabase.from('products').select();
/// ```
SupabaseClient get supabase => Supabase.instance.client;
