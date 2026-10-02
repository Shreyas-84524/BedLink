import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/biological_sex.dart';
import '../../domain/models/clinical_urgency.dart';
import '../../domain/models/patient_intake.dart';

/// Riverpod Notifier managing the in-memory Patient Intake state.
class PatientIntakeNotifier extends Notifier<PatientIntake> {
  @override
  PatientIntake build() {
    return PatientIntake.initial();
  }

  void setPatientName(String name) {
    state = state.copyWith(patientName: name);
  }

  void toggleUnknownPatient(bool isUnknown) {
    state = state.copyWith(
      isUnknownPatient: isUnknown,
      patientName: isUnknown ? '' : state.patientName,
    );
  }

  void setBiologicalSex(BiologicalSex sex) {
    state = state.copyWith(biologicalSex: sex);
  }

  void setAge(int age) {
    final clampedAge = age.clamp(0, 125);
    state = state.copyWith(age: clampedAge);
  }

  void incrementAge({int step = 1}) {
    final newAge = (state.age + step).clamp(0, 125);
    state = state.copyWith(age: newAge);
  }

  void decrementAge({int step = 1}) {
    final newAge = (state.age - step).clamp(0, 125);
    state = state.copyWith(age: newAge);
  }

  void setUrgency(ClinicalUrgency urgency) {
    state = state.copyWith(urgency: urgency);
  }

  void setChiefComplaint(String complaint) {
    state = state.copyWith(chiefComplaint: complaint);
  }

  void setClinicalNotes(String notes) {
    state = state.copyWith(clinicalNotes: notes);
  }

  void fillQuickDemoPreset() {
    state = PatientIntake.demoPreset();
  }

  void reset() {
    state = PatientIntake.initial();
  }
}

/// Global provider for the active patient intake session state.
final patientIntakeProvider =
    NotifierProvider<PatientIntakeNotifier, PatientIntake>(
  PatientIntakeNotifier.new,
);
