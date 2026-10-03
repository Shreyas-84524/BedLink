import '../../data/models/supabase_bed_dto.dart';

/// Contract for accessing raw bed slot inventory records.
abstract class BedRepository {
  /// Fetches all individual bed slots for a specified hospital.
  Future<List<SupabaseBedDto>> getBedsForHospital(String hospitalId);

  /// Whether this repository reads from a live backend rather than mock fixtures.
  bool get isRealBackend;

  /// Human-readable data source identifier for diagnostics and operator badge.
  String get dataSourceName;
}
