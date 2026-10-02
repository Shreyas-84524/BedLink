import 'package:flutter/foundation.dart';
import 'clinical_resource.dart';
import 'clinical_resource_catalogue.dart';

/// Immutable domain state representing clinical bed and capability requirements for discovery.
@immutable
class BedRequirementState {
  const BedRequirementState({
    required this.selectedRequirements,
    required this.searchQuery,
  });

  /// Initial empty requirement state.
  factory BedRequirementState.initial() {
    return const BedRequirementState(
      selectedRequirements: {},
      searchQuery: '',
    );
  }

  /// Map of resource code (e.g., 'icu_bed') to requested quantity (1..5).
  /// For care capabilities, quantity is canonically stored as 1.
  final Map<String, int> selectedRequirements;

  /// Current text in the search input field.
  final String searchQuery;

  /// Returns whether a given resource is in the active requirement set.
  bool isSelected(String resourceId) => selectedRequirements.containsKey(resourceId);

  /// Quantity for a given resource, or 0 if not selected.
  int getQuantity(String resourceId) => selectedRequirements[resourceId] ?? 0;

  /// Number of distinct requirements selected.
  int get selectedCount => selectedRequirements.length;

  /// Whether any countable bed/equipment resource is selected with quantity >= 1.
  bool get hasCountableBed {
    for (final entry in selectedRequirements.entries) {
      final resource = ClinicalResourceCatalogue.findById(entry.key);
      if (resource != null && resource.isCountable && entry.value >= 1) {
        return true;
      }
    }
    return false;
  }

  /// Total units across all countable beds requested.
  int get totalCountableQuantity {
    var sum = 0;
    for (final entry in selectedRequirements.entries) {
      final resource = ClinicalResourceCatalogue.findById(entry.key);
      if (resource != null && resource.isCountable) {
        sum += entry.value;
      }
    }
    return sum;
  }

  /// Hard BedLink validation rule: at least one countable bed or equipment resource is mandatory.
  /// Selecting only care capabilities (e.g. 'cardiac_care' alone) fails validation.
  bool get isValid => hasCountableBed;

  /// Human-readable validation error messages.
  List<String> get validationErrors {
    final errors = <String>[];
    if (selectedRequirements.isEmpty) {
      errors.add('Select at least one bed or equipment resource to search.');
    } else if (!hasCountableBed) {
      errors.add('At least one countable bed or equipment (e.g. ICU Bed, Emergency Bed) is required.');
    }
    return errors;
  }

  /// Active resources as ClinicalResource objects.
  List<ClinicalResource> get selectedResources {
    return selectedRequirements.keys
        .map(ClinicalResourceCatalogue.findById)
        .whereType<ClinicalResource>()
        .toList(growable: false);
  }

  /// Dynamic search results based on current search query.
  List<ClinicalResource> get searchResults =>
      ClinicalResourceCatalogue.search(searchQuery);

  BedRequirementState copyWith({
    Map<String, int>? selectedRequirements,
    String? searchQuery,
  }) {
    return BedRequirementState(
      selectedRequirements: selectedRequirements ?? this.selectedRequirements,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BedRequirementState &&
        mapEquals(other.selectedRequirements, selectedRequirements) &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(selectedRequirements.entries),
        searchQuery,
      );

  @override
  String toString() =>
      'BedRequirementState(selected: $selectedRequirements, query: "$searchQuery", valid: $isValid)';
}
