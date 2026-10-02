import '../../../../core/errors/app_exception.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../domain/models/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

/// In-memory deterministic mock authentication implementation for Phases 3–10.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository({this.simulatedDelay = Duration.zero});

  /// Configurable simulated latency for realistic loading states in development.
  final Duration simulatedDelay;

  SessionState _currentSession = SessionState.unauthenticated();

  /// Known deterministic demo accounts
  static const Map<String, _MockAccount> _mockAccounts = {
    // Ambulance Crew Demo Account
    '1010101010': _MockAccount(
      identifier: '1010101010',
      password: 'password123',
      role: UserRole.ambulanceCrew,
      userId: 'usr-amb-101',
      displayName: 'Crew Lead Sharma',
      organizationId: 'amb-101',
      organizationName: 'Mumbai EMS Unit 101',
      department: 'Central Emergency Dispatch Zone',
      stationId: 'Dadar EMS Station',
    ),
    'amb-101': _MockAccount(
      identifier: 'amb-101',
      password: 'password123',
      role: UserRole.ambulanceCrew,
      userId: 'usr-amb-101',
      displayName: 'Crew Lead Sharma',
      organizationId: 'amb-101',
      organizationName: 'Mumbai EMS Unit 101',
      department: 'Central Emergency Dispatch Zone',
      stationId: 'Dadar EMS Station',
    ),

    // Hospital Staff Demo Account
    '9090909090': _MockAccount(
      identifier: '9090909090',
      password: 'password123',
      role: UserRole.hospitalStaff,
      userId: 'usr-hosp-kem-01',
      displayName: 'Dr. A. Mehta (Triage Lead)',
      organizationId: 'hosp-kem-01',
      organizationName: 'KEM Hospital Mumbai',
      department: 'Emergency & Trauma Department',
      stationId: 'Parel Campus',
    ),
    'hosp-kem-01': _MockAccount(
      identifier: 'hosp-kem-01',
      password: 'password123',
      role: UserRole.hospitalStaff,
      userId: 'usr-hosp-kem-01',
      displayName: 'Dr. A. Mehta (Triage Lead)',
      organizationId: 'hosp-kem-01',
      organizationName: 'KEM Hospital Mumbai',
      department: 'Emergency & Trauma Department',
      stationId: 'Parel Campus',
    ),
  };

  @override
  Future<SessionState> login(AuthCredentials credentials) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }

    final trimmedId = credentials.identifier.trim();
    final trimmedPass = credentials.password.trim();

    if (trimmedId.isEmpty) {
      throw const AuthException(
        'Please enter your 10-digit ID or Callsign.',
        code: 'INVALID_CREDENTIALS',
      );
    }

    if (trimmedPass.isEmpty) {
      throw const AuthException(
        'Please enter your password.',
        code: 'INVALID_CREDENTIALS',
      );
    }

    // Check account existence
    final account = _mockAccounts[trimmedId];
    if (account == null) {
      // For developer convenience, if unknown ID entered, allow any 10-digit ID with password123
      if (trimmedId.length >= 6 && trimmedPass == 'password123') {
        _currentSession = SessionState(
          role: credentials.role,
          userId: 'usr-${credentials.role.name}-$trimmedId',
          displayName: credentials.role.isAmbulance
              ? 'Paramedic ($trimmedId)'
              : 'Dr. On-Duty ($trimmedId)',
          organizationId: 'org-$trimmedId',
          organizationName: credentials.role.isAmbulance
              ? 'Mumbai EMS Unit $trimmedId'
              : 'General Hospital Mumbai',
          department: credentials.role.isAmbulance
              ? 'Emergency Response'
              : 'Emergency Ward',
          stationId: 'Station $trimmedId',
        );
        return _currentSession;
      }

      throw const AuthException(
        'Account not found. Please verify your 10-digit ID or use demo shortcuts.',
        code: 'USER_NOT_FOUND',
      );
    }

    // Verify password
    if (account.password != trimmedPass) {
      throw const AuthException(
        'Invalid password. Please check your passcode and retry.',
        code: 'WRONG_PASSWORD',
      );
    }

    // Verify role matches
    if (account.role != credentials.role) {
      throw AuthException(
        'Role mismatch: This ID belongs to a ${account.role.displayName}. Please switch role tabs above.',
        code: 'ROLE_MISMATCH',
      );
    }

    _currentSession = SessionState(
      role: account.role,
      userId: account.userId,
      displayName: account.displayName,
      organizationId: account.organizationId,
      organizationName: account.organizationName,
      department: account.department,
      stationId: account.stationId,
    );

    return _currentSession;
  }

  @override
  Future<void> logout() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    _currentSession = SessionState.unauthenticated();
  }

  @override
  Future<SessionState> getCurrentSession() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return _currentSession;
  }
}

class _MockAccount {
  const _MockAccount({
    required this.identifier,
    required this.password,
    required this.role,
    required this.userId,
    required this.displayName,
    required this.organizationId,
    required this.organizationName,
    required this.department,
    required this.stationId,
  });

  final String identifier;
  final String password;
  final UserRole role;
  final String userId;
  final String displayName;
  final String organizationId;
  final String organizationName;
  final String department;
  final String stationId;
}
