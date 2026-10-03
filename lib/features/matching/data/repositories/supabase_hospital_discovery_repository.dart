import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../hospital/domain/repositories/hospital_repository.dart';
import '../../domain/models/hospital_match.dart';
import '../../domain/repositories/hospital_discovery_repository.dart';

/// Real backend implementation of [HospitalDiscoveryRepository].
///
/// Queries `public.hospitals` via [HospitalRepository], filters out null coordinates (21 records),
/// calculates Haversine straight-line distances from the ambulance GPS coordinates,
/// applies deterministic radius expansion (5km -> 10km -> 15km), and evaluates requirement compatibility.
class SupabaseHospitalDiscoveryRepository implements HospitalDiscoveryRepository {
  const SupabaseHospitalDiscoveryRepository({
    required this.hospitalRepository,
  });

  final HospitalRepository hospitalRepository;

  @override
  bool get isRealBackend => hospitalRepository.isRealBackend;

  @override
  String get dataSourceName => hospitalRepository.dataSourceName;

  @override
  Future<HospitalDiscoveryResult> discoverHospitals({
    required double latitude,
    required double longitude,
    Map<String, int> selectedRequirements = const {},
    double initialRadiusKm = 5.0,
    double maxRadiusKm = 15.0,
    bool activeOnly = true,
  }) async {
    try {
      final allHospitals = await hospitalRepository.getHospitals(activeOnly: activeOnly);

      if (allHospitals.isEmpty) {
        return const HospitalDiscoveryResult(
          matches: [],
          effectiveRadiusKm: 15,
          totalEvaluated: 0,
          totalWithCoordinates: 0,
          unsupportedRequirementsRequested: [],
          dataSourceLabel: 'SUPABASE_CLOUD',
          isRealBackend: true,
          isRlsBlocked: true,
          errorMessage: 'Supabase returned 0 hospital records (RLS default-deny or empty table).',
        );
      }

      // Identify unsupported requirements requested by user
      final unsupportedRequested = selectedRequirements.keys
          .where((k) => kUnsupportedBackendResources.contains(k))
          .toList();

      // Filter out hospitals without coordinates (preserves 21 null-coordinate records safely)
      final withCoords = allHospitals.where((h) => h.hasCoordinates).toList();

      // Compute distances and evaluate compatibility for all coordinate-bearing hospitals
      final evaluated = <HospitalMatch>[];
      for (final h in withCoords) {
        final dist = GeoUtils.haversineDistanceKm(
          latitude,
          longitude,
          h.latitude!,
          h.longitude!,
        );

        if (dist > maxRadiusKm) continue;

        // Estimate transit time in minutes (~20-25 km/h urban Mumbai speed + buffer)
        final estimatedEta = (dist * 2.2 + 2.0).round().clamp(3, 90);

        // Check clinical compatibility
        final bool isClinicallyCompatible = _evaluateClinicalCompatibility(
          hospital: h,
          requirements: selectedRequirements,
        );

        RecommendationTier tier;
        if (!isClinicallyCompatible) {
          tier = RecommendationTier.incompatible;
        } else if (h.occupancyRate >= 85) {
          tier = RecommendationTier.divertRisk;
        } else {
          tier = RecommendationTier.compatible;
        }

        // Calculate transparent multi-criteria match score
        final score = _calculateScore(
          distanceKm: dist,
          occupancyRate: h.occupancyRate,
          isCompatible: isClinicallyCompatible,
        );

        evaluated.add(h.copyWith(
          distanceKm: double.parse(dist.toStringAsFixed(1)),
          etaMinutes: estimatedEta,
          recommendationTier: tier,
          matchScore: score,
        ));
      }

      // Radius progression: 5 km -> 10 km -> 15 km
      int effectiveRadius = 5;
      var candidatePool = evaluated.where((h) => h.distanceKm <= 5.0).toList();

      if (candidatePool.length < 2 && evaluated.any((h) => h.distanceKm <= 10.0)) {
        candidatePool = evaluated.where((h) => h.distanceKm <= 10.0).toList();
        effectiveRadius = 10;
      }

      if (candidatePool.length < 2 && evaluated.any((h) => h.distanceKm <= 15.0)) {
        candidatePool = evaluated.where((h) => h.distanceKm <= 15.0).toList();
        effectiveRadius = 15;
      }

      if (candidatePool.isEmpty && evaluated.isNotEmpty) {
        candidatePool = evaluated;
        effectiveRadius = 15;
      }

      // Sort candidate pool:
      // 1. Incompatible at bottom
      // 2. Divert risk lower
      // 3. Closest distance & highest match score
      candidatePool.sort((a, b) {
        if (a.recommendationTier.isIncompatible != b.recommendationTier.isIncompatible) {
          return a.recommendationTier.isIncompatible ? 1 : -1;
        }
        if (a.recommendationTier.isDivertRisk != b.recommendationTier.isDivertRisk) {
          return a.recommendationTier.isDivertRisk ? 1 : -1;
        }
        return a.distanceKm.compareTo(b.distanceKm);
      });

      // Assign ranks and elevate top candidates
      final ranked = <HospitalMatch>[];
      for (var i = 0; i < candidatePool.length; i++) {
        final c = candidatePool[i];
        RecommendationTier finalTier = c.recommendationTier;
        if (!finalTier.isIncompatible && !finalTier.isDivertRisk) {
          if (i == 0) {
            finalTier = RecommendationTier.topMatch;
          } else if (i == 1) {
            finalTier = RecommendationTier.strongMatch;
          }
        }

        ranked.add(c.copyWith(
          rank: i + 1,
          recommendationTier: finalTier,
        ));
      }

      return HospitalDiscoveryResult(
        matches: ranked,
        effectiveRadiusKm: effectiveRadius,
        totalEvaluated: allHospitals.length,
        totalWithCoordinates: withCoords.length,
        unsupportedRequirementsRequested: unsupportedRequested,
        dataSourceLabel: dataSourceName,
        isRealBackend: isRealBackend,
        isRlsBlocked: false,
      );
    } on HospitalRepositoryException catch (e) {
      return HospitalDiscoveryResult(
        matches: const [],
        effectiveRadiusKm: 15,
        totalEvaluated: 0,
        totalWithCoordinates: 0,
        unsupportedRequirementsRequested: const [],
        dataSourceLabel: dataSourceName,
        isRealBackend: isRealBackend,
        isRlsBlocked: e.isRlsBlock,
        errorMessage: e.message,
      );
    } catch (e) {
      return HospitalDiscoveryResult(
        matches: const [],
        effectiveRadiusKm: 15,
        totalEvaluated: 0,
        totalWithCoordinates: 0,
        unsupportedRequirementsRequested: const [],
        dataSourceLabel: dataSourceName,
        isRealBackend: isRealBackend,
        errorMessage: 'Discovery search failed: $e',
      );
    }
  }

  /// Determines whether a facility satisfies requested bed counts and core care capabilities.
  bool _evaluateClinicalCompatibility({
    required HospitalMatch hospital,
    required Map<String, int> requirements,
  }) {
    if (requirements.isEmpty) return true;

    for (final entry in requirements.entries) {
      final reqCode = entry.key;
      final reqQty = entry.value;

      // Supported bed types
      if (kSupportedBedTypes.contains(reqCode)) {
        final available = hospital.getAvailableCount(reqCode);
        if (available < reqQty && available == 0) {
          return false;
        }
      }

      // Supported capabilities
      if (kSupportedCapabilities.contains(reqCode)) {
        if (!hospital.hasCapability(reqCode)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Calculates composite score out of 100 based on travel proximity, clinical fit, and load.
  double _calculateScore({
    required double distanceKm,
    required int occupancyRate,
    required bool isCompatible,
  }) {
    final clinicalFit = isCompatible ? 40.0 : 10.0;
    final proximity = ((15.0 - distanceKm.clamp(0.0, 15.0)) / 15.0 * 30.0).clamp(5.0, 30.0);
    final load = (((100 - occupancyRate.clamp(0, 100)) / 100.0) * 15.0).clamp(2.0, 15.0);
    const freshness = 15.0;

    return double.parse((clinicalFit + proximity + load + freshness).toStringAsFixed(1));
  }
}
