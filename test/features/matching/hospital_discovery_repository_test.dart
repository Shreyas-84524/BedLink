import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/features/hospital/domain/repositories/hospital_repository.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/data/repositories/mock_hospital_discovery_repository.dart';
import 'package:bedlink/features/matching/data/repositories/supabase_hospital_discovery_repository.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/core/theme/semantic_tokens.dart';

/// Test stub implementation of [HospitalRepository] for discovery testing.
class FakeHospitalRepository implements HospitalRepository {
  FakeHospitalRepository({
    this.hospitals = const [],
    this.shouldThrowRls = false,
    this.shouldThrowGeneric = false,
  });

  List<HospitalMatch> hospitals;
  bool shouldThrowRls;
  bool shouldThrowGeneric;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async {
    if (shouldThrowRls) {
      throw const HospitalRepositoryException(
        'Supabase RLS is enabled with 0 policies on public.hospitals (default deny).',
        code: ErrorCodes.rlsDenied,
        isRlsBlock: true,
      );
    }
    if (shouldThrowGeneric) {
      throw const HospitalRepositoryException(
        'Database connection timeout.',
        code: ErrorCodes.repositoryError,
      );
    }
    return hospitals;
  }

  @override
  Future<HospitalMatch?> getHospitalById(String id) async {
    try {
      return hospitals.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('SupabaseHospitalDiscoveryRepository Tests', () {
    test('Safely filters out hospitals with null coordinates', () async {
      // Simulates real Supabase dataset with coordinate-bearing and null-coordinate facilities
      final validHosp = MockHospitalData.kemHospital.copyWith(
        id: 'hosp_valid',
        latitude: 18.9986,
        longitude: 72.8427,
      );
      const nullCoordHosp = HospitalMatch(
        id: 'hosp_null_coords',
        name: 'Null Coordinate Clinic',
        address: 'Unknown St',
        area: 'Mumbai',
        distanceKm: 5.0,
        etaMinutes: 12,
        updatedMinutesAgo: 5,
        freshnessState: FreshnessState.fresh,
        loadState: HospitalLoadState.low,
        occupancyRate: 50,
        rank: 2,
        recommendationTier: RecommendationTier.compatible,
        matchScore: 80.0,
        availableBedCounts: {},
        supportedCapabilities: {},
        routeSummary: '',
        emergencyPhone: '',
        latitude: null,
        longitude: null,
      );

      final fakeRepo = FakeHospitalRepository(
        hospitals: [validHosp, nullCoordHosp],
      );

      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: fakeRepo,
      );

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.totalEvaluated, equals(2));
      expect(result.totalWithCoordinates, equals(1));
      expect(result.matches.length, equals(1));
      expect(result.matches.first.id, equals('hosp_valid'));
      expect(result.isRlsBlocked, isFalse);
    });

    test('Expands radius from 5km to 10km when fewer than 2 candidates are nearby', () async {
      // One hospital at 3km, one hospital at 8km, one hospital at 13km
      final nearHosp = MockHospitalData.kemHospital.copyWith(
        id: 'near_3km',
        latitude: 18.9986, // ~1.4 km from 18.9980, 72.8300
        longitude: 72.8427,
      );
      final midHosp = MockHospitalData.hindujaHospital.copyWith(
        id: 'mid_8km',
        latitude: 19.0600, // ~7.5 km away
        longitude: 72.8350,
      );

      final fakeRepo = FakeHospitalRepository(
        hospitals: [nearHosp, midHosp],
      );

      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: fakeRepo,
      );

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      // Since only 1 candidate was within 5km, it expanded to 10km to include the second
      expect(result.effectiveRadiusKm, equals(10));
      expect(result.matches.length, equals(2));
      expect(result.matches[0].id, equals('near_3km'));
      expect(result.matches[0].rank, equals(1));
      expect(result.matches[1].id, equals('mid_8km'));
      expect(result.matches[1].rank, equals(2));
    });

    test('Identifies unsupported requirements in result envelope', () async {
      final fakeRepo = FakeHospitalRepository(
        hospitals: [MockHospitalData.kemHospital],
      );

      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: fakeRepo,
      );

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
        selectedRequirements: {
          'icu_bed': 1,
          'ventilator': 2,
          'oxygen_bed': 1,
        },
      );

      expect(result.unsupportedRequirementsRequested, contains('ventilator'));
      expect(result.unsupportedRequirementsRequested, contains('oxygen_bed'));
      expect(result.unsupportedRequirementsRequested.contains('icu_bed'), isFalse);
    });

    test('Gracefully handles RLS default-deny exception without throwing', () async {
      final fakeRepo = FakeHospitalRepository(shouldThrowRls: true);
      final discoveryRepo = SupabaseHospitalDiscoveryRepository(
        hospitalRepository: fakeRepo,
      );

      final result = await discoveryRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.isRlsBlocked, isTrue);
      expect(result.matches, isEmpty);
      expect(result.errorMessage, contains('RLS'));
    });
  });

  group('MockHospitalDiscoveryRepository Tests', () {
    test('Recalculates distances based on input ambulance coordinates', () async {
      final mockRepo = MockHospitalDiscoveryRepository();
      final result = await mockRepo.discoverHospitals(
        latitude: 18.9980,
        longitude: 72.8300,
      );

      expect(result.isRealBackend, isFalse);
      expect(result.matches.length, equals(5));
      expect(result.matches.first.id, equals('kem_parel'));
      expect(result.matches.first.distanceKm, greaterThan(0));
    });
  });
}
