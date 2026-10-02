import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/features/hospital/data/repositories/supabase_hospital_repository.dart';

void main() {
  group('SupabaseHospitalRepository', () {
    final sampleRows = [
      {
        'id': 'hosp-001',
        'name': 'KEM Hospital Mumbai',
        'ward_name': 'F/South',
        'hospital_type': 'Government',
        'address': 'Acharya Donde Marg, Parel, Mumbai, Maharashtra 400012',
        'latitude': 19.0028,
        'longitude': 72.8427,
        'contact': '022-24107000',
        'total_beds': 1800,
        'facilities': ['Trauma Care', 'ICU', 'Emergency', 'Blood Bank'],
        'availability_is_simulated': true,
        'is_active': true,
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      },
      {
        'id': 'hosp-002',
        'name': 'Lilavati Hospital & Research Centre',
        'ward_name': 'H/West',
        'hospital_type': 'Private',
        'address': 'A-791, Bandra Reclamation, Bandra West, Mumbai 400050',
        'latitude': 19.0519,
        'longitude': 72.8290,
        'contact': '022-26751000',
        'total_beds': 323,
        'facilities': ['ICU', 'Emergency'],
        'availability_is_simulated': true,
        'is_active': true,
        'created_at': '2025-01-01T00:00:00Z',
        'updated_at': '2025-01-01T00:00:00Z',
      },
    ];

    test('metadata properties return expected values', () {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async => [],
      );

      expect(repository.isRealBackend, isTrue);
      expect(repository.dataSourceName, equals('SUPABASE_CLOUD'));
    });

    test('getHospitals successfully parses database rows to domain matches', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async {
          expect(activeOnly, isTrue);
          return sampleRows;
        },
      );

      final result = await repository.getHospitals();

      expect(result.length, equals(2));
      expect(result[0].id, equals('hosp-001'));
      expect(result[0].name, equals('KEM Hospital Mumbai'));
      expect(result[0].rank, equals(1));
      expect(result[0].address, contains('Acharya Donde Marg'));
      expect(result[0].area, equals('Ward F/South, Mumbai'));
      expect(result[0].supportedCapabilities, contains('trauma_care'));
      expect(result[0].supportedCapabilities, contains('icu_care'));
      expect(result[0].supportedCapabilities, contains('emergency_care'));

      expect(result[1].id, equals('hosp-002'));
      expect(result[1].name, equals('Lilavati Hospital & Research Centre'));
      expect(result[1].rank, equals(2));
    });

    test('getHospitals returns empty list when table has 0 rows', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async => [],
      );

      final result = await repository.getHospitals();
      expect(result, isEmpty);
    });

    test('getHospitals translates PostgrestException 42501 (RLS denied) to HospitalRepositoryException with isRlsBlock true', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async {
          throw const PostgrestException(
            message: 'permission denied for table hospitals',
            code: '42501',
          );
        },
      );

      try {
        await repository.getHospitals();
        fail('Should have thrown HospitalRepositoryException');
      } on HospitalRepositoryException catch (e) {
        expect(e.code, equals(ErrorCodes.rlsDenied));
        expect(e.isRlsBlock, isTrue);
        expect(e.message, contains('RLS is enabled with 0 policies'));
      }
    });

    test('getHospitals translates PostgrestException PGRST301 to HospitalRepositoryException with isRlsBlock true', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async {
          throw const PostgrestException(
            message: 'JWT expired or missing RLS policy',
            code: 'PGRST301',
          );
        },
      );

      try {
        await repository.getHospitals();
        fail('Should have thrown HospitalRepositoryException');
      } on HospitalRepositoryException catch (e) {
        expect(e.code, equals(ErrorCodes.rlsDenied));
        expect(e.isRlsBlock, isTrue);
      }
    });

    test('getHospitals translates non-RLS PostgrestException to HospitalRepositoryException with isRlsBlock false', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async {
          throw const PostgrestException(
            message: 'column does not exist',
            code: '42703',
          );
        },
      );

      try {
        await repository.getHospitals();
        fail('Should have thrown HospitalRepositoryException');
      } on HospitalRepositoryException catch (e) {
        expect(e.code, equals(ErrorCodes.repositoryError));
        expect(e.isRlsBlock, isFalse);
        expect(e.message, contains('column does not exist'));
      }
    });

    test('getHospitals translates TimeoutException to NetworkException', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async {
          throw TimeoutException('Supabase connection timed out');
        },
      );

      expect(
        () => repository.getHospitals(),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getHospitals throws HospitalRepositoryException when client is null and no queryExecutor provided', () async {
      final repository = SupabaseHospitalRepository();

      expect(
        () => repository.getHospitals(),
        throwsA(isA<HospitalRepositoryException>()),
      );
    });

    test('getHospitalById retrieves match by ID', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async => sampleRows,
      );

      final hospital = await repository.getHospitalById('hosp-002');
      expect(hospital, isNotNull);
      expect(hospital!.name, equals('Lilavati Hospital & Research Centre'));
    });

    test('getHospitalById returns null if not found', () async {
      final repository = SupabaseHospitalRepository(
        queryExecutor: ({bool activeOnly = true}) async => sampleRows,
      );

      final hospital = await repository.getHospitalById('non-existent');
      expect(hospital, isNull);
    });
  });
}
