import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/ambulance/presentation/screens/ambulance_dashboard_screen.dart';
import '../features/ambulance/presentation/screens/bed_requirements_screen.dart';
import '../features/ambulance/presentation/screens/patient_intake_screen.dart';
import '../features/auth/presentation/screens/login_placeholder_screen.dart';
import '../features/auth/presentation/screens/splash_placeholder_screen.dart';
import '../features/design_system/presentation/screens/design_system_screen.dart';
import '../features/hospital/presentation/screens/hospital_dashboard_screen.dart';
import '../features/hospital/presentation/screens/hospital_holds_screen.dart';
import '../features/hospital/presentation/screens/hospital_requests_screen.dart';
import '../features/hospital/presentation/screens/hospital_resources_screen.dart';
import '../features/matching/presentation/screens/hospital_discovery_screen.dart';
import '../features/navigation/presentation/screens/navigation_screen.dart';
import '../features/reservation/presentation/screens/hold_confirmation_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPlaceholderScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) =>
            const LoginPlaceholderScreen(),
      ),
      GoRoute(
        path: '/design-system',
        name: 'design_system',
        builder: (BuildContext context, GoRouterState state) =>
            const DesignSystemScreen(),
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
    errorBuilder: (BuildContext context, GoRouterState state) => Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Route not found: ${state.uri}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return to Home'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});
