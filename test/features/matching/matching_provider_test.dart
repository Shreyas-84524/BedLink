import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/core/theme/semantic_tokens.dart';
import 'package:bedlink/features/matching/data/mock_hospital_data.dart';
import 'package:bedlink/features/matching/domain/models/hospital_match.dart';
import 'package:bedlink/features/matching/presentation/providers/matching_provider.dart';
import 'package:bedlink/features/matching/presentation/providers/selected_hospital_provider.dart';

void main() {
  group('MockHospitalData Invariants & Domain Tests (Sub-phases 6.3 - 6.7)', () {
    test('Standard dataset contains 5 unique, valid Mumbai hospitals', () {
      const hospitals = MockHospitalData.standardCandidates;
      expect(hospitals.length, equals(5));

      final ids = hospitals.map((h) => h.id).toSet();
      expect(ids.length, equals(5));

      for (var i = 0; i < hospitals.length; i++) {
        expect(hospitals[i].rank, equals(i + 1));
      }
    });

    test('#1 Top Match is KEM Hospital with fastest ETA and high score', () {
      const kem = MockHospitalData.kemHospital;
      expect(kem.id, equals('kem_parel'));
      expect(kem.name, contains('King Edward Memorial Hospital'));
      expect(kem.rank, equals(1));
      expect(kem.etaMinutes, equals(8));
      expect(kem.distanceKm, equals(3.8));
      expect(kem.freshnessState, equals(FreshnessState.fresh));
      expect(kem.recommendationTier, equals(RecommendationTier.topMatch));
      expect(kem.matchScore, greaterThan(90.0));
      expect(kem.getAvailableCount('icu_bed'), equals(3));
      expect(kem.getAvailableCount('ventilator'), equals(2));
      expect(kem.hasCapability('cardiac_care'), isTrue);
      expect(kem.freshnessDisplayText, contains('Updated 2 min ago'));
    });

    test('#4 Hospital (Sion) is flagged with divert risk and high load', () {
      const sion = MockHospitalData.sionHospital;
      expect(sion.id, equals('sion_hospital'));
      expect(sion.rank, equals(4));
      expect(sion.loadState, equals(HospitalLoadState.high));
      expect(sion.occupancyRate, equals(94));
      expect(sion.recommendationTier.isDivertRisk, isTrue);
    });

    test('#5 Hospital (Tata Memorial) has stale data and incompatible resources', () {
      const tata = MockHospitalData.tataMemorialHospital;
      expect(tata.id, equals('tata_memorial'));
      expect(tata.rank, equals(5));
      expect(tata.freshnessState, equals(FreshnessState.stale));
      expect(tata.updatedMinutesAgo, greaterThan(30));
      expect(tata.getAvailableCount('icu_bed'), equals(0));
      expect(tata.recommendationTier.isIncompatible, isTrue);
    });
  });

  group('MatchingNotifier & Provider State Tests (Sub-phases 6.1 & 6.8)', () {
    test('Initial state provides 5 standard candidates within 15km', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(matchingProvider);
      expect(state.matches.length, equals(5));
      expect(state.searchRadiusKm, equals(15));
      expect(state.primaryMatch?.id, equals('kem_parel'));
      expect(state.secondaryMatches.length, equals(4));
      expect(state.isSearching, isFalse);
    });

    test('Setting fixture mode to singleMatch updates matches to 1', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchingProvider.notifier);
      notifier.setFixtureMode(MatchingFixtureMode.singleMatch);

      final state = container.read(matchingProvider);
      expect(state.fixtureMode, equals(MatchingFixtureMode.singleMatch));
      expect(state.matches.length, equals(1));
      expect(state.primaryMatch?.id, equals('kem_parel'));
      expect(state.secondaryMatches, isEmpty);
    });

    test('Setting fixture mode to noMatches updates matches to empty list', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchingProvider.notifier);
      notifier.setFixtureMode(MatchingFixtureMode.noMatches);

      final state = container.read(matchingProvider);
      expect(state.fixtureMode, equals(MatchingFixtureMode.noMatches));
      expect(state.matches, isEmpty);
      expect(state.primaryMatch, isNull);
    });

    test('runSearchProgression updates radius and completes without error', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchingProvider.notifier);
      await notifier.runSearchProgression(stepDuration: Duration.zero);

      final state = container.read(matchingProvider);
      expect(state.isSearching, isFalse);
      expect(state.hasSearched, isTrue);
      expect(state.searchRadiusKm, equals(15));
      expect(state.matches.length, equals(5));
    });

    test('Category filtering narrows candidates correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(matchingProvider.notifier);

      notifier.setFilter('LOW_LOAD');
      var state = container.read(matchingProvider);
      expect(state.filteredMatches.every((m) => m.occupancyRate < 70), isTrue);

      notifier.setFilter('ICU_AVAILABLE');
      state = container.read(matchingProvider);
      expect(state.filteredMatches.every((m) => m.getAvailableCount('icu_bed') > 0), isTrue);
    });
  });

  group('SelectedHospitalNotifier Tests', () {
    test('Selects and clears hospital candidate cleanly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(selectedHospitalProvider), isNull);

      const kem = MockHospitalData.kemHospital;
      container.read(selectedHospitalProvider.notifier).selectHospital(kem);
      expect(container.read(selectedHospitalProvider)?.id, equals('kem_parel'));

      container.read(selectedHospitalProvider.notifier).clearSelection();
      expect(container.read(selectedHospitalProvider), isNull);
    });
  });
}
