import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/features/hospital/data/adapters/bed_inventory_adapter.dart';
import 'package:bedlink/features/hospital/data/models/supabase_bed_dto.dart';

void main() {
  group('BedInventoryAdapter Tests (Worker 2)', () {
    const adapter = BedInventoryAdapter();

    test('aggregates single bed type (ICU) and enforces total invariant', () {
      final now = DateTime.parse('2026-10-01T12:00:00Z');
      final beds = [
        SupabaseBedDto(id: '1', hospitalId: 'h1', bedType: 'ICU', status: 'available', updatedAt: now),
        SupabaseBedDto(id: '2', hospitalId: 'h1', bedType: 'ICU', status: 'available', updatedAt: now.add(const Duration(minutes: 1))),
        SupabaseBedDto(id: '3', hospitalId: 'h1', bedType: 'ICU', status: 'reserved', updatedAt: now.add(const Duration(minutes: 2))),
        SupabaseBedDto(id: '4', hospitalId: 'h1', bedType: 'ICU', status: 'occupied', updatedAt: now.add(const Duration(minutes: 3))),
        SupabaseBedDto(id: '5', hospitalId: 'h1', bedType: 'ICU', status: 'occupied', updatedAt: now.add(const Duration(minutes: 4))),
      ];

      final result = adapter.aggregateBeds(beds);

      expect(result.hasBackendRecords, isTrue);
      expect(result.totalBedRows, equals(5));
      expect(result.lastUpdatedAt, equals(now.add(const Duration(minutes: 4))));

      final icu = result.resources['icu_bed']!;
      expect(icu.available, equals(2));
      expect(icu.held, equals(1)); // reserved mapped to held
      expect(icu.occupied, equals(2));
      expect(icu.total, equals(5));

      // Strict invariant check
      expect(icu.available + icu.held + icu.occupied, equals(icu.total));
      expect(icu.isOperational, isTrue);
    });

    test('aggregates all 3 supported types (ICU, Emergency, General) simultaneously', () {
      final now = DateTime.parse('2026-10-01T12:00:00Z');
      final beds = [
        // 3 ICU: 1 avail, 1 held, 1 occ
        SupabaseBedDto(id: 'i1', hospitalId: 'h1', bedType: 'ICU', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'i2', hospitalId: 'h1', bedType: 'ICU', status: 'reserved', updatedAt: now),
        SupabaseBedDto(id: 'i3', hospitalId: 'h1', bedType: 'ICU', status: 'occupied', updatedAt: now),

        // 4 Emergency: 2 avail, 0 held, 2 occ
        SupabaseBedDto(id: 'e1', hospitalId: 'h1', bedType: 'emergency', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'e2', hospitalId: 'h1', bedType: 'emergency', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'e3', hospitalId: 'h1', bedType: 'emergency', status: 'occupied', updatedAt: now),
        SupabaseBedDto(id: 'e4', hospitalId: 'h1', bedType: 'emergency', status: 'occupied', updatedAt: now),

        // 5 General: 3 avail, 1 held, 1 occ
        SupabaseBedDto(id: 'g1', hospitalId: 'h1', bedType: 'general', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'g2', hospitalId: 'h1', bedType: 'general', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'g3', hospitalId: 'h1', bedType: 'general', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'g4', hospitalId: 'h1', bedType: 'general', status: 'reserved', updatedAt: now),
        SupabaseBedDto(id: 'g5', hospitalId: 'h1', bedType: 'general', status: 'occupied', updatedAt: now),
      ];

      final result = adapter.aggregateBeds(beds);

      expect(result.totalBedRows, equals(12));

      final icu = result.resources['icu_bed']!;
      expect(icu.available, equals(1));
      expect(icu.held, equals(1));
      expect(icu.occupied, equals(1));
      expect(icu.total, equals(3));
      expect(icu.available + icu.held + icu.occupied, equals(icu.total));

      final er = result.resources['er_bed']!;
      expect(er.available, equals(2));
      expect(er.held, equals(0));
      expect(er.occupied, equals(2));
      expect(er.total, equals(4));
      expect(er.available + er.held + er.occupied, equals(er.total));

      final gen = result.resources['general_bed']!;
      expect(gen.available, equals(3));
      expect(gen.held, equals(1));
      expect(gen.occupied, equals(1));
      expect(gen.total, equals(5));
      expect(gen.available + gen.held + gen.occupied, equals(gen.total));
    });

    test('handles empty bed list with hasBackendRecords false', () {
      final result = adapter.aggregateBeds([]);

      expect(result.hasBackendRecords, isFalse);
      expect(result.totalBedRows, equals(0));
      expect(result.lastUpdatedAt, isNull);
    });

    test('handles unknown bed status defensively preserving total invariant', () {
      final now = DateTime.now();
      final beds = [
        SupabaseBedDto(id: 'u1', hospitalId: 'h1', bedType: 'ICU', status: 'available', updatedAt: now),
        SupabaseBedDto(id: 'u2', hospitalId: 'h1', bedType: 'ICU', status: 'cleaning_in_progress', updatedAt: now),
      ];

      final result = adapter.aggregateBeds(beds);
      final icu = result.resources['icu_bed']!;

      expect(icu.total, equals(2));
      expect(icu.available, equals(1));
      expect(icu.occupied, equals(1)); // Unknown treated defensively as occupied
      expect(icu.available + icu.held + icu.occupied, equals(icu.total));
    });

    test('unsupported backend resources are flagged with isOperational false', () {
      final now = DateTime.now();
      final beds = [
        SupabaseBedDto(id: '1', hospitalId: 'h1', bedType: 'ICU', status: 'available', updatedAt: now),
      ];

      final result = adapter.aggregateBeds(beds);

      final ventilator = result.resources['ventilator']!;
      expect(ventilator.isOperational, isFalse);
      expect(ventilator.name, contains('Mock Only'));

      final oxygen = result.resources['oxygen_bed']!;
      expect(oxygen.isOperational, isFalse);
      expect(oxygen.name, contains('Mock Only'));

      final peds = result.resources['pediatric_icu']!;
      expect(peds.isOperational, isFalse);
      expect(peds.name, contains('Mock Only'));

      expect(result.unsupportedResources, contains('ventilator'));
      expect(result.unsupportedResources, contains('oxygen_bed'));
      expect(result.unsupportedResources, contains('pediatric_icu'));
    });
  });
}
