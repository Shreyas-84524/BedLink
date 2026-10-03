import 'package:flutter/foundation.dart';
import '../../../../core/theme/semantic_tokens.dart';
import 'match_score.dart';

/// Recommendation and ranking tier for candidate hospitals.
enum RecommendationTier {
  topMatch('RECOMMENDED • BEST FIT'),
  strongMatch('STRONG MATCH'),
  compatible('AVAILABLE'),
  divertRisk('HIGH LOAD / DIVERT RISK'),
  incompatible('INCOMPATIBLE / STALE');

  const RecommendationTier(this.label);
  final String label;

  bool get isTopMatch => this == RecommendationTier.topMatch;
  bool get isDivertRisk => this == RecommendationTier.divertRisk;
  bool get isIncompatible => this == RecommendationTier.incompatible;
}

/// Ranked hospital candidate matching patient emergency requirements.
@immutable
class HospitalMatch {
  const HospitalMatch({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
    required this.distanceKm,
    required this.etaMinutes,
    required this.updatedMinutesAgo,
    required this.freshnessState,
    required this.loadState,
    required this.occupancyRate,
    required this.rank,
    required this.recommendationTier,
    required this.matchScore,
    required this.availableBedCounts,
    required this.supportedCapabilities,
    required this.routeSummary,
    required this.emergencyPhone,
    this.latitude,
    this.longitude,
    this.scoreBreakdown,
  });

  /// Unique hospital ID (e.g. 'kem_parel').
  final String id;

  /// Official hospital facility name.
  final String name;

  /// Full physical street address.
  final String address;

  /// Mumbai neighborhood / zone (e.g. 'Parel', 'Mahim').
  final String area;

  /// Geographic latitude in decimal degrees (-90 to +90).
  final double? latitude;

  /// Geographic longitude in decimal degrees (-180 to +180).
  final double? longitude;

  /// Whether valid coordinates exist for this facility.
  bool get hasCoordinates =>
      latitude != null &&
      longitude != null &&
      !latitude!.isNaN &&
      !longitude!.isNaN;

  /// Road or straight-line distance in kilometers.
  final double distanceKm;

  /// Estimated road transit time in minutes.
  final int etaMinutes;

  /// Minutes elapsed since last bed status verification.
  final int updatedMinutesAgo;

  /// Semantic freshness classification (<5m, <15m, <30m, >=30m).
  final FreshnessState freshnessState;

  /// Department emergency load classification.
  final HospitalLoadState loadState;

  /// Department occupancy percentage (0..100).
  final int occupancyRate;

  /// 1-based rank in the recommendation match list.
  final int rank;

  /// Recommendation tier classification.
  final RecommendationTier recommendationTier;

  /// Multi-criteria match score (0..100).
  final double matchScore;

  /// Map of resource code to currently available units.
  final Map<String, int> availableBedCounts;

  /// Set of verified clinical care capabilities (e.g. 'cardiac_care').
  final Set<String> supportedCapabilities;

  /// Quick route summary (e.g. 'via Dr. Ambedkar Rd').
  final String routeSummary;

  /// Direct trauma/ED direct desk phone.
  final String emergencyPhone;

  /// Optional detailed breakdown of scoring components.
  final MatchScoreBreakdown? scoreBreakdown;

  /// Returns available count for a specific resource type, or 0.
  int getAvailableCount(String resourceId) => availableBedCounts[resourceId] ?? 0;

  /// Checks if this hospital supports a given care capability.
  bool hasCapability(String capabilityId) => supportedCapabilities.contains(capabilityId);

  /// Human-friendly display string for last update.
  String get freshnessDisplayText {
    if (updatedMinutesAgo <= 1) return 'Updated just now';
    if (updatedMinutesAgo < 60) return 'Updated $updatedMinutesAgo min ago';
    final hours = updatedMinutesAgo ~/ 60;
    return 'Updated $hours hr ago';
  }

  /// Human-friendly distance display string.
  String get distanceDisplayText => '${distanceKm.toStringAsFixed(1)} km';

  /// Human-friendly ETA display string.
  String get etaDisplayText => '$etaMinutes min';

  /// Human-friendly occupancy display string.
  String get occupancyDisplayText => '$occupancyRate% Occupied';

  HospitalMatch copyWith({
    String? id,
    String? name,
    String? address,
    String? area,
    double? distanceKm,
    int? etaMinutes,
    int? updatedMinutesAgo,
    FreshnessState? freshnessState,
    HospitalLoadState? loadState,
    int? occupancyRate,
    int? rank,
    RecommendationTier? recommendationTier,
    double? matchScore,
    Map<String, int>? availableBedCounts,
    Set<String>? supportedCapabilities,
    String? routeSummary,
    String? emergencyPhone,
    double? latitude,
    double? longitude,
    MatchScoreBreakdown? scoreBreakdown,
  }) {
    return HospitalMatch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      area: area ?? this.area,
      distanceKm: distanceKm ?? this.distanceKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      updatedMinutesAgo: updatedMinutesAgo ?? this.updatedMinutesAgo,
      freshnessState: freshnessState ?? this.freshnessState,
      loadState: loadState ?? this.loadState,
      occupancyRate: occupancyRate ?? this.occupancyRate,
      rank: rank ?? this.rank,
      recommendationTier: recommendationTier ?? this.recommendationTier,
      matchScore: matchScore ?? this.matchScore,
      availableBedCounts: availableBedCounts ?? this.availableBedCounts,
      supportedCapabilities: supportedCapabilities ?? this.supportedCapabilities,
      routeSummary: routeSummary ?? this.routeSummary,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HospitalMatch &&
        other.id == id &&
        other.rank == rank &&
        other.etaMinutes == etaMinutes &&
        other.distanceKm == distanceKm &&
        other.updatedMinutesAgo == updatedMinutesAgo &&
        other.occupancyRate == occupancyRate &&
        other.recommendationTier == recommendationTier;
  }

  @override
  int get hashCode => Object.hash(
        id,
        rank,
        etaMinutes,
        distanceKm,
        updatedMinutesAgo,
        occupancyRate,
        recommendationTier,
      );

  @override
  String toString() =>
      'HospitalMatch(#$rank $name [$area] - $etaMinutes min, $distanceKm km, score: $matchScore)';
}
