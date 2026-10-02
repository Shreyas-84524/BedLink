import 'package:flutter/material.dart';

/// Distinguishes physical countable hospital assets (beds, ventilators) from clinical specializations.
enum ClinicalResourceCategory {
  /// Physical bed or critical care equipment with unit counts (e.g. ICU bed, ventilator).
  countableBed,

  /// Medical specialty, surgical capability, or dedicated unit (e.g. Cath Lab, Trauma Care).
  careCapability,
}

/// Standardized domain model representing a clinical bed, equipment, or hospital capability.
@immutable
class ClinicalResource {
  const ClinicalResource({
    required this.id,
    required this.name,
    required this.shortLabel,
    required this.description,
    required this.category,
    required this.icon,
    required this.searchKeywords,
  });

  /// Canonical database code matching BedLink architecture schema (e.g., 'icu_bed', 'cardiac_care').
  final String id;

  /// Full descriptive title (e.g., 'Intensive Care Unit (ICU) Bed').
  final String name;

  /// High-visibility short label for chips and badges (e.g., 'ICU Bed').
  final String shortLabel;

  /// Operational context explaining triage indication.
  final String description;

  /// Classification (countable vs care capability).
  final ClinicalResourceCategory category;

  /// Material icon representing the resource.
  final IconData icon;

  /// Keywords for instant fuzzy/sub-string search matching.
  final List<String> searchKeywords;

  /// Whether this resource requires a numeric quantity (>= 1).
  bool get isCountable => category == ClinicalResourceCategory.countableBed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClinicalResource && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ClinicalResource($id: $name, countable=$isCountable)';
}
