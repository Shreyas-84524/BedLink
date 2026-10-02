import '../../domain/repositories/bed_repository.dart';
import '../models/supabase_bed_dto.dart';

/// In-memory mock repository supplying deterministic bed slot fixtures for tests and offline mode.
class MockBedRepository implements BedRepository {
  const MockBedRepository({
    this.customBeds,
  });

  final List<SupabaseBedDto>? customBeds;

  @override
  bool get isRealBackend => false;

  @override
  String get dataSourceName => 'MOCK_BED_FIXTURE';

  @override
  Future<List<SupabaseBedDto>> getBedsForHospital(String hospitalId) async {
    if (customBeds != null) {
      return List.unmodifiable(customBeds!);
    }

    return _generateDeterministicBeds(hospitalId);
  }

  /// Generates deterministic slot inventory matching Phase 8 default counts:
  /// - 12 ICU beds (3 available, 0 held, 9 occupied)
  /// - 15 Emergency beds (4 available, 0 held, 11 occupied)
  /// - 80 General beds (14 available, 0 held, 66 occupied)
  static List<SupabaseBedDto> _generateDeterministicBeds(String hospitalId) {
    final list = <SupabaseBedDto>[];
    final now = DateTime.now();

    // 12 ICU Beds: 3 available, 9 occupied
    for (var i = 1; i <= 12; i++) {
      list.add(SupabaseBedDto(
        id: 'mock-icu-$i',
        hospitalId: hospitalId,
        bedType: 'ICU',
        status: i <= 3 ? 'available' : 'occupied',
        updatedAt: now.subtract(Duration(minutes: 5 * i)),
      ));
    }

    // 15 Emergency Beds: 4 available, 11 occupied
    for (var i = 1; i <= 15; i++) {
      list.add(SupabaseBedDto(
        id: 'mock-er-$i',
        hospitalId: hospitalId,
        bedType: 'emergency',
        status: i <= 4 ? 'available' : 'occupied',
        updatedAt: now.subtract(Duration(minutes: 3 * i)),
      ));
    }

    // 80 General Beds: 14 available, 66 occupied
    for (var i = 1; i <= 80; i++) {
      list.add(SupabaseBedDto(
        id: 'mock-gen-$i',
        hospitalId: hospitalId,
        bedType: 'general',
        status: i <= 14 ? 'available' : 'occupied',
        updatedAt: now.subtract(Duration(minutes: 2 * i)),
      ));
    }

    return List.unmodifiable(list);
  }
}
