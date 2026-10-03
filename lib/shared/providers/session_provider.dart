import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/data/supabase_client_provider.dart';
import '../../features/auth/data/repositories/mock_auth_repository.dart';
import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/auth/domain/models/auth_credentials.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../models/user_role.dart';

/// Complete Session State representation for BedLink frontend.
class SessionState {
  const SessionState({
    required this.role,
    this.userId,
    this.displayName,
    this.organizationId,
    this.organizationName,
    this.department,
    this.stationId,
    this.isLoading = false,
    this.errorMessage,
  });

  final UserRole role;
  final String? userId;
  final String? displayName;
  final String? organizationId;
  final String? organizationName;
  final String? department;
  final String? stationId;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => role.isAuthenticated && userId != null;
  bool get isAmbulance => role == UserRole.ambulanceCrew;
  bool get isHospital => role == UserRole.hospitalStaff;

  factory SessionState.unauthenticated() {
    return const SessionState(role: UserRole.unauthenticated);
  }

  factory SessionState.loading({UserRole role = UserRole.unauthenticated}) {
    return SessionState(role: role, isLoading: true);
  }

  factory SessionState.mockAmbulance() {
    return const SessionState(
      role: UserRole.ambulanceCrew,
      userId: 'usr-amb-101',
      displayName: 'Crew Lead Sharma',
      organizationId: 'amb-101',
      organizationName: 'Mumbai EMS Unit 101',
      department: 'Central Emergency Dispatch Zone',
      stationId: 'Dadar EMS Station',
    );
  }

  factory SessionState.mockHospital() {
    return const SessionState(
      role: UserRole.hospitalStaff,
      userId: 'usr-hosp-kem-01',
      displayName: 'Dr. A. Mehta (Triage Lead)',
      organizationId: 'hosp-kem-01',
      organizationName: 'KEM Hospital Mumbai',
      department: 'Emergency & Trauma Department',
      stationId: 'Parel Campus',
    );
  }

  SessionState copyWith({
    UserRole? role,
    String? userId,
    String? displayName,
    String? organizationId,
    String? organizationName,
    String? department,
    String? stationId,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      role: role ?? this.role,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
      department: department ?? this.department,
      stationId: stationId ?? this.stationId,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider for the AuthRepository with dynamic switching between Mock and Supabase Cloud.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  final client = ref.watch(supabaseClientProvider);
  if (config.useMock || client == null) {
    return MockAuthRepository();
  }
  return SupabaseAuthRepository(client: client);
});

/// Central Session Notifier managing active login state across the Flutter app.
class SessionNotifier extends Notifier<SessionState> {
  late final AuthRepository _authRepository;

  @override
  SessionState build() {
    _authRepository = ref.read(authRepositoryProvider);
    // Asynchronously restore persisted session if available
    Future.microtask(() => restoreSession());
    return SessionState.unauthenticated();
  }

  /// Restore active session from Supabase or local storage.
  Future<void> restoreSession() async {
    try {
      final session = await _authRepository.getCurrentSession();
      if (session.isAuthenticated) {
        state = session;
      }
    } catch (e) {
      debugPrint('Failed to restore session: $e');
    }
  }

  /// Perform login using typed credentials via the repository.
  Future<bool> login(AuthCredentials credentials) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepository.login(credentials);
      state = session;
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', '').replaceFirst('AuthException: ', ''),
      );
      return false;
    }
  }

  /// Direct one-tap mock login as Ambulance Crew
  Future<void> loginAsAmbulance() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepository.login(
        const AuthCredentials(
          identifier: '1010101010',
          password: 'password123',
          role: UserRole.ambulanceCrew,
        ),
      );
      state = session;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Direct one-tap mock login as Hospital Staff
  Future<void> loginAsHospital() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _authRepository.login(
        const AuthCredentials(
          identifier: '9090909090',
          password: 'password123',
          role: UserRole.hospitalStaff,
        ),
      );
      state = session;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Clear the active clinical session.
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.logout();
    } finally {
      state = SessionState.unauthenticated();
    }
  }

  /// Clear any active error banner.
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

/// App-wide Session Provider
final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
