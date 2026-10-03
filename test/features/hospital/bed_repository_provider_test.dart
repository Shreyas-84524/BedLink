import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/config/supabase_config.dart';
import 'package:bedlink/core/data/supabase_client_provider.dart';
import 'package:bedlink/features/hospital/data/models/supabase_bed_dto.dart';
import 'package:bedlink/features/hospital/data/repositories/mock_bed_repository.dart';
import 'package:bedlink/features/hospital/domain/repositories/bed_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/bed_repository_provider.dart';

class _FakeBedRepository implements BedRepository {
  @override
  String get dataSourceName => 'FAKE_BED_REPO';

  @override
  bool get isRealBackend => false;

  @override
  Future<List<SupabaseBedDto>> getBedsForHospital(String hospitalId) async => [];
}

void main() {
  group('bedRepositoryProvider Tests (Worker 3)', () {
    test('defaults to MockBedRepository when Supabase is unconfigured', () {
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

      final repository = container.read(bedRepositoryProvider);

      expect(repository, isA<MockBedRepository>());
      expect(repository.isRealBackend, isFalse);
      expect(repository.dataSourceName, equals('MOCK_BED_FIXTURE'));
    });

    test('returns MockBedRepository if client is null even if config specifies supabase', () {
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

      final repository = container.read(bedRepositoryProvider);

      expect(repository, isA<MockBedRepository>());
      expect(repository.isRealBackend, isFalse);
    });

    test('supports seamless overrideWithValue in tests', () {
      final fakeRepo = _FakeBedRepository();
      final container = ProviderContainer(
        overrides: [
          bedRepositoryProvider.overrideWithValue(fakeRepo),
        ],
      );
      addTearDown(container.dispose);

      final repository = container.read(bedRepositoryProvider);

      expect(repository, isA<_FakeBedRepository>());
      expect(repository.dataSourceName, equals('FAKE_BED_REPO'));
    });
  });
}
