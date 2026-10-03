/// Compatibility interface for hospital resource availability mutations.
///
/// In Phase 15, backend slot mutations are executed atomically on public.beds
/// to prevent double-booking and synchronize live triage states.
abstract class BedInventoryMutationRepository {
  /// Request incrementing available capacity for a specific resource.
  Future<void> incrementAvailable(String hospitalId, String resourceId);

  /// Request decrementing available capacity for a specific resource.
  Future<void> decrementAvailable(String hospitalId, String resourceId);

  /// Atomically reserves a bed slot for an inbound transfer.
  Future<void> reserveBed(String hospitalId, String resourceId);

  /// Marks a reserved or allocated bed as occupied upon patient arrival.
  Future<void> markBedOccupied(String hospitalId, String resourceId);

  /// Releases a reserved bed back to available status upon hold cancellation/expiry.
  Future<void> releaseReservedBed(String hospitalId, String resourceId);

  /// Whether mutations are committed directly to a live Supabase backend.
  bool get isRealBackendWritesSupported;

  /// Convenience getter matching repository conventions.
  bool get isRealBackend => isRealBackendWritesSupported;
}

/// Local/Mock implementation of [BedInventoryMutationRepository].
class MockBedInventoryMutationRepository implements BedInventoryMutationRepository {
  const MockBedInventoryMutationRepository();

  @override
  bool get isRealBackendWritesSupported => false;

  @override
  bool get isRealBackend => false;

  @override
  Future<void> incrementAvailable(String hospitalId, String resourceId) async {
    // Local in-memory simulation only.
  }

  @override
  Future<void> decrementAvailable(String hospitalId, String resourceId) async {
    // Local in-memory simulation only.
  }

  @override
  Future<void> reserveBed(String hospitalId, String resourceId) async {
    // Local in-memory simulation only.
  }

  @override
  Future<void> markBedOccupied(String hospitalId, String resourceId) async {
    // Local in-memory simulation only.
  }

  @override
  Future<void> releaseReservedBed(String hospitalId, String resourceId) async {
    // Local in-memory simulation only.
  }
}
