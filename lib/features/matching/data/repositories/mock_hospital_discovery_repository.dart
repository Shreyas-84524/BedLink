import '../../../../core/utils/geo_utils.dart';
import '../../data/mock_hospital_data.dart';
import '../../domain/models/hospital_match.dart';
import '../../domain/repositories/hospital_discovery_repository.dart';

/// Test fixture and offline mock implementation of [HospitalDiscoveryRepository].
class MockHospitalDiscoveryRepository implements HospitalDiscoveryRepository {
  MockHospitalDiscoveryRepository({
    this.customMatches,
    this.effectiveRadiusKm = 15,
    this.shouldThrow = false,
  });

  List<HospitalMatch>? customMatches;
  int effectiveRadiusKm;
  bool shouldThrow;

  @override
  bool get isRealBackend => false;

  @override
  String get dataSourceName => 'MOCK_FIXTURE';

  @override
  Future<HospitalDiscoveryResult> discoverHospitals({
    required double latitude,
    required double longitude,
    Map<String, int> selectedRequirements = const {},
    double initialRadiusKm = 5.0,
    double maxRadiusKm = 15.0,
    bool activeOnly = true,
  }) async {
    if (shouldThrow) {
      throw Exception('Mock discovery failure simulated.');
    }

    final sourceList = customMatches ?? MockHospitalData.standardCandidates;

    // Recalculate distances based on provided coordinates if available
    final updated = <HospitalMatch>[];
    for (final h in sourceList) {
      if (h.hasCoordinates) {
        final dist = GeoUtils.haversineDistanceKm(
          latitude,
          longitude,
          h.latitude!,
          h.longitude!,
        );
        updated.add(h.copyWith(
          distanceKm: double.parse(dist.toStringAsFixed(1)),
        ));
      } else {
        updated.add(h);
      }
    }

    return HospitalDiscoveryResult(
      matches: updated,
      effectiveRadiusKm: effectiveRadiusKm,
      totalEvaluated: updated.length,
      totalWithCoordinates: updated.where((h) => h.hasCoordinates).length,
      unsupportedRequirementsRequested: const [],
      dataSourceLabel: dataSourceName,
      isRealBackend: false,
    );
  }
}
