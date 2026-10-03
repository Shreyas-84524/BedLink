import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_codes.dart';
import '../../domain/repositories/bed_repository.dart';
import '../models/supabase_bed_dto.dart';

/// Real cloud implementation of [BedRepository] querying Supabase `public.beds`.
class SupabaseBedRepository implements BedRepository {
  SupabaseBedRepository({
    this.client,
    this.queryExecutor,
  });

  final SupabaseClient? client;
  final Future<List<Map<String, dynamic>>> Function(String hospitalId)? queryExecutor;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<List<SupabaseBedDto>> getBedsForHospital(String hospitalId) async {
    try {
      final List<Map<String, dynamic>> rawRows;

      if (queryExecutor != null) {
        rawRows = await queryExecutor!(hospitalId);
      } else {
        if (client == null) {
          throw const BedRepositoryException(
            'SupabaseClient is not initialized. Please verify configuration.',
            code: ErrorCodes.unknownError,
          );
        }

        final response = await client!
            .from('beds')
            .select('*')
            .eq('hospital_id', hospitalId)
            .order('bed_type', ascending: true);

        rawRows = List<Map<String, dynamic>>.from(response);
      }

      if (rawRows.isEmpty) {
        debugPrint(
          'Supabase bed query returned 0 rows for hospital $hospitalId '
          '(possible default-deny RLS or no beds seeded for this facility).',
        );
      }

      final dtos = rawRows.map(SupabaseBedDto.fromJson).toList();
      return List.unmodifiable(dtos);
    } on PostgrestException catch (e, stack) {
      debugPrint('PostgrestException during getBedsForHospital: ${e.code} - ${e.message}\n$stack');

      final isRlsIssue = e.code == '42501' ||
          e.code == 'PGRST301' ||
          e.message.toLowerCase().contains('permission denied') ||
          e.message.toLowerCase().contains('row-level security') ||
          e.message.toLowerCase().contains('policy');

      if (isRlsIssue) {
        throw BedRepositoryException(
          'Supabase RLS is enabled with 0 policies on public.beds (default deny). '
          'Approval of a client SELECT policy is required to read live bed inventory.',
          code: ErrorCodes.rlsDenied,
          isRlsBlock: true,
          cause: e,
        );
      }

      throw BedRepositoryException(
        'Database error querying bed inventory: ${e.message}',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    } on AppException {
      rethrow;
    } on TimeoutException catch (e) {
      throw NetworkException(
        'Timed out while connecting to Supabase bed inventory.',
        cause: e,
      );
    } catch (e, stack) {
      debugPrint('Unexpected error querying Supabase beds: $e\n$stack');
      throw BedRepositoryException(
        'Failed to load bed inventory from Supabase: $e',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    }
  }
}
