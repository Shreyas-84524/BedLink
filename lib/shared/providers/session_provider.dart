import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';

class SessionState {
  const SessionState({
    required this.role,
    this.userId,
    this.displayName,
    this.organizationId,
    this.organizationName,
  });

  final UserRole role;
  final String? userId;
  final String? displayName;
  final String? organizationId;
  final String? organizationName;

  factory SessionState.unauthenticated() {
    return const SessionState(role: UserRole.unauthenticated);
  }

  factory SessionState.mockAmbulance() {
    return const SessionState(
      role: UserRole.ambulanceCrew,
      userId: 'user-amb-101',
      displayName: 'Crew Lead - Unit 101',
      organizationId: 'amb-101',
      organizationName: 'Mumbai EMS Unit 101',
    );
  }

  factory SessionState.mockHospital() {
    return const SessionState(
      role: UserRole.hospitalStaff,
      userId: 'user-hosp-kem',
      displayName: 'Dr. Triage Lead',
      organizationId: 'hosp-kem-01',
      organizationName: 'KEM Hospital Mumbai',
    );
  }

  SessionState copyWith({
    UserRole? role,
    String? userId,
    String? displayName,
    String? organizationId,
    String? organizationName,
  }) {
    return SessionState(
      role: role ?? this.role,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      organizationId: organizationId ?? this.organizationId,
      organizationName: organizationName ?? this.organizationName,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    // Default to unauthenticated session in foundation phase
    return SessionState.unauthenticated();
  }

  void loginAsAmbulance() {
    state = SessionState.mockAmbulance();
  }

  void loginAsHospital() {
    state = SessionState.mockHospital();
  }

  void logout() {
    state = SessionState.unauthenticated();
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(
  SessionNotifier.new,
);
