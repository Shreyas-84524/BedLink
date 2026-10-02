import '../../../../shared/models/user_role.dart';

/// Clinical user credentials for BedLink login.
class AuthCredentials {
  const AuthCredentials({
    required this.identifier,
    required this.password,
    required this.role,
  });

  /// 10-digit numeric ID or operational callsign (e.g. "1010101010" or "amb-101")
  final String identifier;

  /// Clinical user password / passcode
  final String password;

  /// Selected role
  final UserRole role;
}
