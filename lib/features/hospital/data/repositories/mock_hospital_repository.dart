import '../../../matching/data/mock_hospital_data.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../domain/repositories/hospital_repository.dart';

/// In-memory mock repository supplying deterministic Mumbai hospital candidates for tests & offline demo.
class MockHospitalRepository implements HospitalRepository {
  const MockHospitalRepository({
    this.candidates = MockHospitalData.standardCandidates,
  });

  final List<HospitalMatch> candidates;

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async {
    return List.unmodifiable(candidates);
  }

  @override
  Future<HospitalMatch?> getHospitalById(String id) async {
    try {
      return candidates.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  bool get isRealBackend => false;

  @override
  String get dataSourceName => 'MOCK_FIXTURE';
}
