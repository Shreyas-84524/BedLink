/// Compatibility interface for hospital resource availability mutations.
///
/// In Phase 12, backend slot mutations are strictly deferred to prevent unsafe concurrency
/// and unauthorized schema writes. Live reads are connected, while writes operate locally.
abstract class BedInventoryMutationRepository {
  /// Request incrementing available capacity for a specific resource.
  Future<void> incrementAvailable(String hospitalId, String resourceId);

  /// Request decrementing available capacity for a specific resource.
  Future<void> decrementAvailable(String hospitalId, String resourceId);

  /// Whether mutations are committed directly to a live Supabase backend.
  bool get isRealBackendWritesSupported;
}

/// Local/Mock implementation of [BedInventoryMutationRepository].
class MockBedInventoryMutationRepository implements BedInventoryMutationRepository {
  const MockBedInventoryMutationRepository();

  @override
  bool get isRealBackendWritesSupported => false;

  @override
  Future<void> incrementAvailable(String hospitalId, String resourceId) async {
    // Safe compatibility: mutations remain local in Phase 12.
  }

  @override
  Future<void> decrementAvailable(String hospitalId, String resourceId) async {
    // Safe compatibility: mutations remain local in Phase 12.
  }
}
