/// Canonical clinical resource and capability codes matching PostgreSQL schema and API contract.
class ClinicalCodes {
  ClinicalCodes._();

  // Six Countable Resources
  static const String generalBed = 'general_bed';
  static const String emergencyBed = 'emergency_bed';
  static const String icuBed = 'icu_bed';
  static const String ventilator = 'ventilator';
  static const String oxygenBed = 'oxygen_bed';
  static const String pediatricIcuBed = 'pediatric_icu_bed';

  static const List<String> allResourceCodes = <String>[
    generalBed,
    emergencyBed,
    icuBed,
    ventilator,
    oxygenBed,
    pediatricIcuBed,
  ];

  // Clinical Care Capabilities
  static const String cardiacCare = 'cardiac_care';
  static const String traumaCare = 'trauma_care';
  static const String burnsCare = 'burns_care';
  static const String pediatricIcuCare = 'pediatric_icu_care';

  static const List<String> allCapabilityCodes = <String>[
    cardiacCare,
    traumaCare,
    burnsCare,
    pediatricIcuCare,
  ];
}
