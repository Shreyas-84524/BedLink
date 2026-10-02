import 'package:bedlink/core/config/supabase_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SupabaseConfig Tests (Worker 1)', () {
    test('default mock config is unconfigured and selects mock mode', () {
      final config = SupabaseConfig.mock();

      expect(config.url, isEmpty);
      expect(config.anonKey, isEmpty);
      expect(config.mode, equals(AppMode.mock));
      expect(config.isConfigured, isFalse);
      expect(config.useMock, isTrue);
    });

    test('missing URL marks config as unconfigured', () {
      const config = SupabaseConfig(
        url: '',
        anonKey: 'sample-anon-key',
        mode: AppMode.supabase,
      );

      expect(config.isConfigured, isFalse);
      expect(config.useMock, isTrue);
    });

    test('missing anon key marks config as unconfigured', () {
      const config = SupabaseConfig(
        url: 'https://sample.supabase.co',
        anonKey: '',
        mode: AppMode.supabase,
      );

      expect(config.isConfigured, isFalse);
      expect(config.useMock, isTrue);
    });

    test('valid HTTPS URL and anon key marks config as configured and active', () {
      const config = SupabaseConfig(
        url: 'https://segutgypwupqjktrxztz.supabase.co',
        anonKey: 'sample-anon-key-abc123xyz',
        mode: AppMode.supabase,
      );

      expect(config.isConfigured, isTrue);
      expect(config.useMock, isFalse);
      expect(config.mode, equals(AppMode.supabase));
    });

    test('toString safely redacts anon key and never exposes raw secrets', () {
      const config = SupabaseConfig(
        url: 'https://segutgypwupqjktrxztz.supabase.co',
        anonKey: 'sensitive-super-secret-key-1234567890',
        mode: AppMode.supabase,
      );

      final debugString = config.toString();

      expect(debugString, contains('https://segutgypwupqjktrxztz.supabase.co'));
      expect(debugString, contains('[REDACTED]'));
      expect(debugString, isNot(contains('sensitive-super-secret-key-1234567890')));
    });

    test('custom factory correctly builds configured instance', () {
      final config = SupabaseConfig.custom(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
        mode: AppMode.supabase,
      );

      expect(config.url, equals('https://test.supabase.co'));
      expect(config.anonKey, equals('test-anon-key'));
      expect(config.isConfigured, isTrue);
    });
  });
}
