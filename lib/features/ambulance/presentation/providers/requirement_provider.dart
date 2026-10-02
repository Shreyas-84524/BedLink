import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/bed_requirement_state.dart';
import '../../domain/models/clinical_resource_catalogue.dart';

/// Riverpod Notifier managing clinical resource and bed requirement selection for ambulance dispatch.
class BedRequirementNotifier extends Notifier<BedRequirementState> {
  @override
  BedRequirementState build() {
    return BedRequirementState.initial();
  }

  /// Adds a resource or sets its quantity.
  void addResource(String resourceId, {int quantity = 1}) {
    final resource = ClinicalResourceCatalogue.findById(resourceId);
    if (resource == null) return;

    final updated = Map<String, int>.from(state.selectedRequirements);
    final effectiveQty = resource.isCountable ? quantity.clamp(1, 5) : 1;
    updated[resourceId] = effectiveQty;

    state = state.copyWith(selectedRequirements: updated);
  }

  /// Toggles selection of a clinical resource.
  void toggleResource(String resourceId) {
    if (state.isSelected(resourceId)) {
      removeResource(resourceId);
    } else {
      addResource(resourceId);
    }
  }

  /// Removes a resource from the active requirement list.
  void removeResource(String resourceId) {
    if (!state.selectedRequirements.containsKey(resourceId)) return;

    final updated = Map<String, int>.from(state.selectedRequirements)..remove(resourceId);
    state = state.copyWith(selectedRequirements: updated);
  }

  /// Updates quantity for a countable bed/equipment (clamped between 1 and 5).
  void updateQuantity(String resourceId, int quantity) {
    final resource = ClinicalResourceCatalogue.findById(resourceId);
    if (resource == null || !resource.isCountable) return;

    if (quantity <= 0) {
      removeResource(resourceId);
      return;
    }

    final updated = Map<String, int>.from(state.selectedRequirements);
    updated[resourceId] = quantity.clamp(1, 5);
    state = state.copyWith(selectedRequirements: updated);
  }

  /// Increments quantity for a countable bed/equipment up to a maximum of 5.
  void incrementQuantity(String resourceId) {
    final current = state.getQuantity(resourceId);
    if (current < 5) {
      updateQuantity(resourceId, current + 1);
    }
  }

  /// Decrements quantity for a countable bed/equipment down to 1 (or removes if already 1).
  void decrementQuantity(String resourceId) {
    final current = state.getQuantity(resourceId);
    if (current > 1) {
      updateQuantity(resourceId, current - 1);
    } else {
      removeResource(resourceId);
    }
  }

  /// Applies an emergency preset bundle, setting exact clinical requirements.
  void applyPreset(String presetId) {
    for (final preset in ClinicalResourceCatalogue.presets) {
      if (preset.id == presetId) {
        state = state.copyWith(
          selectedRequirements: Map<String, int>.from(preset.requirements),
        );
        return;
      }
    }
  }

  /// Clears all currently selected clinical requirements.
  void clearAll() {
    state = state.copyWith(selectedRequirements: const {});
  }

  /// Updates the search filter query string.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clears the active search query.
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

/// Global provider for the active clinical bed and capability requirements state.
final bedRequirementProvider =
    NotifierProvider<BedRequirementNotifier, BedRequirementState>(
  BedRequirementNotifier.new,
);
