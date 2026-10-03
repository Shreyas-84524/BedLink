import '../models/emergency_request.dart';

/// Abstract contract for managing emergency transfer requests and hospital offers.
abstract class EmergencyRequestRepository {
  bool get isRealBackend;
  String get dataSourceName;

  /// Creates a new emergency request row in the backend.
  Future<EmergencyRequest> createRequest(EmergencyRequest request);

  /// Retrieves an emergency request by UUID.
  Future<EmergencyRequest?> getRequestById(String id);

  /// Finds any active en-route or pending emergency request for the given ambulance unit.
  Future<EmergencyRequest?> getActiveRequestForAmbulance(String ambulanceId);

  /// Updates status and metadata of an active emergency request.
  Future<EmergencyRequest> updateRequestStatus(
    String requestId,
    EmergencyRequestStatus newStatus, {
    String? hospitalId,
    String? hospitalName,
    DateTime? expiresAt,
  });

  /// Retrieves all pending and active requests for a hospital receiving desk.
  Future<List<EmergencyRequest>> getRequestsForHospital(String hospitalId);

  /// Stream of active emergency requests for Realtime synchronization.
  Stream<EmergencyRequest?> watchRequest(String requestId);

  /// Stream of incoming requests for a hospital triage desk.
  Stream<List<EmergencyRequest>> watchHospitalRequests(String hospitalId);
}
