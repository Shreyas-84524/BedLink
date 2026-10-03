import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_codes.dart';
import '../../domain/models/emergency_request.dart';
import '../../domain/repositories/emergency_request_repository.dart';

/// Real cloud Supabase implementation of [EmergencyRequestRepository] querying `public.ambulance_requests`.
class SupabaseEmergencyRequestRepository implements EmergencyRequestRepository {
  SupabaseEmergencyRequestRepository({
    this.client,
    this.queryExecutor,
    this.mutationExecutor,
  });

  final SupabaseClient? client;
  final Future<List<Map<String, dynamic>>> Function(String queryType, Map<String, dynamic> params)? queryExecutor;
  final Future<Map<String, dynamic>> Function(String action, Map<String, dynamic> payload)? mutationExecutor;

  @override
  bool get isRealBackend => true;

  @override
  String get dataSourceName => 'SUPABASE_CLOUD';

  @override
  Future<EmergencyRequest> createRequest(EmergencyRequest request) async {
    try {
      if (mutationExecutor != null) {
        final res = await mutationExecutor!('create', request.toJson());
        return EmergencyRequest.fromJson(res);
      }

      if (client == null) {
        throw const AppException(
          message: 'SupabaseClient not initialized for emergency request creation.',
          code: ErrorCodes.unknownError,
        );
      }

      final payload = request.toJson();
      final response = await client!
          .from('ambulance_requests')
          .insert(payload)
          .select()
          .single();

      return EmergencyRequest.fromJson(response);
    } on PostgrestException catch (e, stack) {
      debugPrint('PostgrestException creating emergency request: ${e.code} - ${e.message}\n$stack');
      throw AppException(
        message: 'Database error creating emergency request: ${e.message}',
        code: e.code == '42501' ? ErrorCodes.rlsDenied : ErrorCodes.repositoryError,
        cause: e,
      );
    } catch (e, stack) {
      debugPrint('Unexpected error creating emergency request: $e\n$stack');
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Failed to create emergency request: $e',
        code: ErrorCodes.networkError,
        cause: e,
      );
    }
  }

  @override
  Future<EmergencyRequest?> getRequestById(String id) async {
    try {
      if (queryExecutor != null) {
        final rows = await queryExecutor!('getById', {'id': id});
        if (rows.isEmpty) return null;
        return EmergencyRequest.fromJson(rows.first);
      }

      if (client == null) return null;

      final response = await client!
          .from('ambulance_requests')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return EmergencyRequest.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching emergency request $id: $e');
      return null;
    }
  }

  @override
  Future<EmergencyRequest?> getActiveRequestForAmbulance(String ambulanceId) async {
    try {
      if (queryExecutor != null) {
        final rows = await queryExecutor!('getActive', {'ambulanceId': ambulanceId});
        if (rows.isEmpty) return null;
        return EmergencyRequest.fromJson(rows.first);
      }

      if (client == null) return null;

      final response = await client!
          .from('ambulance_requests')
          .select('*')
          .eq('ambulance_id', ambulanceId)
          .inFilter('status', ['pending', 'matched'])
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return EmergencyRequest.fromJson(response);
    } catch (e) {
      debugPrint('Error finding active request for ambulance $ambulanceId: $e');
      return null;
    }
  }

  @override
  Future<EmergencyRequest> updateRequestStatus(
    String requestId,
    EmergencyRequestStatus newStatus, {
    String? hospitalId,
    String? hospitalName,
    DateTime? expiresAt,
  }) async {
    try {
      final current = await getRequestById(requestId);
      final updatedMeta = Map<String, dynamic>.from(
        current?.toJson()['required_facilities'] as Map<dynamic, dynamic>? ?? {},
      );

      if (hospitalId != null) updatedMeta['hospital_id'] = hospitalId;
      if (hospitalName != null) updatedMeta['hospital_name'] = hospitalName;
      if (expiresAt != null) updatedMeta['expires_at'] = expiresAt.toIso8601String();

      final updatePayload = <String, dynamic>{
        'status': newStatus.toDatabaseStatus(),
        'required_facilities': updatedMeta,
      };

      if (mutationExecutor != null) {
        final res = await mutationExecutor!('update', {'id': requestId, ...updatePayload});
        return EmergencyRequest.fromJson(res);
      }

      if (client == null) {
        throw const AppException(
          message: 'SupabaseClient not initialized for request update.',
          code: ErrorCodes.unknownError,
        );
      }

      final response = await client!
          .from('ambulance_requests')
          .update(updatePayload)
          .eq('id', requestId)
          .select()
          .single();

      return EmergencyRequest.fromJson(response);
    } on PostgrestException catch (e, stack) {
      debugPrint('PostgrestException updating request: ${e.code} - ${e.message}\n$stack');
      throw AppException(
        message: 'Failed to update request: ${e.message}',
        code: ErrorCodes.repositoryError,
        cause: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException(
        message: 'Error updating emergency request: $e',
        code: ErrorCodes.unknownError,
        cause: e,
      );
    }
  }

  @override
  Future<List<EmergencyRequest>> getRequestsForHospital(String hospitalId) async {
    try {
      if (queryExecutor != null) {
        final rows = await queryExecutor!('getForHospital', {'hospitalId': hospitalId});
        return rows.map(EmergencyRequest.fromJson).toList();
      }

      if (client == null) return const [];

      // Query active requests (pending / matched)
      final response = await client!
          .from('ambulance_requests')
          .select('*')
          .inFilter('status', ['pending', 'matched'])
          .order('created_at', ascending: false);

      final allRequests = List<Map<String, dynamic>>.from(response)
          .map(EmergencyRequest.fromJson)
          .toList();

      // Filter for this hospital (or general pending requests)
      return allRequests.where((r) {
        return r.hospitalId == null || r.hospitalId == hospitalId;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching requests for hospital $hospitalId: $e');
      return const [];
    }
  }

  @override
  Stream<EmergencyRequest?> watchRequest(String requestId) {
    if (client == null) {
      return const Stream.empty();
    }

    final controller = StreamController<EmergencyRequest?>.broadcast();

    // Initial fetch
    getRequestById(requestId).then((req) {
      if (!controller.isClosed) controller.add(req);
    });

    // Subscribe via Supabase Realtime channel
    final channel = client!
        .channel('public:ambulance_requests:id=eq.$requestId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ambulance_requests',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: requestId,
          ),
          callback: (payload) {
            final newRow = payload.newRecord;
            if (newRow.isNotEmpty && !controller.isClosed) {
              controller.add(EmergencyRequest.fromJson(newRow));
            }
          },
        )
        .subscribe();

    controller.onCancel = () {
      client?.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Stream<List<EmergencyRequest>> watchHospitalRequests(String hospitalId) {
    if (client == null) {
      return const Stream.empty();
    }

    final controller = StreamController<List<EmergencyRequest>>.broadcast();

    // Initial fetch
    getRequestsForHospital(hospitalId).then((list) {
      if (!controller.isClosed) controller.add(list);
    });

    final channel = client!
        .channel('public:ambulance_requests:hospital')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'ambulance_requests',
          callback: (payload) async {
            final refreshed = await getRequestsForHospital(hospitalId);
            if (!controller.isClosed) controller.add(refreshed);
          },
        )
        .subscribe();

    controller.onCancel = () {
      client?.removeChannel(channel);
    };

    return controller.stream;
  }
}
