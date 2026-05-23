import 'package:supabase_flutter/supabase_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Supabase configuration
//
// Replace the values below with your project's URL and anon key from:
//   https://app.supabase.com → Settings → API
//
// ⚠️  Never commit real credentials to a public repository.
//     Use a .env file + --dart-define or flutter_dotenv for production.
// ─────────────────────────────────────────────────────────────────────────────

const _supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
const _supabaseAnonKey = 'YOUR_ANON_KEY';

/// Initialises the Supabase client.
///
/// Must be awaited in [main] before [runApp]:
/// ```dart
/// await SupabaseConfig.initialize();
/// ```
class SupabaseConfig {
  SupabaseConfig._(); // prevent instantiation

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      // Uncomment and configure as needed:
      // authOptions: FlutterAuthClientOptions(
      //   authFlowType: AuthFlowType.pkce,
      // ),
      // realtimeClientOptions: const RealtimeClientOptions(
      //   logLevel: RealtimeLogLevel.info,
      // ),
    );
  }
}

/// Convenience getter for the Supabase client.
///
/// Use anywhere in the app after [SupabaseConfig.initialize] has been called:
/// ```dart
/// final user = supabase.auth.currentUser;
/// final data = await supabase.from('products').select();
/// ```
SupabaseClient get supabase => Supabase.instance.client;
