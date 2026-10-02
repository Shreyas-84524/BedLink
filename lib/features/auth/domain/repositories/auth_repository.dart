import '../../../../shared/providers/session_provider.dart';
import '../models/auth_credentials.dart';

/// Abstract contract for BedLink Authentication.
///
/// Implemented by [MockAuthRepository] in Phase 3–10 and
/// replaced by [SupabaseAuthRepository] in Phase 11 without screen changes.
abstract class AuthRepository {
  /// Attempt login with identifier, password, and expected role.
  Future<SessionState> login(AuthCredentials credentials);

  /// Terminate the active clinical session.
  Future<void> logout();

  /// Retrieve the current cached / persisted session if valid.
  Future<SessionState> getCurrentSession();
}
