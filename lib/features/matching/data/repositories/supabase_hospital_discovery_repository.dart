import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../hospital/domain/repositories/hospital_repository.dart';
import '../../domain/models/hospital_match.dart';
import '../../domain/repositories/hospital_discovery_repository.dart';

import '../services/ors_matrix_service.dart';

/// Real backend implementation of [HospitalDiscoveryRepository].
///
/// Queries `public.hospitals` via [HospitalRepository], filters out null coordinates (21 records),
/// calculates Haversine straight-line distances from the ambulance GPS coordinates,
/// applies deterministic radius expansion (5km -> 10km -> 15km), and evaluates requirement compatibility.
/// When [OrsMatrixService] is configured, queries real road driving durations & road distances.
class SupabaseHospitalDiscoveryRepository implements HospitalDiscoveryRepository {
  const SupabaseHospitalDiscoveryRepository({
    required this.hospitalRepository,
    this.matrixService,
  });

  final HospitalRepository hospitalRepository;
  final OrsMatrixService? matrixService;

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
      final unsupportedRequested = selectedRequirements.keys.where((k) {
        final norm = k.toLowerCase();
        return kUnsupportedBackendResources.contains(norm) ||
            norm.contains('ventilator') ||
            norm.contains('oxygen') ||
            norm.contains('pediatric') ||
            norm.contains('cardiac') ||
            norm.contains('burn');
      }).toList();

      // Filter out hospitals without coordinates (preserves null-coordinate records safely)
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

      // Filter to only clinically compatible facilities (preserves divertRisk, excludes incompatible)
      final compatible = evaluated
          .where((h) => h.recommendationTier != RecommendationTier.incompatible)
          .toList();

      // Radius progression: 5 km -> 10 km -> 15 km
      int effectiveRadius = 5;
      var candidatePool = compatible.where((h) => h.distanceKm <= 5.0).toList();

      if (candidatePool.length < 2 && compatible.any((h) => h.distanceKm <= 10.0)) {
        final within10 = compatible.where((h) => h.distanceKm <= 10.0).toList();
        if (within10.length > candidatePool.length) {
          candidatePool = within10;
          effectiveRadius = 10;
        }
      }

      if (candidatePool.length < 2 && compatible.any((h) => h.distanceKm <= 15.0)) {
        final within15 = compatible.where((h) => h.distanceKm <= 15.0).toList();
        if (within15.length > candidatePool.length) {
          candidatePool = within15;
          effectiveRadius = 15;
        }
      }

      if (candidatePool.isEmpty) {
        effectiveRadius = 15;
      }

      bool isRealRoutingUsed = false;
      String? routingError;

      // Sub-Phase 14.3, 14.4 & 14.5: OpenRouteService Matrix Integration
      // Query real road ETA and road distance for candidate hospitals when ORS is configured.
      if (candidatePool.isNotEmpty && matrixService != null && matrixService!.config.isOrsConfigured) {
        try {
          final destinations = candidatePool
              .map((h) => (latitude: h.latitude!, longitude: h.longitude!))
              .toList();

          final estimates = await matrixService!.getDistancesAndDurations(
            originLat: latitude,
            originLng: longitude,
            destinations: destinations,
          );

          if (estimates.isNotEmpty) {
            final updatedPool = <HospitalMatch>[];
            for (var i = 0; i < candidatePool.length; i++) {
              final h = candidatePool[i];
              final estimate = estimates[i];
              if (estimate != null) {
                // Update with real road distance & duration from ORS
                final updatedScore = _calculateScore(
                  distanceKm: estimate.distanceKm,
                  occupancyRate: h.occupancyRate,
                  isCompatible: true,
                );
                updatedPool.add(h.copyWith(
                  distanceKm: estimate.distanceKm,
                  etaMinutes: estimate.durationMinutes,
                  routeSummary: 'via ORS Matrix Road Corridor',
                  matchScore: updatedScore,
                  isRealRoadRoute: true,
                ));
              } else {
                updatedPool.add(h);
              }
            }
            candidatePool = updatedPool;
            isRealRoutingUsed = true;
          }
        } on RoutingException catch (e) {
          routingError = e.message;
        } catch (e) {
          routingError = 'Routing matrix failed: $e';
        }
      }

      // Sort candidate pool:
      // When real routing is available, sort ascending by real road travel time (ETA),
      // then by road distance, then by match score.
      // Otherwise, sort ascending by geographic distance.
      candidatePool.sort((a, b) {
        if (isRealRoutingUsed) {
          final etaCmp = a.etaMinutes.compareTo(b.etaMinutes);
          if (etaCmp != 0) return etaCmp;
        }
        final distCmp = a.distanceKm.compareTo(b.distanceKm);
        if (distCmp != 0) return distCmp;
        return b.matchScore.compareTo(a.matchScore);
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
        isRealRoutingUsed: isRealRoutingUsed,
        routingErrorMessage: routingError,
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

      // Supported ICU evaluation (countable bed or care capability)
      if (reqCode == 'icu_bed' || reqCode == 'icu') {
        final available = hospital.getAvailableCount('icu_bed');
        if (available < reqQty && available <= 0 && !hospital.hasCapability('icu_care')) {
          return false;
        }
      } else if (reqCode == 'icu_care') {
        if (!hospital.hasCapability('icu_care') && hospital.getAvailableCount('icu_bed') <= 0) {
          return false;
        }
      }

      // Supported Emergency evaluation (countable bed or care capability)
      else if (reqCode == 'emergency_bed' || reqCode == 'emergency') {
        final available = hospital.getAvailableCount('emergency_bed');
        if (available < reqQty && available <= 0 && !hospital.hasCapability('emergency_care')) {
          return false;
        }
      } else if (reqCode == 'emergency_care') {
        if (!hospital.hasCapability('emergency_care') && hospital.getAvailableCount('emergency_bed') <= 0) {
          return false;
        }
      }

      // Supported Trauma Care evaluation (specialized surgical capability)
      else if (reqCode == 'trauma_care' || reqCode == 'trauma') {
        if (!hospital.hasCapability('trauma_care')) {
          return false;
        }
      }

      // Other supported bed types (general_bed)
      else if (kSupportedBedTypes.contains(reqCode)) {
        final available = hospital.getAvailableCount(reqCode);
        if (available < reqQty && available <= 0) {
          return false;
        }
      }

      // Other supported capabilities
      else if (kSupportedCapabilities.contains(reqCode)) {
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
