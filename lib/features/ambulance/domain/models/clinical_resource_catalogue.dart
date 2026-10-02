import 'package:flutter/material.dart';
import 'clinical_resource.dart';

/// Predefined one-tap clinical bundle for high-acuity emergency dispatches.
@immutable
class EmergencyPresetBundle {
  const EmergencyPresetBundle({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.requirements,
  });

  final String id;
  final String name;
  final String subtitle;
  final IconData icon;

  /// Map of resource ID to quantity (for countable resources) or 1 (for care capabilities).
  final Map<String, int> requirements;
}

/// Official catalogue and query service for BedLink standard clinical resources.
class ClinicalResourceCatalogue {
  const ClinicalResourceCatalogue._();

  // ---------------------------------------------------------------------------
  // Canonical Resources
  // ---------------------------------------------------------------------------

  static const ClinicalResource icuBed = ClinicalResource(
    id: 'icu_bed',
    name: 'Intensive Care Unit (ICU) Bed',
    shortLabel: 'ICU Bed',
    description: 'Critical care bed with full invasive hemodynamic monitoring and dedicated nurse.',
    category: ClinicalResourceCategory.countableBed,
    icon: Icons.single_bed_rounded,
    searchKeywords: ['icu', 'intensive', 'critical', 'life support', 'monitor', 'bed'],
  );

  static const ClinicalResource ventilator = ClinicalResource(
    id: 'ventilator',
    name: 'Mechanical Ventilator',
    shortLabel: 'Ventilator',
    description: 'Invasive/non-invasive mechanical ventilation unit for respiratory compromise.',
    category: ClinicalResourceCategory.countableBed,
    icon: Icons.air_rounded,
    searchKeywords: ['ventilator', 'vent', 'intubation', 'respiratory', 'breathing', 'bipap'],
  );

  static const ClinicalResource oxygenBed = ClinicalResource(
    id: 'oxygen_bed',
    name: 'High-Flow Oxygen Bed',
    shortLabel: 'Oxygen Bed',
    description: 'Step-down acute bed with central high-flow oxygen supply and continuous oximetry.',
    category: ClinicalResourceCategory.countableBed,
    icon: Icons.masks_rounded,
    searchKeywords: ['oxygen', 'o2', 'hypoxia', 'stepdown', 'respiratory', 'bed'],
  );

  static const ClinicalResource emergencyBed = ClinicalResource(
    id: 'emergency_bed',
    name: 'Emergency / Trauma Bay',
    shortLabel: 'Emergency Bed',
    description: 'Resuscitation bay in the Emergency Department for acute stabilization.',
    category: ClinicalResourceCategory.countableBed,
    icon: Icons.emergency_rounded,
    searchKeywords: ['emergency', 'ed', 'casualty', 'triage', 'resuscitation', 'er', 'bed'],
  );

  static const ClinicalResource generalBed = ClinicalResource(
    id: 'general_bed',
    name: 'General Medical Ward Bed',
    shortLabel: 'General Bed',
    description: 'Inpatient ward bed for non-critical admissions and stable observation.',
    category: ClinicalResourceCategory.countableBed,
    icon: Icons.hotel_rounded,
    searchKeywords: ['general', 'ward', 'inpatient', 'stable', 'observation', 'bed'],
  );

  static const ClinicalResource pediatricIcuBed = ClinicalResource(
    id: 'pediatric_icu_bed',
    name: 'Pediatric ICU (PICU) Bed',
    shortLabel: 'PICU Bed',
    description: 'Specialized intensive care bed calibrated for infants and children under 18.',
    category: ClinicalResourceCategory.countableBed,
    icon: Icons.child_care_rounded,
    searchKeywords: ['pediatric', 'picu', 'child', 'infant', 'nicu', 'kid', 'baby', 'bed'],
  );

  static const ClinicalResource cardiacCare = ClinicalResource(
    id: 'cardiac_care',
    name: 'Interventional Cardiology / Cath Lab',
    shortLabel: 'Cath Lab / CCU',
    description: '24/7 cardiac catheterization laboratory with emergency angioplasty capability.',
    category: ClinicalResourceCategory.careCapability,
    icon: Icons.favorite_rounded,
    searchKeywords: ['cardiac', 'heart', 'cath lab', 'stemi', 'angioplasty', 'ccu', 'chest pain', 'mi'],
  );

  static const ClinicalResource traumaCare = ClinicalResource(
    id: 'trauma_care',
    name: 'Level 1 Trauma Surgery',
    shortLabel: 'Trauma Surgery',
    description: 'Immediate operative surgical capability with neurosurgery and orthopedic trauma teams.',
    category: ClinicalResourceCategory.careCapability,
    icon: Icons.healing_rounded,
    searchKeywords: ['trauma', 'polytrauma', 'accident', 'surgery', 'ortho', 'hemorrhage', 'fracture'],
  );

  static const ClinicalResource burnsCare = ClinicalResource(
    id: 'burns_care',
    name: 'Dedicated Burns Care Unit',
    shortLabel: 'Burns Unit',
    description: 'Sterile isolation unit specialized in severe thermal/chemical inhalation injuries.',
    category: ClinicalResourceCategory.careCapability,
    icon: Icons.local_fire_department_rounded,
    searchKeywords: ['burn', 'burns', 'thermal', 'inhalation', 'chemical', 'scald'],
  );

  static const ClinicalResource pediatricIcuCare = ClinicalResource(
    id: 'pediatric_icu_care',
    name: 'Pediatric Intensivist On Duty',
    shortLabel: 'Pediatric Intensivist',
    description: 'Board-certified pediatric intensivist and neonatal emergency resuscitation team.',
    category: ClinicalResourceCategory.careCapability,
    icon: Icons.escalator_warning_rounded,
    searchKeywords: ['pediatric', 'intensivist', 'specialist', 'children', 'infant', 'neonatal'],
  );

  /// Complete list of standard BedLink clinical resources.
  static const List<ClinicalResource> allResources = [
    icuBed,
    ventilator,
    oxygenBed,
    emergencyBed,
    generalBed,
    pediatricIcuBed,
    cardiacCare,
    traumaCare,
    burnsCare,
    pediatricIcuCare,
  ];

  /// Countable resources (beds, mechanical ventilators).
  static List<ClinicalResource> get countableBeds =>
      allResources.where((r) => r.isCountable).toList(growable: false);

  /// Hospital care capabilities (specialties, catheterization labs, trauma suites).
  static List<ClinicalResource> get careCapabilities =>
      allResources.where((r) => !r.isCountable).toList(growable: false);

  /// Find a resource by its canonical ID.
  static ClinicalResource? findById(String id) {
    for (final resource in allResources) {
      if (resource.id == id) return resource;
    }
    return null;
  }

  /// Instant search matching name, shortLabel, description, or search keywords.
  static List<ClinicalResource> search(String query) {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return allResources;

    return allResources.where((resource) {
      if (resource.name.toLowerCase().contains(clean)) return true;
      if (resource.shortLabel.toLowerCase().contains(clean)) return true;
      if (resource.description.toLowerCase().contains(clean)) return true;
      if (resource.searchKeywords.any((k) => k.toLowerCase().contains(clean))) return true;
      return false;
    }).toList(growable: false);
  }

  /// Suggests appropriate clinical resources based on the active patient's chief complaint.
  static List<ClinicalResource> suggestForComplaint(String complaint) {
    final clean = complaint.trim().toLowerCase();
    if (clean.isEmpty) return [];

    final suggestions = <ClinicalResource>{};

    if (clean.contains('cardiac') ||
        clean.contains('chest pain') ||
        clean.contains('stemi') ||
        clean.contains('heart') ||
        clean.contains('ecg')) {
      suggestions.add(icuBed);
      suggestions.add(cardiacCare);
    }

    if (clean.contains('trauma') ||
        clean.contains('accident') ||
        clean.contains('polytrauma') ||
        clean.contains('fracture') ||
        clean.contains('fall')) {
      suggestions.add(emergencyBed);
      suggestions.add(icuBed);
      suggestions.add(traumaCare);
    }

    if (clean.contains('respiratory') ||
        clean.contains('breath') ||
        clean.contains('dyspnea') ||
        clean.contains('spo2') ||
        clean.contains('asthma') ||
        clean.contains('pneumonia')) {
      suggestions.add(ventilator);
      suggestions.add(oxygenBed);
      suggestions.add(icuBed);
    }

    if (clean.contains('pediatric') ||
        clean.contains('child') ||
        clean.contains('infant') ||
        clean.contains('febrile')) {
      suggestions.add(pediatricIcuBed);
      suggestions.add(pediatricIcuCare);
    }

    if (clean.contains('burn') || clean.contains('scald') || clean.contains('fire')) {
      suggestions.add(burnsCare);
      suggestions.add(icuBed);
    }

    if (clean.contains('stroke') || clean.contains('neuro') || clean.contains('altered')) {
      suggestions.add(icuBed);
      suggestions.add(emergencyBed);
    }

    // Default fallback if no specific keywords matched
    if (suggestions.isEmpty) {
      suggestions.add(emergencyBed);
      suggestions.add(icuBed);
    }

    return suggestions.toList(growable: false);
  }

  // ---------------------------------------------------------------------------
  // Emergency Preset Bundles (Sub-phase 5.5)
  // ---------------------------------------------------------------------------

  static const List<EmergencyPresetBundle> presets = [
    EmergencyPresetBundle(
      id: 'cardiac_emergency',
      name: 'Cardiac Emergency',
      subtitle: 'ICU Bed + Cath Lab / CCU',
      icon: Icons.favorite_rounded,
      requirements: {
        'icu_bed': 1,
        'cardiac_care': 1,
      },
    ),
    EmergencyPresetBundle(
      id: 'polytrauma_icu',
      name: 'Polytrauma ICU',
      subtitle: 'ICU + Trauma Bay + Trauma Surgery',
      icon: Icons.healing_rounded,
      requirements: {
        'icu_bed': 1,
        'emergency_bed': 1,
        'trauma_care': 1,
      },
    ),
    EmergencyPresetBundle(
      id: 'respiratory_failure',
      name: 'Respiratory Failure',
      subtitle: 'ICU + Ventilator + Oxygen',
      icon: Icons.air_rounded,
      requirements: {
        'icu_bed': 1,
        'ventilator': 1,
        'oxygen_bed': 1,
      },
    ),
    EmergencyPresetBundle(
      id: 'pediatric_icu',
      name: 'Pediatric ICU',
      subtitle: 'PICU Bed + Pediatric Intensivist',
      icon: Icons.child_care_rounded,
      requirements: {
        'pediatric_icu_bed': 1,
        'pediatric_icu_care': 1,
      },
    ),
  ];
}
