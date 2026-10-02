import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/config/supabase_config.dart';
import 'package:bedlink/core/data/supabase_client_provider.dart';
import 'package:bedlink/features/hospital/data/repositories/mock_hospital_repository.dart';
import 'package:bedlink/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_repository_provider.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';

class _FakeHospitalRepository implements HospitalRepository {
  @override
  String get dataSourceName => 'FAKE_TEST_REPO';

  @override
  bool get isRealBackend => false;

  @override
  Future<HospitalMatch?> getHospitalById(String id) async => null;

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async => [];
}

void main() {
  group('hospitalRepositoryProvider', () {
    test('defaults to MockHospitalRepository when Supabase is unconfigured', () {
      final container = ProviderContainer(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfig(
              url: '',
              anonKey: '',
              mode: AppMode.mock,
            ),
          ),
          supabaseClientProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(hospitalRepositoryProvider);

      expect(repository, isA<MockHospitalRepository>());
      expect(repository.isRealBackend, isFalse);
      expect(repository.dataSourceName, equals('MOCK_FIXTURE'));
    });

    test('returns MockHospitalRepository if client is null even if config specifies supabase', () {
      final container = ProviderContainer(
        overrides: [
          supabaseConfigProvider.overrideWithValue(
            const SupabaseConfig(
              url: 'https://example.supabase.co',
              anonKey: 'valid-key',
              mode: AppMode.supabase,
            ),
          ),
          supabaseClientProvider.overrideWithValue(null),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(hospitalRepositoryProvider);

      expect(repository, isA<MockHospitalRepository>());
      expect(repository.isRealBackend, isFalse);
    });

    test('supports seamless overrideWithValue in tests', () {
      final fakeRepo = _FakeHospitalRepository();
      final container = ProviderContainer(
        overrides: [
          hospitalRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(hospitalRepositoryProvider);

      expect(repository, isA<_FakeHospitalRepository>());
      expect(repository.dataSourceName, equals('FAKE_TEST_REPO'));
    });
  });
}
