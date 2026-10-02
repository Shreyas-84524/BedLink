import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/supabase_config.dart';
import '../../../../core/data/supabase_client_provider.dart';
import '../../data/repositories/mock_bed_repository.dart';
import '../../data/repositories/supabase_bed_repository.dart';
import '../../domain/repositories/bed_repository.dart';

/// Global provider supplying the active [BedRepository] implementation.
///
/// Automatically switches between [MockBedRepository] and [SupabaseBedRepository]
/// depending on [SupabaseConfig] and client availability.
///
/// Can be overridden in unit and widget tests using:
/// ```dart
/// bedRepositoryProvider.overrideWithValue(myMockBedRepository)
/// ```
final bedRepositoryProvider = Provider<BedRepository>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  final client = ref.watch(supabaseClientProvider);

  if (config.useMock || client == null) {
    return const MockBedRepository();
  }

  return SupabaseBedRepository(client: client);
});
