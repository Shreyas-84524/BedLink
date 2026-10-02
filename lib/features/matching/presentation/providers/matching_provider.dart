import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_hospital_data.dart';
import '../../domain/models/hospital_match.dart';

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
  });

  /// Initial state: ready with standard candidates or auto-searching.
  factory MatchingState.initial({bool startSearching = false}) {
    return MatchingState(
      isSearching: startSearching,
      searchRadiusKm: 15,
      searchingProgressMessage: 'Evaluating candidate hospitals within 15km...',
      matches: MockHospitalData.standardCandidates,
      fixtureMode: MatchingFixtureMode.standardFive,
      activeFilter: 'ALL',
      hasSearched: true,
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
        other.hasSearched == hasSearched;
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
      );
}

/// Riverpod Notifier orchestrating hospital discovery and match state.
class MatchingNotifier extends Notifier<MatchingState> {
  @override
  MatchingState build() {
    return MatchingState.initial();
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

  /// Triggers simulated searching progression across radius thresholds (5km -> 10km -> 15km).
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
      searchingProgressMessage: 'Evaluating Hinduja, KEM, Lilavati road travel times...',
    );

    if (stepDuration > Duration.zero) {
      await Future<void>.delayed(stepDuration);
      if (!state.isSearching) return;
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

    state = state.copyWith(
      isSearching: false,
      searchRadiusKm: 15,
      searchingProgressMessage: '${resolved.length} candidates ranked by road ETA & capacity',
      matches: resolved,
      hasSearched: true,
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
    state = MatchingState.initial();
  }
}

/// Global provider for matching and hospital discovery state.
final matchingProvider =
    NotifierProvider<MatchingNotifier, MatchingState>(
  MatchingNotifier.new,
);
