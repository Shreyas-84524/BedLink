import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/data/supabase_client_provider.dart';
import '../../data/repositories/mock_hospital_repository.dart';
import '../../data/repositories/supabase_hospital_repository.dart';
import '../../domain/repositories/hospital_repository.dart';

/// Global provider supplying the active [HospitalRepository] implementation.
///
/// Automatically switches between [MockHospitalRepository] and [SupabaseHospitalRepository]
/// depending on [SupabaseConfig] and client availability.
///
/// Can be overridden in unit and widget tests using:
/// ```dart
/// hospitalRepositoryProvider.overrideWithValue(myMockRepository)
/// ```
final hospitalRepositoryProvider = Provider<HospitalRepository>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  final client = ref.watch(supabaseClientProvider);

  if (config.useMock || client == null) {
    return const MockHospitalRepository();
  }

  return SupabaseHospitalRepository(client: client);
});
