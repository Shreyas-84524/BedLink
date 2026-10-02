import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/location/location_models.dart';
import '../../../../core/services/location/location_provider.dart';
import '../../../ambulance/presentation/providers/requirement_provider.dart';
import '../../../hospital/presentation/providers/hospital_repository_provider.dart';
import '../../data/mock_hospital_data.dart';
import '../../domain/models/hospital_match.dart';
import 'hospital_discovery_provider.dart';

/// Test fixture modes for demonstrating discovery states.
enum MatchingFixtureMode {
  standardFive,
  singleMatch,
  noMatches,
}

/// Immutable state for the hospital discovery and match grid workflow.
@immutable
class MatchingState {
  const MatchingState({
    required this.isSearching,
    required this.searchRadiusKm,
    required this.searchingProgressMessage,
    required this.matches,
    required this.fixtureMode,
    required this.activeFilter,
    required this.hasSearched,
    this.isRealBackend = false,
    this.dataSourceLabel = 'MOCK_FIXTURE',
    this.errorMessage,
    this.isRlsBlocked = false,
    this.ambulanceLatitude,
    this.ambulanceLongitude,
    this.unsupportedRequirements = const [],
  });

  /// Initial state: ready with standard candidates or auto-searching.
  factory MatchingState.initial({
    bool startSearching = false,
    bool isRealBackend = false,
    String dataSourceLabel = 'MOCK_FIXTURE',
  }) {
    return MatchingState(
      isSearching: startSearching,
      searchRadiusKm: 15,
      searchingProgressMessage: 'Evaluating candidate hospitals within 15km...',
      matches: MockHospitalData.standardCandidates,
      fixtureMode: MatchingFixtureMode.standardFive,
      activeFilter: 'ALL',
      hasSearched: true,
      isRealBackend: isRealBackend,
      dataSourceLabel: dataSourceLabel,
    );
  }

  /// Whether the radar / search progression animation is actively running.
  final bool isSearching;

  /// Current search radius boundary in kilometers (e.g. 5km, 10km, 15km).
  final int searchRadiusKm;

  /// Current contextual search progression message.
  final String searchingProgressMessage;

  /// Ranked candidate hospital matches.
  final List<HospitalMatch> matches;

  /// Current fixture scenario mode.
  final MatchingFixtureMode fixtureMode;

  /// Active filter criteria ('ALL', 'TOP_MATCH', 'LOW_LOAD', 'ICU_ONLY').
  final String activeFilter;

  /// Whether at least one search run has completed.
  final bool hasSearched;

  /// Whether candidate data was retrieved from the live Supabase backend.
  final bool isRealBackend;

  /// Human-readable data source label ('MOCK_FIXTURE' vs 'SUPABASE_CLOUD').
  final String dataSourceLabel;

  /// Optional error or diagnostic message (e.g. RLS blocked).
  final String? errorMessage;

  /// Whether queries to the live backend were blocked by Row-Level Security (default deny).
  final bool isRlsBlocked;

  /// Current GPS latitude of the searching ambulance unit.
  final double? ambulanceLatitude;

  /// Current GPS longitude of the searching ambulance unit.
  final double? ambulanceLongitude;

  /// List of requested clinical requirement codes that lack backend support.
  final List<String> unsupportedRequirements;

  /// Top recommended #1 candidate, if any.
  HospitalMatch? get primaryMatch => matches.isNotEmpty ? matches.first : null;

  /// Secondary ranked candidates (Rank #2..N).
  List<HospitalMatch> get secondaryMatches =>
      matches.length > 1 ? matches.sublist(1) : const [];

  /// Number of matching facilities found.
  int get totalMatchesCount => matches.length;

  /// Filtered list of candidate hospitals according to `activeFilter`.
  List<HospitalMatch> get filteredMatches {
    switch (activeFilter) {
      case 'TOP_MATCH':
        return matches
            .where((m) =>
                m.recommendationTier == RecommendationTier.topMatch ||
                m.recommendationTier == RecommendationTier.strongMatch)
            .toList();
      case 'LOW_LOAD':
        return matches
            .where((m) => m.occupancyRate < 70)
            .toList();
      case 'ICU_AVAILABLE':
        return matches
            .where((m) => m.getAvailableCount('icu_bed') > 0)
            .toList();
      case 'ALL':
      default:
        return matches;
    }
  }

  MatchingState copyWith({
    bool? isSearching,
    int? searchRadiusKm,
    String? searchingProgressMessage,
    List<HospitalMatch>? matches,
    MatchingFixtureMode? fixtureMode,
    String? activeFilter,
    bool? hasSearched,
    bool? isRealBackend,
    String? dataSourceLabel,
    String? errorMessage,
    bool? isRlsBlocked,
    double? ambulanceLatitude,
    double? ambulanceLongitude,
    List<String>? unsupportedRequirements,
  }) {
    return MatchingState(
      isSearching: isSearching ?? this.isSearching,
      searchRadiusKm: searchRadiusKm ?? this.searchRadiusKm,
      searchingProgressMessage:
          searchingProgressMessage ?? this.searchingProgressMessage,
      matches: matches ?? this.matches,
      fixtureMode: fixtureMode ?? this.fixtureMode,
      activeFilter: activeFilter ?? this.activeFilter,
      hasSearched: hasSearched ?? this.hasSearched,
      isRealBackend: isRealBackend ?? this.isRealBackend,
      dataSourceLabel: dataSourceLabel ?? this.dataSourceLabel,
      errorMessage: errorMessage ?? this.errorMessage,
      isRlsBlocked: isRlsBlocked ?? this.isRlsBlocked,
      ambulanceLatitude: ambulanceLatitude ?? this.ambulanceLatitude,
      ambulanceLongitude: ambulanceLongitude ?? this.ambulanceLongitude,
      unsupportedRequirements:
          unsupportedRequirements ?? this.unsupportedRequirements,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MatchingState &&
        other.isSearching == isSearching &&
        other.searchRadiusKm == searchRadiusKm &&
        other.searchingProgressMessage == searchingProgressMessage &&
        listEquals(other.matches, matches) &&
        other.fixtureMode == fixtureMode &&
        other.activeFilter == activeFilter &&
        other.hasSearched == hasSearched &&
        other.isRealBackend == isRealBackend &&
        other.dataSourceLabel == dataSourceLabel &&
        other.errorMessage == errorMessage &&
        other.isRlsBlocked == isRlsBlocked &&
        other.ambulanceLatitude == ambulanceLatitude &&
        other.ambulanceLongitude == ambulanceLongitude &&
        listEquals(other.unsupportedRequirements, unsupportedRequirements);
  }

  @override
  int get hashCode => Object.hash(
        isSearching,
        searchRadiusKm,
        searchingProgressMessage,
        Object.hashAll(matches),
        fixtureMode,
        activeFilter,
        hasSearched,
        isRealBackend,
        dataSourceLabel,
        errorMessage,
        isRlsBlocked,
        ambulanceLatitude,
        ambulanceLongitude,
        Object.hashAll(unsupportedRequirements),
      );
}

/// Riverpod Notifier orchestrating hospital discovery and match state.
class MatchingNotifier extends Notifier<MatchingState> {
  @override
  MatchingState build() {
    final repository = ref.watch(hospitalRepositoryProvider);
    return MatchingState.initial(
      isRealBackend: repository.isRealBackend,
      dataSourceLabel: repository.dataSourceName,
    );
  }

  /// Sets the fixture scenario mode (5 matches, 1 match, 0 matches) for testing & edge cases.
  void setFixtureMode(MatchingFixtureMode mode) {
    List<HospitalMatch> targetMatches;
    switch (mode) {
      case MatchingFixtureMode.standardFive:
        targetMatches = MockHospitalData.standardCandidates;
        break;
      case MatchingFixtureMode.singleMatch:
        targetMatches = MockHospitalData.singleCandidate;
        break;
      case MatchingFixtureMode.noMatches:
        targetMatches = MockHospitalData.noCandidates;
        break;
    }

    state = state.copyWith(
      fixtureMode: mode,
      matches: targetMatches,
    );
  }

  /// Triggers searching progression across radius thresholds (5km -> 10km -> 15km).
  ///
  /// When backed by [SupabaseHospitalRepository], loads real hospital facilities.
  /// If blocked by RLS (0 policies default-deny), gracefully falls back to mock candidates
  /// and marks [MatchingState.isRlsBlocked] without crashing.
  Future<void> runSearchProgression({
    Duration stepDuration = const Duration(milliseconds: 600),
  }) async {
    state = state.copyWith(
      isSearching: true,
      searchRadiusKm: 5,
      searchingProgressMessage: 'Scanning immediate 5km radius for ICU beds...',
      hasSearched: false,
    );

    if (stepDuration > Duration.zero) {
      await Future<void>.delayed(stepDuration);
      if (!state.isSearching) return;
    }

    state = state.copyWith(
      searchRadiusKm: 10,
      searchingProgressMessage: 'Expanding discovery to 10km radius...',
    );

    if (stepDuration > Duration.zero) {
      await Future<void>.delayed(stepDuration);
      if (!state.isSearching) return;
    }

    state = state.copyWith(
      searchRadiusKm: 15,
      searchingProgressMessage: 'Evaluating candidate road travel times...',
    );

    if (stepDuration > Duration.zero) {
      await Future<void>.delayed(stepDuration);
      if (!state.isSearching) return;
    }

    final repository = ref.read(hospitalRepositoryProvider);
    final discoveryRepo = ref.read(hospitalDiscoveryRepositoryProvider);

    // Get current ambulance coordinates or fallback to default
    final locState = ref.read(ambulanceLocationProvider);
    final lat = locState.location?.latitude ?? AmbulanceLocation.defaultMumbaiLat;
    final lon = locState.location?.longitude ?? AmbulanceLocation.defaultMumbaiLng;

    // Read active patient clinical requirements
    final reqState = ref.read(bedRequirementProvider);

    // If using real backend and in standard mode, run real hospital discovery
    if (state.fixtureMode == MatchingFixtureMode.standardFive && repository.isRealBackend) {
      final result = await discoveryRepo.discoverHospitals(
        latitude: lat,
        longitude: lon,
        selectedRequirements: reqState.selectedRequirements,
      );

      if (result.isRlsBlocked) {
        state = state.copyWith(
          isSearching: false,
          searchRadiusKm: 15,
          searchingProgressMessage: 'Supabase RLS default-deny active. Showing mock fallback.',
          matches: MockHospitalData.standardCandidates,
          hasSearched: true,
          isRealBackend: true,
          dataSourceLabel: repository.dataSourceName,
          isRlsBlocked: true,
          errorMessage: 'Supabase RLS is enabled with 0 policies on public.hospitals (default deny). Approval of a safe client SELECT policy is required to read live data directly from Flutter.',
          ambulanceLatitude: lat,
          ambulanceLongitude: lon,
          unsupportedRequirements: result.unsupportedRequirementsRequested,
        );
        return;
      }

      if (result.matches.isNotEmpty) {
        state = state.copyWith(
          isSearching: false,
          searchRadiusKm: result.effectiveRadiusKm,
          searchingProgressMessage: '${result.matches.length} Mumbai hospitals matched within ${result.effectiveRadiusKm}km',
          matches: result.matches,
          hasSearched: true,
          isRealBackend: true,
          dataSourceLabel: repository.dataSourceName,
          isRlsBlocked: false,
          errorMessage: null,
          ambulanceLatitude: lat,
          ambulanceLongitude: lon,
          unsupportedRequirements: result.unsupportedRequirementsRequested,
        );
        return;
      } else {
        // Zero records returned: likely default-deny RLS or empty table
        state = state.copyWith(
          isSearching: false,
          searchRadiusKm: result.effectiveRadiusKm,
          searchingProgressMessage: 'Supabase returned 0 records (RLS default-deny active). Showing mock fallback.',
          matches: MockHospitalData.standardCandidates,
          hasSearched: true,
          isRealBackend: true,
          dataSourceLabel: repository.dataSourceName,
          isRlsBlocked: true,
          errorMessage: result.errorMessage ?? 'Supabase RLS is enabled with 0 policies on public.hospitals (default deny). Approval of a safe client SELECT policy is required to read live data directly from Flutter.',
          ambulanceLatitude: lat,
          ambulanceLongitude: lon,
          unsupportedRequirements: result.unsupportedRequirementsRequested,
        );
        return;
      }
    }

    // Resolve candidates based on active fixture
    List<HospitalMatch> resolved;
    switch (state.fixtureMode) {
      case MatchingFixtureMode.standardFive:
        resolved = MockHospitalData.standardCandidates;
        break;
      case MatchingFixtureMode.singleMatch:
        resolved = MockHospitalData.singleCandidate;
        break;
      case MatchingFixtureMode.noMatches:
        resolved = MockHospitalData.noCandidates;
        break;
    }

    state = state.copyWith(
      isSearching: false,
      searchRadiusKm: 15,
      searchingProgressMessage: '${resolved.length} candidates ranked by road ETA & capacity',
      matches: resolved,
      hasSearched: true,
      isRealBackend: repository.isRealBackend,
      dataSourceLabel: repository.dataSourceName,
      ambulanceLatitude: lat,
      ambulanceLongitude: lon,
    );
  }

  /// Instantly finishes search without delay (ideal for deterministic unit/widget tests).
  void completeSearchInstantaneously({List<HospitalMatch>? overrideMatches}) {
    final resolved = overrideMatches ??
        (state.fixtureMode == MatchingFixtureMode.noMatches
            ? MockHospitalData.noCandidates
            : state.fixtureMode == MatchingFixtureMode.singleMatch
                ? MockHospitalData.singleCandidate
                : MockHospitalData.standardCandidates);

    final repository = ref.read(hospitalRepositoryProvider);

    state = state.copyWith(
      isSearching: false,
      searchRadiusKm: 15,
      searchingProgressMessage: '${resolved.length} candidates ranked by road ETA & capacity',
      matches: resolved,
      hasSearched: true,
      isRealBackend: repository.isRealBackend,
      dataSourceLabel: repository.dataSourceName,
    );
  }

  /// Sets an active category filter ('ALL', 'TOP_MATCH', 'LOW_LOAD', 'ICU_AVAILABLE').
  void setFilter(String filter) {
    state = state.copyWith(activeFilter: filter);
  }

  /// Expands search radius manually to next tier.
  void expandRadius(int radiusKm) {
    state = state.copyWith(searchRadiusKm: radiusKm);
  }

  /// Resets matching state to initial defaults.
  void reset() {
    final repository = ref.read(hospitalRepositoryProvider);
    state = MatchingState.initial(
      isRealBackend: repository.isRealBackend,
      dataSourceLabel: repository.dataSourceName,
    );
  }
}

/// Global provider for matching and hospital discovery state.
final matchingProvider =
    NotifierProvider<MatchingNotifier, MatchingState>(
  MatchingNotifier.new,
);
