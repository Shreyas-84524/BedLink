import 'package:bedlink/features/ambulance/domain/models/bed_requirement_state.dart';
import 'package:bedlink/features/ambulance/domain/models/clinical_resource_catalogue.dart';
import 'package:bedlink/features/ambulance/presentation/providers/requirement_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Clinical Resource Catalogue Tests (Sub-phase 5.6)', () {
    test('contains all canonical MVP resources with correct classifications', () {
      const all = ClinicalResourceCatalogue.allResources;
      expect(all.length, greaterThanOrEqualTo(10));

      final countable = ClinicalResourceCatalogue.countableBeds;
      final capabilities = ClinicalResourceCatalogue.careCapabilities;

      expect(countable.map((r) => r.id), containsAll([
        'icu_bed',
        'ventilator',
        'oxygen_bed',
        'emergency_bed',
        'general_bed',
        'pediatric_icu_bed',
      ]));

      expect(capabilities.map((r) => r.id), containsAll([
        'cardiac_care',
        'trauma_care',
        'burns_care',
        'pediatric_icu_care',
      ]));

      for (final bed in countable) {
        expect(bed.isCountable, isTrue);
      }
      for (final cap in capabilities) {
        expect(cap.isCountable, isFalse);
      }
    });

    test('instant search filters correctly across keywords and names', () {
      final ventSearch = ClinicalResourceCatalogue.search('vent');
      expect(ventSearch.any((r) => r.id == 'ventilator'), isTrue);

      final cardiacSearch = ClinicalResourceCatalogue.search('cath');
      expect(cardiacSearch.any((r) => r.id == 'cardiac_care'), isTrue);

      final emptyQuery = ClinicalResourceCatalogue.search('');
      expect(emptyQuery.length, equals(ClinicalResourceCatalogue.allResources.length));
    });

    test('suggests relevant resources based on chief complaints (Sub-phase 5.3)', () {
      final cardiacSuggestions =
          ClinicalResourceCatalogue.suggestForComplaint('Acute STEMI and chest pain');
      expect(cardiacSuggestions.map((r) => r.id), containsAll(['icu_bed', 'cardiac_care']));

      final traumaSuggestions =
          ClinicalResourceCatalogue.suggestForComplaint('Road traffic accident polytrauma');
      expect(traumaSuggestions.map((r) => r.id), containsAll(['emergency_bed', 'icu_bed', 'trauma_care']));

      final respSuggestions =
          ClinicalResourceCatalogue.suggestForComplaint('Severe respiratory failure');
      expect(respSuggestions.map((r) => r.id), containsAll(['ventilator', 'oxygen_bed']));

      final pedsSuggestions =
          ClinicalResourceCatalogue.suggestForComplaint('Pediatric febrile seizure');
      expect(pedsSuggestions.map((r) => r.id), containsAll(['pediatric_icu_bed', 'pediatric_icu_care']));
    });

    test('emergency preset bundles are fully defined with valid resources (Sub-phase 5.5)', () {
      const presets = ClinicalResourceCatalogue.presets;
      expect(presets.length, equals(4));

      for (final bundle in presets) {
        expect(bundle.requirements, isNotEmpty);
        var hasCountable = false;
        for (final entry in bundle.requirements.entries) {
          final resource = ClinicalResourceCatalogue.findById(entry.key);
          expect(resource, isNotNull, reason: 'Preset resource ${entry.key} must exist');
          if (resource!.isCountable) hasCountable = true;
        }
        expect(hasCountable, isTrue, reason: 'Preset ${bundle.id} must include at least 1 countable bed');
      }
    });
  });

  group('Bed Requirement State & Validation Tests (Sub-phase 5.7)', () {
    test('initial state is empty and invalid', () {
      final state = BedRequirementState.initial();
      expect(state.selectedRequirements, isEmpty);
      expect(state.hasCountableBed, isFalse);
      expect(state.isValid, isFalse);
      expect(state.validationErrors, contains('Select at least one bed or equipment resource to search.'));
    });

    test('selecting ONLY care capabilities fails validation (Mandatory BedLink Rule)', () {
      const state = BedRequirementState(
        selectedRequirements: {
          'cardiac_care': 1,
          'trauma_care': 1,
        },
        searchQuery: '',
      );

      expect(state.hasCountableBed, isFalse);
      expect(state.isValid, isFalse);
      expect(
        state.validationErrors,
        contains('At least one countable bed or equipment (e.g. ICU Bed, Emergency Bed) is required.'),
      );
    });

    test('selecting countable bed satisfies validation', () {
      const state = BedRequirementState(
        selectedRequirements: {
          'icu_bed': 1,
        },
        searchQuery: '',
      );

      expect(state.hasCountableBed, isTrue);
      expect(state.isValid, isTrue);
      expect(state.validationErrors, isEmpty);
      expect(state.totalCountableQuantity, equals(1));
    });

    test('selecting both countable bed and care capability is valid', () {
      const state = BedRequirementState(
        selectedRequirements: {
          'icu_bed': 2,
          'cardiac_care': 1,
        },
        searchQuery: '',
      );

      expect(state.hasCountableBed, isTrue);
      expect(state.isValid, isTrue);
      expect(state.totalCountableQuantity, equals(2));
      expect(state.selectedCount, equals(2));
    });
  });

  group('BedRequirementNotifier Tests (Sub-phase 5.7)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('adds, increments, decrements, and removes countable resources', () {
      final notifier = container.read(bedRequirementProvider.notifier);

      expect(container.read(bedRequirementProvider).isValid, isFalse);

      notifier.addResource('icu_bed', quantity: 1);
      expect(container.read(bedRequirementProvider).getQuantity('icu_bed'), equals(1));
      expect(container.read(bedRequirementProvider).isValid, isTrue);

      notifier.incrementQuantity('icu_bed');
      expect(container.read(bedRequirementProvider).getQuantity('icu_bed'), equals(2));

      notifier.decrementQuantity('icu_bed');
      expect(container.read(bedRequirementProvider).getQuantity('icu_bed'), equals(1));

      notifier.decrementQuantity('icu_bed');
      expect(container.read(bedRequirementProvider).isSelected('icu_bed'), isFalse);
      expect(container.read(bedRequirementProvider).isValid, isFalse);
    });

    test('clamps countable quantity between 1 and 5', () {
      final notifier = container.read(bedRequirementProvider.notifier);

      notifier.addResource('icu_bed', quantity: 99);
      expect(container.read(bedRequirementProvider).getQuantity('icu_bed'), equals(5));

      notifier.incrementQuantity('icu_bed');
      expect(container.read(bedRequirementProvider).getQuantity('icu_bed'), equals(5));
    });

    test('toggles care capability cleanly', () {
      final notifier = container.read(bedRequirementProvider.notifier);

      notifier.toggleResource('cardiac_care');
      expect(container.read(bedRequirementProvider).isSelected('cardiac_care'), isTrue);

      notifier.toggleResource('cardiac_care');
      expect(container.read(bedRequirementProvider).isSelected('cardiac_care'), isFalse);
    });

    test('applies emergency preset bundle correctly', () {
      final notifier = container.read(bedRequirementProvider.notifier);

      notifier.applyPreset('cardiac_emergency');
      final state = container.read(bedRequirementProvider);

      expect(state.isSelected('icu_bed'), isTrue);
      expect(state.isSelected('cardiac_care'), isTrue);
      expect(state.isValid, isTrue);
    });

    test('clearAll resets all active requirements', () {
      final notifier = container.read(bedRequirementProvider.notifier);

      notifier.applyPreset('polytrauma_icu');
      expect(container.read(bedRequirementProvider).selectedCount, greaterThan(0));

      notifier.clearAll();
      expect(container.read(bedRequirementProvider).selectedRequirements, isEmpty);
      expect(container.read(bedRequirementProvider).isValid, isFalse);
    });

    test('updates and clears search query', () {
      final notifier = container.read(bedRequirementProvider.notifier);

      notifier.setSearchQuery('oxygen');
      expect(container.read(bedRequirementProvider).searchQuery, equals('oxygen'));
      expect(
        container.read(bedRequirementProvider).searchResults.map((r) => r.id),
        contains('oxygen_bed'),
      );

      notifier.clearSearch();
      expect(container.read(bedRequirementProvider).searchQuery, isEmpty);
    });
  });
}
