import 'package:flutter/foundation.dart';
import 'biological_sex.dart';
import 'clinical_urgency.dart';

/// Immutable domain model representing the patient intake information captured by the ambulance crew.
@immutable
class PatientIntake {
  const PatientIntake({
    required this.patientName,
    required this.isUnknownPatient,
    required this.biologicalSex,
    required this.age,
    required this.urgency,
    required this.chiefComplaint,
    required this.clinicalNotes,
  });

  /// Initial default state for a new patient intake session.
  factory PatientIntake.initial() {
    return const PatientIntake(
      patientName: '',
      isUnknownPatient: false,
      biologicalSex: BiologicalSex.male,
      age: 45,
      urgency: ClinicalUrgency.critical,
      chiefComplaint: '',
      clinicalNotes: '',
    );
  }

  /// Preset demographic fixture for fast 1-tap demo testing.
  factory PatientIntake.demoPreset() {
    return const PatientIntake(
      patientName: 'Ramesh Patil (Cardiac Case)',
      isUnknownPatient: false,
      biologicalSex: BiologicalSex.male,
      age: 58,
      urgency: ClinicalUrgency.critical,
      chiefComplaint: 'Acute Chest Pain • Suspected STEMI',
      clinicalNotes: 'Sudden onset crushing retrosternal chest pain radiating to left arm. ST elevation in leads II, III, aVF. BP 148/92, HR 102, SpO2 94%.',
    );
  }

  final String patientName;
  final bool isUnknownPatient;
  final BiologicalSex biologicalSex;
  final int age;
  final ClinicalUrgency urgency;
  final String chiefComplaint;
  final String clinicalNotes;

  /// Human-readable patient age category.
  String get ageCohort {
    if (age < 1) return 'Infant';
    if (age < 18) return 'Pediatric';
    if (age < 65) return 'Adult';
    return 'Geriatric';
  }

  /// Effective patient display label.
  String get displayName {
    if (isUnknownPatient) {
      return 'UNKNOWN / UNCONSCIOUS PATIENT';
    }
    return patientName.trim().isEmpty ? 'UNIDENTIFIED PATIENT' : patientName.trim();
  }

  /// Centralized validation rule determining whether the intake form is ready for progression.
  bool get isFormValid {
    final hasValidName = isUnknownPatient || patientName.trim().isNotEmpty;
    final hasValidAge = age >= 0 && age <= 125;
    final hasValidComplaint = chiefComplaint.trim().isNotEmpty;
    return hasValidName && hasValidAge && hasValidComplaint;
  }

  /// List of human-readable missing validation requirements.
  List<String> get validationErrors {
    final errors = <String>[];
    if (!isUnknownPatient && patientName.trim().isEmpty) {
      errors.add('Patient name or "Unknown Patient" selection is required.');
    }
    if (age < 0 || age > 125) {
      errors.add('Patient age must be between 0 and 125 years.');
    }
    if (chiefComplaint.trim().isEmpty) {
      errors.add('Chief complaint / clinical condition must be specified.');
    }
    return errors;
  }

  PatientIntake copyWith({
    String? patientName,
    bool? isUnknownPatient,
    BiologicalSex? biologicalSex,
    int? age,
    ClinicalUrgency? urgency,
    String? chiefComplaint,
    String? clinicalNotes,
  }) {
    return PatientIntake(
      patientName: patientName ?? this.patientName,
      isUnknownPatient: isUnknownPatient ?? this.isUnknownPatient,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      age: age ?? this.age,
      urgency: urgency ?? this.urgency,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientIntake &&
        other.patientName == patientName &&
        other.isUnknownPatient == isUnknownPatient &&
        other.biologicalSex == biologicalSex &&
        other.age == age &&
        other.urgency == urgency &&
        other.chiefComplaint == chiefComplaint &&
        other.clinicalNotes == clinicalNotes;
  }

  @override
  int get hashCode {
    return Object.hash(
      patientName,
      isUnknownPatient,
      biologicalSex,
      age,
      urgency,
      chiefComplaint,
      clinicalNotes,
    );
  }

  @override
  String toString() {
    return 'PatientIntake(name: $patientName, unknown: $isUnknownPatient, sex: $biologicalSex, age: $age ($ageCohort), urgency: $urgency, complaint: $chiefComplaint)';
  }
}
