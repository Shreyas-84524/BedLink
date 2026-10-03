import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../../core/errors/app_exception.dart' as app;
import '../../../../core/errors/error_codes.dart';
import '../../../../shared/models/user_role.dart';
import '../../../../shared/providers/session_provider.dart';
import '../../domain/models/auth_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

/// Real Supabase implementation of [AuthRepository] managing Email/Password authentication,
/// session persistence, and role-based access gating.
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository({
    required this.client,
  });

  final supa.SupabaseClient client;

  /// Helper to convert user-entered 10-digit ID or callsign to canonical email.
  static String formatEmailFromIdentifier(String rawIdentifier, UserRole role) {
    final trimmed = rawIdentifier.trim();
    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }
    // Prefix or domain mapping for 10-digit numeric ID or vehicle callsign
    final prefix = role.isAmbulance ? 'amb' : 'hosp';
    return '$prefix.$trimmed@bedlink.org'.toLowerCase();
  }

  /// Resolves [UserRole] from user metadata or app metadata.
  static UserRole resolveRole(supa.User? user, {UserRole? fallbackRole}) {
    if (user == null) return UserRole.unauthenticated;

    final meta = user.userMetadata ?? {};
    final appMeta = user.appMetadata;

    final rawRole = (meta['role'] ?? appMeta['role'] ?? '').toString().toLowerCase();

    if (rawRole.contains('ambulance') || rawRole == 'ambulance_crew') {
      return UserRole.ambulanceCrew;
    }
    if (rawRole.contains('hospital') || rawRole == 'hospital_staff') {
      return UserRole.hospitalStaff;
    }

    // Secondary fallback: email pattern inspection
    final email = user.email?.toLowerCase() ?? '';
    if (email.startsWith('amb') || email.contains('ambulance') || email.contains('crew')) {
      return UserRole.ambulanceCrew;
    }
    if (email.startsWith('hosp') || email.contains('hospital') || email.contains('staff')) {
      return UserRole.hospitalStaff;
    }

    return fallbackRole ?? UserRole.unauthenticated;
  }

  /// Builds a [SessionState] from authenticated Supabase [User].
  static SessionState buildSessionFromUser(supa.User user, {UserRole? expectedRole}) {
    final role = resolveRole(user, fallbackRole: expectedRole);
    final meta = user.userMetadata ?? {};

    final displayName = meta['display_name']?.toString() ??
        (role.isAmbulance ? 'Crew Lead (${user.email})' : 'Dr. Triage (${user.email})');

    final orgId = meta['organization_id']?.toString() ??
        (role.isAmbulance ? 'AMB-108' : 'kem_parel');

    final orgName = meta['organization_name']?.toString() ??
        (role.isAmbulance ? 'Mumbai EMS Fleet Unit' : 'King Edward Memorial Hospital');

    final department = meta['department']?.toString() ??
        (role.isAmbulance ? 'Central Emergency Dispatch' : 'Emergency & Trauma Desk');

    final stationId = meta['station_id']?.toString() ??
        (role.isAmbulance ? 'Dadar EMS Station' : 'Parel Campus');

    return SessionState(
      role: role,
      userId: user.id,
      displayName: displayName,
      organizationId: orgId,
      organizationName: orgName,
      department: department,
      stationId: stationId,
    );
  }

  @override
  Future<SessionState> login(AuthCredentials credentials) async {
    final email = formatEmailFromIdentifier(credentials.identifier, credentials.role);
    final password = credentials.password;

    try {
      final authResponse = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const app.AuthException(
          'Authentication failed: No user returned by authentication server.',
          code: ErrorCodes.authRequired,
        );
      }

      // Role Verification & Wrong-Role Blocking (15.1)
      final actualRole = resolveRole(user, fallbackRole: credentials.role);
      if (actualRole != credentials.role && actualRole.isAuthenticated) {
        // Enforce strict wrong-role gating: sign out immediately
        await client.auth.signOut();
        throw app.AuthException(
          'Wrong-role access blocked: User account is registered as ${actualRole.displayName}, '
          'but attempted to log in to ${credentials.role.displayName} portal.',
          code: ErrorCodes.invalidRole,
        );
      }

      return buildSessionFromUser(user, expectedRole: credentials.role);
    } on supa.AuthException catch (e) {
      debugPrint('Supabase AuthException: [${e.code}] ${e.message}');

      // If email not confirmed, provide clear actionable guidance
      if (e.message.toLowerCase().contains('email not confirmed')) {
        throw const app.AuthException(
          'Email not confirmed in Supabase Auth. Please confirm your email in Supabase dashboard '
          'or disable "Confirm email" in Auth settings.',
          code: ErrorCodes.authRequired,
        );
      }

      if (e.message.toLowerCase().contains('invalid login credentials') ||
          e.message.toLowerCase().contains('invalid_grant')) {
        throw const app.AuthException(
          'Invalid clinical credentials. Please verify your ID and password.',
          code: ErrorCodes.authRequired,
        );
      }

      throw app.AuthException(
        e.message,
        code: ErrorCodes.authRequired,
        cause: e,
      );
    } on app.AppException {
      rethrow;
    } catch (e, stack) {
      debugPrint('Unexpected error during Supabase login: $e\n$stack');
      throw app.AuthException(
        'Unable to connect to authentication server: $e',
        code: ErrorCodes.networkError,
        cause: e,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      debugPrint('Error during Supabase signOut: $e');
    }
  }

  @override
  Future<SessionState> getCurrentSession() async {
    final currentSession = client.auth.currentSession;
    if (currentSession == null) {
      return SessionState.unauthenticated();
    }

    final user = currentSession.user;
    final role = resolveRole(user);
    if (!role.isAuthenticated) {
      return SessionState.unauthenticated();
    }

    return buildSessionFromUser(user);
  }
}
