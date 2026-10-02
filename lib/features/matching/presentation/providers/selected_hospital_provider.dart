import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/hospital_match.dart';

/// Riverpod Notifier holding the active hospital selected by ambulance crew for a 2-minute hold.
class SelectedHospitalNotifier extends Notifier<HospitalMatch?> {
  @override
  HospitalMatch? build() {
    return null;
  }

  /// Selects a hospital candidate for reservation hold.
  void selectHospital(HospitalMatch hospital) {
    state = hospital;
  }

  /// Clears the currently selected hospital.
  void clearSelection() {
    state = null;
  }
}

/// Global provider for the hospital currently selected for emergency bed hold.
final selectedHospitalProvider =
    NotifierProvider<SelectedHospitalNotifier, HospitalMatch?>(
  SelectedHospitalNotifier.new,
);
