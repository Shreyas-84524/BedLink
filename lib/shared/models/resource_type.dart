import '../../core/constants/clinical_codes.dart';

enum ResourceType {
  generalBed(ClinicalCodes.generalBed, 'General Emergency Bed', 'Standard emergency observation bed'),
  emergencyBed(ClinicalCodes.emergencyBed, 'Emergency Trauma Bed', 'Immediate resuscitation bed'),
  icuBed(ClinicalCodes.icuBed, 'ICU Bed', 'Intensive care unit bed with monitor'),
  ventilator(ClinicalCodes.ventilator, 'Mechanical Ventilator', 'Invasive/non-invasive ventilation unit'),
  oxygenBed(ClinicalCodes.oxygenBed, 'High Flow Oxygen Bed', 'High-flow nasal cannula/O2 therapy'),
  pediatricIcuBed(ClinicalCodes.pediatricIcuBed, 'Pediatric ICU Bed', 'Specialized PICU bed with pediatric monitor');

  const ResourceType(this.code, this.displayName, this.description);

  final String code;
  final String displayName;
  final String description;

  static ResourceType? fromCode(String code) {
    for (final ResourceType type in ResourceType.values) {
      if (type.code == code) return type;
    }
    return null;
  }
}
