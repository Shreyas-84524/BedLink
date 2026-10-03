import 'package:flutter/foundation.dart';

/// Execution mode for BedLink backend connectivity.
enum AppMode {
  /// Pure local mock mode using deterministic in-memory fixtures.
  mock,

  /// Cloud Supabase integration mode using real PostgreSQL & Edge Functions.
  supabase,
}

/// Immutable configuration for Supabase backend connectivity.
///
/// Values are supplied via compile-time/runtime `--dart-define` flags:
/// - `SUPABASE_URL`: The public HTTPS endpoint for the Supabase project.
/// - `SUPABASE_ANON_KEY`: The public publishable anon key.
/// - `APP_MODE`: Explicit mode override ('mock' or 'supabase').
@immutable
class SupabaseConfig {
  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    this.mode = AppMode.mock,
  });

  /// Normalizes project URL by stripping any /rest/v1 or trailing slashes.
  static String normalizeUrl(String raw) {
    var trimmed = raw.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    if (trimmed.endsWith('/rest/v1')) {
      trimmed = trimmed.substring(0, trimmed.length - '/rest/v1'.length);
    }
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed;
  }

  /// Reads configuration from compile-time `--dart-define` environment.
  factory SupabaseConfig.fromEnvironment() {
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const envMode = String.fromEnvironment('APP_MODE', defaultValue: '');

    AppMode resolvedMode;
    if (envMode.toLowerCase() == 'supabase') {
      resolvedMode = AppMode.supabase;
    } else if (envMode.toLowerCase() == 'mock') {
      resolvedMode = AppMode.mock;
    } else {
      // Auto-detect: if both URL and Anon Key are supplied, use Supabase mode; otherwise Mock.
      resolvedMode = (envUrl.isNotEmpty && envAnonKey.isNotEmpty)
          ? AppMode.supabase
          : AppMode.mock;
    }

    return SupabaseConfig(
      url: normalizeUrl(envUrl),
      anonKey: envAnonKey.trim(),
      mode: resolvedMode,
    );
  }

  /// Default mock configuration where Supabase is unconfigured.
  factory SupabaseConfig.mock() {
    return const SupabaseConfig(
      url: '',
      anonKey: '',
      mode: AppMode.mock,
    );
  }

  /// Explicit custom configuration for unit & integration testing.
  factory SupabaseConfig.custom({
    required String url,
    required String anonKey,
    AppMode mode = AppMode.supabase,
  }) {
    return SupabaseConfig(
      url: normalizeUrl(url),
      anonKey: anonKey.trim(),
      mode: mode,
    );
  }

  /// Public project URL (e.g. `https://segutgypwupqjktrxztz.supabase.co`).
  final String url;

  /// Public publishable anon key.
  final String anonKey;

  /// Active runtime mode (mock vs supabase).
  final AppMode mode;

  /// Whether both URL and Anon Key are non-empty and well-formed.
  bool get isConfigured =>
      url.trim().isNotEmpty &&
      anonKey.trim().isNotEmpty &&
      (url.startsWith('https://') || url.startsWith('http://'));

  /// Whether the app should use mock repositories.
  bool get useMock => mode == AppMode.mock || !isConfigured;

  /// Safe diagnostic string that completely redacts any key values.
  @override
  String toString() {
    final maskedKey = anonKey.isEmpty
        ? '<EMPTY>'
        : '${anonKey.substring(0, anonKey.length > 6 ? 6 : anonKey.length)}...[REDACTED]';
    return 'SupabaseConfig(url: ${url.isEmpty ? "<EMPTY>" : url}, anonKey: $maskedKey, mode: $mode, isConfigured: $isConfigured)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SupabaseConfig &&
        other.url == url &&
        other.anonKey == anonKey &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(url, anonKey, mode);
}
