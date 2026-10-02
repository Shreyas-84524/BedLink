import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import '../features/ambulance/presentation/screens/bed_requirements_screen.dart';
import '../features/ambulance/presentation/screens/patient_intake_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/design_system/presentation/screens/design_system_screen.dart';
import '../features/hospital/presentation/screens/hospital_dashboard_screen.dart';
import '../features/hospital/presentation/screens/hospital_holds_screen.dart';
import '../features/hospital/presentation/screens/hospital_requests_screen.dart';
import '../features/hospital/presentation/screens/hospital_resources_screen.dart';
import '../features/matching/presentation/screens/hospital_discovery_screen.dart';
import '../features/navigation/presentation/screens/navigation_screen.dart';
import '../features/reservation/presentation/screens/hold_confirmation_screen.dart';
import '../shared/models/user_role.dart';
import '../shared/providers/session_provider.dart';
import '../shared/widgets/errors/access_denied_screen.dart';
import '../shared/widgets/errors/not_found_screen.dart';

/// Notifier that bridges Riverpod SessionState changes to GoRouter's refreshListenable.
class _GoRouterRefreshNotifier extends ChangeNotifier {
  _GoRouterRefreshNotifier(Ref ref) {
    ref.listen<SessionState>(sessionProvider, (previous, next) {
      notifyListeners();
    });
  }
}

/// Central GoRouter configuration for BedLink.
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = _GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      if (state.error != null) {
        return null;
      }

      final session = ref.read(sessionProvider);
      final location = state.matchedLocation;

      final isSplash = location == '/';
      final isLogin = location == '/login';
      final isDesignSystem = location == '/design-system';
      final isAccessDenied = location.startsWith('/access-denied');

      // Design System showcase is always accessible in development
      if (isDesignSystem || isAccessDenied) {
        return null;
      }

      // 1. Unauthenticated users
      if (!session.isAuthenticated) {
        // Allow splash and login screens
        if (isSplash || isLogin) {
          return null;
        }
        // Protect all ambulance and hospital routes
        return '/login';
      }

      // 2. Authenticated Ambulance Crew
      if (session.isAmbulance) {
        // Redirect away from login or splash to ambulance dashboard
        if (isSplash || isLogin) {
          return '/ambulance';
        }
        // Disallow hospital routes and redirect back to ambulance
        if (location.startsWith('/hospital')) {
          return '/ambulance';
        }
        return null;
      }

      // 3. Authenticated Hospital Staff
      if (session.isHospital) {
        // Redirect away from login or splash to hospital dashboard
        if (isSplash || isLogin) {
          return '/hospital';
        }
        // Disallow ambulance routes and redirect back to hospital
        if (location.startsWith('/ambulance')) {
          return '/hospital';
        }
        return null;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginScreen(),
      ),
      GoRoute(
        path: '/design-system',
        name: 'design_system',
        builder: (BuildContext context, GoRouterState state) =>
            const DesignSystemScreen(),
      ),
      GoRoute(
        path: '/access-denied',
        name: 'access_denied',
        builder: (BuildContext context, GoRouterState state) {
          final extra = state.extra as Map<String, dynamic>?;
          final attemptedRoute = extra?['route'] as String? ?? '/';
          final requiredRole = extra?['requiredRole'] as UserRole? ?? UserRole.unauthenticated;
          return AccessDeniedScreen(
            attemptedRoute: attemptedRoute,
            requiredRole: requiredRole,
          );
        },
      ),

      // Ambulance Flow Routes
      GoRoute(
        path: '/ambulance',
        name: 'ambulance_dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const AmbulanceDashboardScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'intake',
            name: 'ambulance_intake',
            builder: (BuildContext context, GoRouterState state) =>
                const PatientIntakeScreen(),
          ),
          GoRoute(
            path: 'requirements',
            name: 'ambulance_requirements',
            builder: (BuildContext context, GoRouterState state) =>
                const BedRequirementsScreen(),
          ),
          GoRoute(
            path: 'hospitals',
            name: 'ambulance_hospitals',
            builder: (BuildContext context, GoRouterState state) =>
                const HospitalDiscoveryScreen(),
          ),
          GoRoute(
            path: 'hold',
            name: 'ambulance_hold',
            builder: (BuildContext context, GoRouterState state) =>
                const HoldConfirmationScreen(),
          ),
          GoRoute(
            path: 'navigation',
            name: 'ambulance_navigation',
            builder: (BuildContext context, GoRouterState state) =>
                const NavigationScreen(),
          ),
        ],
      ),

      // Hospital Flow Routes
      GoRoute(
        path: '/hospital',
        name: 'hospital_dashboard',
        builder: (BuildContext context, GoRouterState state) =>
            const HospitalDashboardScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'resources',
            name: 'hospital_resources',
            builder: (BuildContext context, GoRouterState state) =>
                const HospitalResourcesScreen(),
          ),
          GoRoute(
            path: 'requests',
            name: 'hospital_requests',
            builder: (BuildContext context, GoRouterState state) =>
                const HospitalRequestsScreen(),
          ),
          GoRoute(
            path: 'holds',
            name: 'hospital_holds',
            builder: (BuildContext context, GoRouterState state) =>
                const HospitalHoldsScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (BuildContext context, GoRouterState state) =>
        NotFoundScreen(uri: state.uri.toString()),
  );
});
