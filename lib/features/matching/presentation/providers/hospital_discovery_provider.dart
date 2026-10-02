import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../hospital/presentation/providers/hospital_repository_provider.dart';
import '../../data/repositories/mock_hospital_discovery_repository.dart';
import '../../data/repositories/supabase_hospital_discovery_repository.dart';
import '../../domain/repositories/hospital_discovery_repository.dart';

/// Provider exposing the active [HospitalDiscoveryRepository].
/// Dynamically switches between [SupabaseHospitalDiscoveryRepository] when real backend is active
/// and [MockHospitalDiscoveryRepository] in offline/test mode.
final hospitalDiscoveryRepositoryProvider = Provider<HospitalDiscoveryRepository>((ref) {
  final hospitalRepo = ref.watch(hospitalRepositoryProvider);

  if (hospitalRepo.isRealBackend) {
    return SupabaseHospitalDiscoveryRepository(
      hospitalRepository: hospitalRepo,
    );
  }

  return MockHospitalDiscoveryRepository();
});
