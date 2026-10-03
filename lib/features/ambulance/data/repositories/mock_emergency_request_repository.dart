import 'dart:async';
import '../../domain/models/emergency_request.dart';
import '../../domain/repositories/emergency_request_repository.dart';

/// In-memory mock implementation of [EmergencyRequestRepository] for tests and mock mode.
class MockEmergencyRequestRepository implements EmergencyRequestRepository {
  MockEmergencyRequestRepository({
    List<EmergencyRequest>? initialRequests,
  }) : _requests = List.of(initialRequests ?? []);

  final List<EmergencyRequest> _requests;
  final _changeStream = StreamController<void>.broadcast();

  @override
  bool get isRealBackend => false;

  @override
  String get dataSourceName => 'MOCK_FIXTURE';

  @override
  Future<EmergencyRequest> createRequest(EmergencyRequest request) async {
    final newReq = request.copyWith(
      id: request.id.isNotEmpty ? request.id : 'REQ-${DateTime.now().millisecondsSinceEpoch}',
    );
    _requests.add(newReq);
    _changeStream.add(null);
    return newReq;
  }

  @override
  Future<EmergencyRequest?> getRequestById(String id) async {
    try {
      return _requests.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<EmergencyRequest?> getActiveRequestForAmbulance(String ambulanceId) async {
    try {
      return _requests.lastWhere(
        (r) => r.ambulanceId == ambulanceId && (r.status.isPending || r.status.isReserved),
      );
    } catch (_) {
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
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx < 0) {
      throw StateError('Request $requestId not found in mock store');
    }

    final updated = _requests[idx].copyWith(
      status: newStatus,
      hospitalId: hospitalId ?? _requests[idx].hospitalId,
      hospitalName: hospitalName ?? _requests[idx].hospitalName,
      expiresAt: expiresAt ?? _requests[idx].expiresAt,
    );
    _requests[idx] = updated;
    _changeStream.add(null);
    return updated;
  }

  @override
  Future<List<EmergencyRequest>> getRequestsForHospital(String hospitalId) async {
    return _requests.where((r) {
      return r.hospitalId == null || r.hospitalId == hospitalId;
    }).toList();
  }

  @override
  Stream<EmergencyRequest?> watchRequest(String requestId) async* {
    yield await getRequestById(requestId);
    yield* _changeStream.stream.asyncMap((_) => getRequestById(requestId));
  }

  @override
  Stream<List<EmergencyRequest>> watchHospitalRequests(String hospitalId) async* {
    yield await getRequestsForHospital(hospitalId);
    yield* _changeStream.stream.asyncMap((_) => getRequestsForHospital(hospitalId));
  }

  void dispose() {
    _changeStream.close();
  }
}
