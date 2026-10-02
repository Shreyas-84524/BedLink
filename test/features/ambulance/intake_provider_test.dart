import 'package:bedlink/features/ambulance/domain/models/biological_sex.dart';
import 'package:bedlink/features/ambulance/domain/models/clinical_urgency.dart';
import 'package:bedlink/features/ambulance/domain/models/patient_intake.dart';
import 'package:bedlink/features/ambulance/presentation/providers/intake_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Patient Intake Domain & Notifier Tests', () {
    test('Initial PatientIntake defaults are initialized correctly', () {
      final intake = PatientIntake.initial();

      expect(intake.patientName, '');
      expect(intake.isUnknownPatient, false);
      expect(intake.biologicalSex, BiologicalSex.male);
      expect(intake.age, 45);
      expect(intake.ageCohort, 'Adult');
      expect(intake.urgency, ClinicalUrgency.critical);
      expect(intake.chiefComplaint, '');
      expect(intake.clinicalNotes, '');
      expect(intake.isFormValid, false);
      expect(intake.validationErrors.isNotEmpty, true);
    });

    test('Patient age cohort categorizes ages accurately', () {
      final infant = PatientIntake.initial().copyWith(age: 0);
      expect(infant.ageCohort, 'Infant');

      final pediatric = PatientIntake.initial().copyWith(age: 12);
      expect(pediatric.ageCohort, 'Pediatric');

      final adult = PatientIntake.initial().copyWith(age: 35);
      expect(adult.ageCohort, 'Adult');

      final geriatric = PatientIntake.initial().copyWith(age: 78);
      expect(geriatric.ageCohort, 'Geriatric');
    });

    test('Form validation requires name or unknown patient + valid age + complaint', () {
      var intake = PatientIntake.initial();
      expect(intake.isFormValid, false);

      // Add name only (complaint missing)
      intake = intake.copyWith(patientName: 'John Doe');
      expect(intake.isFormValid, false);

      // Add chief complaint
      intake = intake.copyWith(chiefComplaint: 'Chest pain');
      expect(intake.isFormValid, true);
      expect(intake.validationErrors.isEmpty, true);

      // Clear name but set isUnknownPatient = true
      intake = intake.copyWith(patientName: '', isUnknownPatient: true);
      expect(intake.isFormValid, true);
      expect(intake.displayName, 'UNKNOWN / UNCONSCIOUS PATIENT');
    });

    test('PatientIntakeNotifier updates fields and clamps age within [0, 125]', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(patientIntakeProvider.notifier);

      // Update name
      notifier.setPatientName('Anil Kumar');
      expect(container.read(patientIntakeProvider).patientName, 'Anil Kumar');

      // Update sex
      notifier.setBiologicalSex(BiologicalSex.female);
      expect(container.read(patientIntakeProvider).biologicalSex, BiologicalSex.female);

      // Age increment & decrement
      notifier.setAge(10);
      expect(container.read(patientIntakeProvider).age, 10);
      notifier.incrementAge(step: 5);
      expect(container.read(patientIntakeProvider).age, 15);
      notifier.decrementAge(step: 2);
      expect(container.read(patientIntakeProvider).age, 13);

      // Clamping bounds
      notifier.setAge(150);
      expect(container.read(patientIntakeProvider).age, 125);
      notifier.setAge(-10);
      expect(container.read(patientIntakeProvider).age, 0);

      // Update urgency
      notifier.setUrgency(ClinicalUrgency.urgent);
      expect(container.read(patientIntakeProvider).urgency, ClinicalUrgency.urgent);

      // Update complaint and notes
      notifier.setChiefComplaint('Severe head trauma');
      notifier.setClinicalNotes('GCS 11, pupil responsive');
      expect(container.read(patientIntakeProvider).chiefComplaint, 'Severe head trauma');
      expect(container.read(patientIntakeProvider).clinicalNotes, 'GCS 11, pupil responsive');
      expect(container.read(patientIntakeProvider).isFormValid, true);

      // Reset
      notifier.reset();
      expect(container.read(patientIntakeProvider).patientName, '');
      expect(container.read(patientIntakeProvider).isFormValid, false);
    });

    test('fillQuickDemoPreset populates complete valid demo intake', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(patientIntakeProvider.notifier).fillQuickDemoPreset();
      final intake = container.read(patientIntakeProvider);

      expect(intake.patientName, contains('Ramesh Patil'));
      expect(intake.age, 58);
      expect(intake.urgency, ClinicalUrgency.critical);
      expect(intake.chiefComplaint, contains('Chest Pain'));
      expect(intake.clinicalNotes, isNotEmpty);
      expect(intake.isFormValid, true);
    });
  });
}
