import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

/// Provider exposing the active [SupabaseConfig].
final supabaseConfigProvider = Provider<SupabaseConfig>((ref) {
  return SupabaseConfig.fromEnvironment();
});

/// Provider exposing the initialized [SupabaseClient] instance, or null if in mock mode / unconfigured.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  if (config.useMock || !config.isConfigured) {
    return null;
  }

  try {
    return Supabase.instance.client;
  } catch (e) {
    debugPrint('SupabaseClient not initialized: $e');
    return null;
  }
});

/// Safely initializes Supabase client during app bootstrap without crashing.
///
/// Returns the initialized [SupabaseClient], or `null` if unconfigured / in mock mode.
Future<SupabaseClient?> initializeSupabase(SupabaseConfig config) async {
  if (config.useMock || !config.isConfigured) {
    debugPrint('BedLink running in MOCK MODE: Supabase credentials not supplied.');
    return null;
  }

  try {
    // ignore: deprecated_member_use
    await Supabase.initialize(
      url: config.url,
      // ignore: deprecated_member_use
      anonKey: config.anonKey,
      debug: kDebugMode,
    );
    debugPrint('Supabase successfully initialized.');
    return Supabase.instance.client;
  } catch (error, stackTrace) {
    debugPrint('Failed to initialize Supabase: $error\n$stackTrace');
    // Return null so the app falls back safely to mock repositories instead of crashing.
    return null;
  }
}
