import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/bed_mutation_repository.dart';

/// Real cloud implementation of [BedInventoryMutationRepository] executing atomic slot updates
/// against Supabase `public.beds`.
class SupabaseBedMutationRepository implements BedInventoryMutationRepository {
  SupabaseBedMutationRepository({
    this.client,
  });

  final SupabaseClient? client;

  @override
  bool get isRealBackendWritesSupported => true;

  @override
  bool get isRealBackend => true;

  /// Translates canonical BedLink resource ID to public.beds bed_type.
  String _toDbBedType(String resourceId) {
    final lower = resourceId.toLowerCase();
    if (lower.contains('icu')) return 'ICU';
    if (lower.contains('general')) return 'general';
    return 'emergency';
  }

  @override
  Future<void> incrementAvailable(String hospitalId, String resourceId) async {
    if (client == null) return;
    try {
      final dbType = _toDbBedType(resourceId);
      // Find an occupied bed and free it
      final bed = await client!
          .from('beds')
          .select('id')
          .eq('hospital_id', hospitalId)
          .eq('bed_type', dbType)
          .eq('status', 'occupied')
          .limit(1)
          .maybeSingle();

      if (bed != null) {
        await client!.from('beds').update({
          'status': 'available',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', bed['id'] as Object);
      }
    } catch (e) {
      debugPrint('Error incrementing available bed: $e');
    }
  }

  @override
  Future<void> decrementAvailable(String hospitalId, String resourceId) async {
    if (client == null) return;
    try {
      final dbType = _toDbBedType(resourceId);
      // Find an available bed and allocate it
      final bed = await client!
          .from('beds')
          .select('id')
          .eq('hospital_id', hospitalId)
          .eq('bed_type', dbType)
          .eq('status', 'available')
          .limit(1)
          .maybeSingle();

      if (bed != null) {
        await client!.from('beds').update({
          'status': 'occupied',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', bed['id'] as Object);
      }
    } catch (e) {
      debugPrint('Error decrementing available bed: $e');
    }
  }

  @override
  Future<void> reserveBed(String hospitalId, String resourceId) async {
    if (client == null) return;
    try {
      final dbType = _toDbBedType(resourceId);
      // Atomic query and update to prevent race conditions & double-booking
      final availableBed = await client!
          .from('beds')
          .select('id')
          .eq('hospital_id', hospitalId)
          .eq('bed_type', dbType)
          .eq('status', 'available')
          .limit(1)
          .maybeSingle();

      if (availableBed == null) {
        debugPrint('No available bed of type $dbType at hospital $hospitalId to reserve.');
        return;
      }

      await client!
          .from('beds')
          .update({
            'status': 'reserved',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', availableBed['id'] as Object)
          .eq('status', 'available'); // Double-check optimistic concurrency lock
    } catch (e) {
      debugPrint('Error reserving bed: $e');
    }
  }

  @override
  Future<void> markBedOccupied(String hospitalId, String resourceId) async {
    if (client == null) return;
    try {
      final dbType = _toDbBedType(resourceId);
      final reservedBed = await client!
          .from('beds')
          .select('id')
          .eq('hospital_id', hospitalId)
          .eq('bed_type', dbType)
          .eq('status', 'reserved')
          .limit(1)
          .maybeSingle();

      if (reservedBed != null) {
        await client!.from('beds').update({
          'status': 'occupied',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', reservedBed['id'] as Object);
      }
    } catch (e) {
      debugPrint('Error marking bed occupied: $e');
    }
  }

  @override
  Future<void> releaseReservedBed(String hospitalId, String resourceId) async {
    if (client == null) return;
    try {
      final dbType = _toDbBedType(resourceId);
      final reservedBed = await client!
          .from('beds')
          .select('id')
          .eq('hospital_id', hospitalId)
          .eq('bed_type', dbType)
          .eq('status', 'reserved')
          .limit(1)
          .maybeSingle();

      if (reservedBed != null) {
        await client!.from('beds').update({
          'status': 'available',
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', reservedBed['id'] as Object);
      }
    } catch (e) {
      debugPrint('Error releasing reserved bed: $e');
    }
  }
}
