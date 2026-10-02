import '../../../../core/theme/semantic_tokens.dart';
import '../domain/models/hospital_match.dart';
import '../domain/models/match_score.dart';

/// Deterministic mock dataset of Mumbai hospitals for BedLink discovery & match grid.
class MockHospitalData {
  const MockHospitalData._();

  /// #1 Ranked Hospital: KEM Hospital (Parel)
  /// Optimal match with shortest ETA, high ICU capacity, fresh data, moderate load.
  static const HospitalMatch kemHospital = HospitalMatch(
    id: 'kem_parel',
    name: 'King Edward Memorial Hospital (KEM)',
    address: 'Acharya Donde Marg, Parel, Mumbai, Maharashtra 400012',
    area: 'Parel, Mumbai',
    distanceKm: 3.8,
    etaMinutes: 8,
    updatedMinutesAgo: 2,
    freshnessState: FreshnessState.fresh,
    loadState: HospitalLoadState.moderate,
    occupancyRate: 68,
    rank: 1,
    recommendationTier: RecommendationTier.topMatch,
    matchScore: 96.5,
    availableBedCounts: {
      'icu_bed': 3,
      'ventilator': 2,
      'emergency_bed': 6,
      'oxygen_bed': 8,
      'general_bed': 14,
      'pediatric_icu_bed': 2,
    },
    supportedCapabilities: {
      'cardiac_care',
      'trauma_care',
      'burns_care',
      'pediatric_icu_care',
    },
    routeSummary: 'via Dr. Ambedkar Rd & Acharya Donde Marg (Fastest route)',
    emergencyPhone: '+91 22 2410 7000',
    scoreBreakdown: MatchScoreBreakdown(
      clinicalFitScore: 39.5,
      travelTimeScore: 29.0,
      freshnessScore: 14.5,
      loadScore: 13.5,
      totalScore: 96.5,
    ),
  );

  /// #2 Ranked Hospital: P.D. Hinduja Hospital (Mahim)
  /// Strong alternate candidate, low emergency load, highly reliable.
  static const HospitalMatch hindujaHospital = HospitalMatch(
    id: 'hinduja_mahim',
    name: 'P.D. Hinduja National Hospital',
    address: 'Veer Savarkar Marg, Mahim, Mumbai, Maharashtra 400016',
    area: 'Mahim, Mumbai',
    distanceKm: 5.4,
    etaMinutes: 12,
    updatedMinutesAgo: 4,
    freshnessState: FreshnessState.fresh,
    loadState: HospitalLoadState.low,
    occupancyRate: 48,
    rank: 2,
    recommendationTier: RecommendationTier.strongMatch,
    matchScore: 88.2,
    availableBedCounts: {
      'icu_bed': 2,
      'ventilator': 1,
      'emergency_bed': 4,
      'oxygen_bed': 5,
      'general_bed': 11,
      'pediatric_icu_bed': 0,
    },
    supportedCapabilities: {
      'cardiac_care',
      'trauma_care',
    },
    routeSummary: 'via Lady Jamshedjee Rd & Cadell Rd',
    emergencyPhone: '+91 22 2445 2222',
    scoreBreakdown: MatchScoreBreakdown(
      clinicalFitScore: 37.0,
      travelTimeScore: 24.5,
      freshnessScore: 14.0,
      loadScore: 12.7,
      totalScore: 88.2,
    ),
  );

  /// #3 Ranked Hospital: Lilavati Hospital (Bandra)
  /// Compatible candidate, moderate travel time, recent verification.
  static const HospitalMatch lilavatiHospital = HospitalMatch(
    id: 'lilavati_bandra',
    name: 'Lilavati Hospital & Research Centre',
    address: 'A-791, Bandra Reclamation, Bandra West, Mumbai, Maharashtra 400050',
    area: 'Bandra West, Mumbai',
    distanceKm: 7.2,
    etaMinutes: 16,
    updatedMinutesAgo: 11,
    freshnessState: FreshnessState.recent,
    loadState: HospitalLoadState.moderate,
    occupancyRate: 82,
    rank: 3,
    recommendationTier: RecommendationTier.compatible,
    matchScore: 74.0,
    availableBedCounts: {
      'icu_bed': 1,
      'ventilator': 1,
      'emergency_bed': 3,
      'oxygen_bed': 4,
      'general_bed': 6,
      'pediatric_icu_bed': 1,
    },
    supportedCapabilities: {
      'cardiac_care',
      'burns_care',
    },
    routeSummary: 'via Western Express Hwy & Reclamation Flyover',
    emergencyPhone: '+91 22 2675 1000',
    scoreBreakdown: MatchScoreBreakdown(
      clinicalFitScore: 32.0,
      travelTimeScore: 20.0,
      freshnessScore: 11.5,
      loadScore: 10.5,
      totalScore: 74.0,
    ),
  );

  /// #4 Ranked Hospital: Lokmanya Tilak Hospital (Sion)
  /// Critical surge load (94% occupancy), divert risk alert.
  static const HospitalMatch sionHospital = HospitalMatch(
    id: 'sion_hospital',
    name: 'Lokmanya Tilak Municipal General Hospital (Sion)',
    address: 'Sion West, Mumbai, Maharashtra 400022',
    area: 'Sion West, Mumbai',
    distanceKm: 8.5,
    etaMinutes: 19,
    updatedMinutesAgo: 8,
    freshnessState: FreshnessState.recent,
    loadState: HospitalLoadState.high,
    occupancyRate: 94,
    rank: 4,
    recommendationTier: RecommendationTier.divertRisk,
    matchScore: 58.5,
    availableBedCounts: {
      'icu_bed': 1,
      'ventilator': 1,
      'emergency_bed': 1,
      'oxygen_bed': 2,
      'general_bed': 2,
      'pediatric_icu_bed': 0,
    },
    supportedCapabilities: {
      'trauma_care',
      'burns_care',
    },
    routeSummary: 'via Sion Flyover & Eastern Express Hwy (Heavy traffic)',
    emergencyPhone: '+91 22 2407 6381',
    scoreBreakdown: MatchScoreBreakdown(
      clinicalFitScore: 28.0,
      travelTimeScore: 16.0,
      freshnessScore: 11.0,
      loadScore: 3.5,
      totalScore: 58.5,
    ),
  );

  /// #5 Ranked Hospital: Tata Memorial Hospital (Parel)
  /// Incompatible / Stale data (38 min ago), oncology specialized, no ICU/Vent match.
  static const HospitalMatch tataMemorialHospital = HospitalMatch(
    id: 'tata_memorial',
    name: 'Tata Memorial Hospital',
    address: 'Dr. E Borges Rd, Parel, Mumbai, Maharashtra 400012',
    area: 'Parel, Mumbai',
    distanceKm: 9.8,
    etaMinutes: 22,
    updatedMinutesAgo: 38,
    freshnessState: FreshnessState.stale,
    loadState: HospitalLoadState.moderate,
    occupancyRate: 72,
    rank: 5,
    recommendationTier: RecommendationTier.incompatible,
    matchScore: 32.0,
    availableBedCounts: {
      'icu_bed': 0,
      'ventilator': 0,
      'emergency_bed': 2,
      'oxygen_bed': 3,
      'general_bed': 5,
      'pediatric_icu_bed': 0,
    },
    supportedCapabilities: {
      'burns_care',
    },
    routeSummary: 'via Dr. E Borges Rd',
    emergencyPhone: '+91 22 2417 7000',
    scoreBreakdown: MatchScoreBreakdown(
      clinicalFitScore: 10.0,
      travelTimeScore: 13.0,
      freshnessScore: 4.0,
      loadScore: 5.0,
      totalScore: 32.0,
    ),
  );

  /// Standard list of all 5 Mumbai candidate hospitals.
  static const List<HospitalMatch> standardCandidates = [
    kemHospital,
    hindujaHospital,
    lilavatiHospital,
    sionHospital,
    tataMemorialHospital,
  ];

  /// Single candidate fixture for testing or specialized scenarios.
  static const List<HospitalMatch> singleCandidate = [
    kemHospital,
  ];

  /// Empty fixture for testing 'no compatible hospitals' scenario.
  static const List<HospitalMatch> noCandidates = [];
}
