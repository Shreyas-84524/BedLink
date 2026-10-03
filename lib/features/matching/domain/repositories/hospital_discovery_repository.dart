import '../models/hospital_match.dart';

/// Supported clinical resources backed by real Supabase inventory.
const Set<String> kSupportedBedTypes = {
  'general_bed',
  'emergency_bed',
  'icu_bed',
};

/// Supported clinical care capabilities mapped from database facilities.
const Set<String> kSupportedCapabilities = {
  'trauma_care',
  'emergency_care',
  'icu_care',
};

/// Clinical capabilities and resources unsupported by current backend database.
const Set<String> kUnsupportedBackendResources = {
  'ventilator',
  'oxygen_bed',
  'pediatric_icu_bed',
  'cardiac_care',
  'burns_care',
};

/// Contract for discovering, distance-filtering, and ranking hospitals based on real coordinates
/// and clinical requirements.
abstract class HospitalDiscoveryRepository {
  /// Discovers and ranks candidate hospitals from a given ambulance coordinate.
  ///
  /// Steps through 5km -> 10km -> 15km radius expansion until sufficient candidates are found.
  Future<HospitalDiscoveryResult> discoverHospitals({
    required double latitude,
    required double longitude,
    Map<String, int> selectedRequirements = const {},
    double initialRadiusKm = 5.0,
    double maxRadiusKm = 15.0,
    bool activeOnly = true,
  });

  /// Whether this discovery repository queries live backend data.
  bool get isRealBackend;

  /// Label identifying the active discovery data source.
  String get dataSourceName;
}

/// Result envelope of a hospital discovery search run.
class HospitalDiscoveryResult {
  const HospitalDiscoveryResult({
    required this.matches,
    required this.effectiveRadiusKm,
    required this.totalEvaluated,
    required this.totalWithCoordinates,
    required this.unsupportedRequirementsRequested,
    this.dataSourceLabel = 'MOCK_FIXTURE',
    this.isRealBackend = false,
    this.isRlsBlocked = false,
    this.errorMessage,
  });

  /// Candidate hospitals within the discovery radius, sorted and ranked.
  final List<HospitalMatch> matches;

  /// Search radius in km where matching candidates were found (5, 10, or 15).
  final int effectiveRadiusKm;

  /// Total hospitals retrieved from directory.
  final int totalEvaluated;

  /// Total hospitals that possess valid coordinates.
  final int totalWithCoordinates;

  /// List of requested clinical requirement codes that lack backend support.
  final List<String> unsupportedRequirementsRequested;

  /// Human-readable data source label.
  final String dataSourceLabel;

  /// Whether this result originates from live Supabase.
  final bool isRealBackend;

  /// Whether queries were blocked by Supabase RLS.
  final bool isRlsBlocked;

  /// Optional error or diagnostic message.
  final String? errorMessage;

  bool get isEmpty => matches.isEmpty;
  bool get isNotEmpty => matches.isNotEmpty;
}
