import 'package:flutter_test/flutter_test.dart';
import 'package:bedlink/features/hospital/data/models/supabase_bed_dto.dart';

void main() {
  group('SupabaseBedDto Tests (Worker 1)', () {
    test('deserializes ICU bed with available status', () {
      final json = {
        'id': 'bed-icu-001',
        'hospital_id': 'hosp-001',
        'bed_type': 'ICU',
        'status': 'available',
        'updated_at': '2026-10-01T12:00:00Z',
      };

      final dto = SupabaseBedDto.fromJson(json);

      expect(dto.id, equals('bed-icu-001'));
      expect(dto.hospitalId, equals('hosp-001'));
      expect(dto.bedType, equals('ICU'));
      expect(dto.canonicalResourceId, equals('icu_bed'));
      expect(dto.isSupportedType, isTrue);
      expect(dto.status, equals('available'));
      expect(dto.domainStatus, equals('available'));
      expect(dto.updatedAt, equals(DateTime.parse('2026-10-01T12:00:00Z')));
    });

    test('deserializes general bed with reserved status mapping to held', () {
      final json = {
        'id': 'bed-gen-002',
        'hospital_id': 'hosp-001',
        'bed_type': 'general',
        'status': 'reserved',
        'updated_at': '2026-10-01T12:30:00Z',
      };

      final dto = SupabaseBedDto.fromJson(json);

      expect(dto.canonicalResourceId, equals('general_bed'));
      expect(dto.isSupportedType, isTrue);
      expect(dto.status, equals('reserved'));
      expect(dto.domainStatus, equals('held')); // Must map reserved to held
    });

    test('deserializes emergency bed with occupied status', () {
      final json = {
        'id': 'bed-er-003',
        'hospital_id': 'hosp-001',
        'bed_type': 'emergency',
        'status': 'occupied',
        'updated_at': '2026-10-01T13:00:00Z',
      };

      final dto = SupabaseBedDto.fromJson(json);

      expect(dto.canonicalResourceId, equals('er_bed'));
      expect(dto.isSupportedType, isTrue);
      expect(dto.domainStatus, equals('occupied'));
    });

    test('handles unknown bed type safely without crashing', () {
      final json = {
        'id': 'bed-other-004',
        'hospital_id': 'hosp-001',
        'bed_type': 'specialty_ward',
        'status': 'available',
        'updated_at': '2026-10-01T13:00:00Z',
      };

      final dto = SupabaseBedDto.fromJson(json);

      expect(dto.canonicalResourceId, equals('unknown_specialty_ward'));
      expect(dto.isSupportedType, isFalse);
      expect(dto.domainStatus, equals('available'));
    });

    test('handles unknown status safely', () {
      final json = {
        'id': 'bed-005',
        'hospital_id': 'hosp-001',
        'bed_type': 'ICU',
        'status': 'maintenance_mode',
        'updated_at': '2026-10-01T13:00:00Z',
      };

      final dto = SupabaseBedDto.fromJson(json);

      expect(dto.domainStatus, equals('unknown'));
    });

    test('handles null or malformed updated_at with fallback timestamp', () {
      final json = {
        'id': 'bed-006',
        'hospital_id': 'hosp-001',
        'bed_type': 'ICU',
        'status': 'available',
        'updated_at': null,
      };

      final dto = SupabaseBedDto.fromJson(json);

      expect(dto.updatedAt, isNotNull);
    });

    test('toJson produces expected map matching database columns', () {
      final dto = SupabaseBedDto(
        id: 'bed-test-01',
        hospitalId: 'hosp-test',
        bedType: 'ICU',
        status: 'available',
        updatedAt: DateTime.parse('2026-10-01T12:00:00Z'),
      );

      final map = dto.toJson();

      expect(map['id'], equals('bed-test-01'));
      expect(map['hospital_id'], equals('hosp-test'));
      expect(map['bed_type'], equals('ICU'));
      expect(map['status'], equals('available'));
      expect(map['updated_at'], equals('2026-10-01T12:00:00.000Z'));
    });
  });
}
