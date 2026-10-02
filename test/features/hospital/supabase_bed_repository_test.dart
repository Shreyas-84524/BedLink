import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bedlink/core/errors/app_exception.dart';
import 'package:bedlink/core/errors/error_codes.dart';
import 'package:bedlink/features/hospital/data/repositories/supabase_bed_repository.dart';

void main() {
  group('SupabaseBedRepository Tests (Worker 1)', () {
    final sampleRows = [
      {
        'id': 'b1',
        'hospital_id': 'hosp-01',
        'bed_type': 'ICU',
        'status': 'available',
        'updated_at': '2026-10-01T10:00:00Z',
      },
      {
        'id': 'b2',
        'hospital_id': 'hosp-01',
        'bed_type': 'ICU',
        'status': 'reserved',
        'updated_at': '2026-10-01T10:05:00Z',
      },
      {
        'id': 'b3',
        'hospital_id': 'hosp-01',
        'bed_type': 'general',
        'status': 'occupied',
        'updated_at': '2026-10-01T10:10:00Z',
      },
    ];

    test('metadata properties return expected values', () {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async => [],
      );

      expect(repository.isRealBackend, isTrue);
      expect(repository.dataSourceName, equals('SUPABASE_CLOUD'));
    });

    test('getBedsForHospital parses rows correctly', () async {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async {
          expect(hospId, equals('hosp-01'));
          return sampleRows;
        },
      );

      final result = await repository.getBedsForHospital('hosp-01');

      expect(result.length, equals(3));
      expect(result[0].id, equals('b1'));
      expect(result[0].bedType, equals('ICU'));
      expect(result[0].canonicalResourceId, equals('icu_bed'));
      expect(result[0].domainStatus, equals('available'));

      expect(result[1].id, equals('b2'));
      expect(result[1].domainStatus, equals('held'));

      expect(result[2].id, equals('b3'));
      expect(result[2].canonicalResourceId, equals('general_bed'));
      expect(result[2].domainStatus, equals('occupied'));
    });

    test('getBedsForHospital returns empty list when table has 0 rows for hospital', () async {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async => [],
      );

      final result = await repository.getBedsForHospital('hosp-empty');
      expect(result, isEmpty);
    });

    test('getBedsForHospital translates PostgrestException 42501 to BedRepositoryException with isRlsBlock true', () async {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async {
          throw const PostgrestException(
            message: 'permission denied for table beds',
            code: '42501',
          );
        },
      );

      try {
        await repository.getBedsForHospital('hosp-01');
        fail('Should have thrown BedRepositoryException');
      } on BedRepositoryException catch (e) {
        expect(e.code, equals(ErrorCodes.rlsDenied));
        expect(e.isRlsBlock, isTrue);
        expect(e.message, contains('RLS is enabled with 0 policies'));
      }
    });

    test('getBedsForHospital translates PostgrestException PGRST301 to BedRepositoryException with isRlsBlock true', () async {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async {
          throw const PostgrestException(
            message: 'JWT expired or missing RLS policy',
            code: 'PGRST301',
          );
        },
      );

      try {
        await repository.getBedsForHospital('hosp-01');
        fail('Should have thrown BedRepositoryException');
      } on BedRepositoryException catch (e) {
        expect(e.code, equals(ErrorCodes.rlsDenied));
        expect(e.isRlsBlock, isTrue);
      }
    });

    test('getBedsForHospital translates non-RLS PostgrestException to BedRepositoryException with isRlsBlock false', () async {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async {
          throw const PostgrestException(
            message: 'relation does not exist',
            code: '42P01',
          );
        },
      );

      try {
        await repository.getBedsForHospital('hosp-01');
        fail('Should have thrown BedRepositoryException');
      } on BedRepositoryException catch (e) {
        expect(e.code, equals(ErrorCodes.repositoryError));
        expect(e.isRlsBlock, isFalse);
      }
    });

    test('getBedsForHospital translates TimeoutException to NetworkException', () async {
      final repository = SupabaseBedRepository(
        queryExecutor: (hospId) async {
          throw TimeoutException('Connection to Supabase timed out');
        },
      );

      expect(
        () => repository.getBedsForHospital('hosp-01'),
        throwsA(isA<NetworkException>()),
      );
    });

    test('getBedsForHospital throws BedRepositoryException when client is null and no executor provided', () async {
      final repository = SupabaseBedRepository();

      expect(
        () => repository.getBedsForHospital('hosp-01'),
        throwsA(isA<BedRepositoryException>()),
      );
    });
  });
}
