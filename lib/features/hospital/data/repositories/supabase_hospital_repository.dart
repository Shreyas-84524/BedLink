import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_codes.dart';
import '../../../matching/domain/models/hospital_match.dart';
import '../../domain/repositories/hospital_repository.dart';
import '../models/supabase_hospital_dto.dart';

/// Real cloud implementation of [HospitalRepository] querying Supabase `public.hospitals`.
class SupabaseHospitalRepository implements HospitalRepository {
  SupabaseHospitalRepository({
    this.client,
    this.queryExecutor,
  });

  final SupabaseClient? client;
  final Future<List<Map<String, dynamic>>> Function({bool activeOnly})? queryExecutor;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<HospitalMatch>> getHospitals({bool activeOnly = true}) async {
    try {
      final List<Map<String, dynamic>> rawRows;

      if (queryExecutor != null) {
        rawRows = await queryExecutor!(activeOnly: activeOnly);
      } else {
        if (client == null) {
          throw const HospitalRepositoryException(
            'SupabaseClient is not initialized. Please verify SUPABASE_URL and SUPABASE_ANON_KEY.',
            code: ErrorCodes.unknownError,
          );
        }

        var query = client!.from('hospitals').select('*');
        if (activeOnly) {
          query = query.eq('is_active', true);
        }

        final response = await query.order('name', ascending: true);
        rawRows = List<Map<String, dynamic>>.from(response);
      }

      if (rawRows.isEmpty) {
        debugPrint('Supabase query returned 0 hospital records (possible default-deny RLS or empty table).');
      }

      final matches = <HospitalMatch>[];
      for (var i = 0; i < rawRows.length; i++) {
        final dto = SupabaseHospitalDto.fromJson(rawRows[i]);
        matches.add(dto.toDomainMatch(rank: i + 1));
      }

      return List.unmodifiable(matches);
    } on PostgrestException catch (e, stack) {
      debugPrint('PostgrestException during getHospitals: ${e.code} - ${e.message}\n$stack');

      final isRlsIssue = e.code == '42501' ||
          e.code == 'PGRST301' ||
          e.message.toLowerCase().contains('permission denied') ||
          e.message.toLowerCase().contains('row-level security') ||
          e.message.toLowerCase().contains('policy');

      if (isRlsIssue) {
        throw HospitalRepositoryException(
          'Supabase RLS is enabled with 0 policies on public.hospitals (default deny). '
          'Approval of a safe client SELECT policy is required to read live data directly from Flutter.',
          code: ErrorCodes.rlsDenied,
          isRlsBlock: true,
          cause: e,
        );
      }

      throw HospitalRepositoryException(
        'Database error querying hospital directory: ${e.message}',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    } on AppException {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(
        'Timed out while connecting to Supabase hospital directory.',
        cause: e,
      );
    } catch (e, stack) {
      debugPrint('Unexpected error querying Supabase hospitals: $e\n$stack');
      throw HospitalRepositoryException(
        'Failed to load hospital directory from Supabase: $e',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    }
  }

  @override
  Future<HospitalMatch?> getHospitalById(String id) async {
    try {
      if (queryExecutor != null) {
        final all = await getHospitals();
        try {
          return all.firstWhere((h) => h.id == id);
        } catch (_) {
          return null;
        }
      }

      if (client == null) {
        throw const HospitalRepositoryException(
          'SupabaseClient is not initialized.',
          code: ErrorCodes.unknownError,
        );
      }

      final response = await client!
          .from('hospitals')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;

      final dto = SupabaseHospitalDto.fromJson(response);
      return dto.toDomainMatch(rank: 1);
    } on PostgrestException catch (e) {
      final isRlsIssue = e.code == '42501' ||
          e.message.toLowerCase().contains('permission denied') ||
          e.message.toLowerCase().contains('row-level security');

      if (isRlsIssue) {
        throw HospitalRepositoryException(
          'Supabase RLS is blocking access to hospital detail.',
          code: ErrorCodes.rlsDenied,
          isRlsBlock: true,
          cause: e,
        );
      }

      throw HospitalRepositoryException(
        'Database error querying hospital by ID: ${e.message}',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    } catch (e) {
      throw HospitalRepositoryException(
        'Failed to fetch hospital by ID: $e',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    }
  }
}
