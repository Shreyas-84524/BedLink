import '../../../matching/domain/models/hospital_match.dart';

/// Abstract contract for querying hospital facilities and match candidates.
abstract class HospitalRepository {
  /// Retrieves all hospitals, optionally filtered to active facilities.
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true});

  /// Retrieves a specific hospital facility by its ID.
  Future<HospitalMatch?> getHospitalById(String id);

  /// Whether this repository is backed by real live Supabase backend data.
  bool get isRealBackend;

  /// Human-readable label of the active data source (e.g. 'MOCK_FIXTURE', 'SUPABASE_CLOUD').
  String get dataSourceName;
}
