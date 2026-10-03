import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/supabase_client_provider.dart';
import '../../data/repositories/mock_emergency_request_repository.dart';
import '../../data/repositories/supabase_emergency_request_repository.dart';
import '../../domain/models/emergency_request.dart';
import '../../domain/repositories/emergency_request_repository.dart';

/// Provider exposing the active [EmergencyRequestRepository] with dynamic cloud switching.
final emergencyRequestRepositoryProvider = Provider<EmergencyRequestRepository>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  final client = ref.watch(supabaseClientProvider);
  if (config.useMock || client == null) {
    return MockEmergencyRequestRepository();
  }
  return SupabaseEmergencyRequestRepository(client: client);
});

/// State for the current active emergency request.
class ActiveEmergencyRequestState {
  const ActiveEmergencyRequestState({
    this.request,
    this.isLoading = false,
    this.errorMessage,
  });

  final EmergencyRequest? request;
  final bool isLoading;
  final String? errorMessage;

  ActiveEmergencyRequestState copyWith({
    EmergencyRequest? request,
    bool? isLoading,
    String? errorMessage,
    bool clearRequest = false,
    bool clearError = false,
  }) {
    return ActiveEmergencyRequestState(
      request: clearRequest ? null : (request ?? this.request),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Notifier managing active emergency request dispatch, real-time sync, and recovery.
class ActiveEmergencyRequestNotifier extends Notifier<ActiveEmergencyRequestState> {
  late final EmergencyRequestRepository _repository;

  @override
  ActiveEmergencyRequestState build() {
    _repository = ref.read(emergencyRequestRepositoryProvider);
    return const ActiveEmergencyRequestState();
  }

  /// Restores active in-flight request for ambulance on app restart (Workflow Recovery 15.4 / Section 4).
  Future<void> restoreActiveRequest(String ambulanceId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final active = await _repository.getActiveRequestForAmbulance(ambulanceId);
      if (active != null) {
        state = state.copyWith(request: active, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      debugPrint('Failed to restore active emergency request: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Dispatches a new emergency request to Supabase.
  Future<EmergencyRequest?> dispatchRequest(EmergencyRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final created = await _repository.createRequest(request);
      state = state.copyWith(request: created, isLoading: false);
      return created;
    } catch (e) {
      debugPrint('Failed to dispatch emergency request: $e');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  /// Updates status of active emergency request.
  Future<void> setStatus(
    EmergencyRequestStatus status, {
    String? hospitalId,
    String? hospitalName,
    DateTime? expiresAt,
  }) async {
    final cur = state.request;
    if (cur == null) return;

    try {
      final updated = await _repository.updateRequestStatus(
        cur.id,
        status,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        expiresAt: expiresAt,
      );
      state = state.copyWith(request: updated);
    } catch (e) {
      debugPrint('Failed to update emergency request status: $e');
    }
  }

  /// Clears active request once transport or handoff is fully completed.
  void clear() {
    state = const ActiveEmergencyRequestState();
  }
}

/// App-wide provider for active emergency request.
final activeEmergencyRequestProvider =
    NotifierProvider<ActiveEmergencyRequestNotifier, ActiveEmergencyRequestState>(
  ActiveEmergencyRequestNotifier.new,
);
