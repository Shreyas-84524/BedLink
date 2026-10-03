import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/features/hospital/data/models/supabase_bed_dto.dart';
import 'package:bedlink/features/hospital/domain/repositories/bed_mutation_repository.dart';
import 'package:bedlink/features/hospital/domain/repositories/bed_repository.dart';
import 'package:bedlink/features/hospital/presentation/providers/bed_repository_provider.dart';
import 'package:bedlink/features/hospital/presentation/providers/hospital_state_provider.dart';

class _MockTestBedRepository implements BedRepository {
  _MockTestBedRepository({
    this.shouldThrowRls = false,
    this.shouldThrowNetwork = false,
    this.bedsToReturn,
  });

  final bool shouldThrowRls;
  final bool shouldThrowNetwork;
  final List<SupabaseBedDto>? bedsToReturn;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<SupabaseBedDto>> getBedsForHospital(String hospitalId) async {
    if (shouldThrowRls) {
      throw const BedRepositoryException(
        'RLS default deny on beds',
        code: ErrorCodes.rlsDenied,
        isRlsBlock: true,
      );
    }

    if (shouldThrowNetwork) {
      throw const NetworkException('Connection timeout');
    }

    return bedsToReturn ?? [];
  }
}

void main() {
  group('HospitalStateNotifier Live Integration Tests (Phase 12)', () {
    test('loadLiveBeds updates state resources and flags real backend', () async {
      final now = DateTime.now();
      final sampleBeds = [
        SupabaseBedDto(id: 'b1', hospitalId: 'h1', bedType: 'ICU', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'b2', hospitalId: 'h1', bedType: 'ICU', status: 'occupied', updatedAt: now),
        SupabaseBedDto(id: 'b3', hospitalId: 'h1', bedType: 'emergency', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'b4', hospitalId: 'h1', bedType: 'emergency', status: 'reserved', updatedAt: now),
      ];

      final container = ProviderContainer(
        overrides: [
          bedRepositoryProvider.overrideWithValue(
            _MockTestBedRepository(bedsToReturn: sampleBeds),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);

      await notifier.loadLiveBeds(hospitalId: 'h1');

      final state = container.read(hospitalStateProvider);

      expect(state.isRealBackend, isTrue);
      expect(state.dataSourceName, equals('SUPABASE_CLOUD'));

      final icu = state.resources['icu_bed']!;
      expect(icu.available, equals(1));
      expect(icu.occupied, equals(1));
      expect(icu.total, equals(2));

      final er = state.resources['er_bed']!;
      expect(er.available, equals(1));
      expect(er.held, equals(1));
      expect(er.total, equals(2));

      expect(notifier.isRlsBlocked, isFalse);
      expect(notifier.inventoryError, isNull);
    });

    test('loadLiveBeds handles RLS error gracefully setting isRlsBlocked flag', () async {
      final container = ProviderContainer(
        overrides: [
          bedRepositoryProvider.overrideWithValue(
            _MockTestBedRepository(shouldThrowRls: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);

      await notifier.loadLiveBeds(hospitalId: 'h1');

      expect(notifier.isRlsBlocked, isTrue);
      expect(notifier.inventoryError, contains('RLS default deny'));
      // State does not crash and initial resources remain accessible
      expect(container.read(hospitalStateProvider).resources, isNotEmpty);
    });

    test('loadLiveBeds handles network error gracefully setting inventoryError', () async {
      final container = ProviderContainer(
        overrides: [
          bedRepositoryProvider.overrideWithValue(
            _MockTestBedRepository(shouldThrowNetwork: true),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);

      await notifier.loadLiveBeds(hospitalId: 'h1');

      expect(notifier.isRlsBlocked, isFalse);
      expect(notifier.inventoryError, isNotNull);
      expect(container.read(hospitalStateProvider).resources, isNotEmpty);
    });

    test('refreshBedInventory triggers load without crashing', () async {
      final container = ProviderContainer(
        overrides: [
          bedRepositoryProvider.overrideWithValue(
            _MockTestBedRepository(bedsToReturn: []),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(hospitalStateProvider.notifier);

      await notifier.refreshBedInventory();

      expect(notifier.isLoadingInventory, isFalse);
    });

    test('MockBedInventoryMutationRepository maintains safe local behavior', () async {
      const repo = MockBedInventoryMutationRepository();

      expect(repo.isRealBackendWritesSupported, isFalse);
      await repo.incrementAvailable('h1', 'icu_bed');
      await repo.decrementAvailable('h1', 'icu_bed');
    });
  });
}
