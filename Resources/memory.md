# BedLink Project Memory

Operational memory for BedLink development.

## Current responsibility
Complete BedLink Flutter frontend (Ambulance Dispatch & Hospital Staff interfaces).

## Current development model
15 Major Phases × 8 Sub-Phases = 120 Sub-Phases.

## Phase categorization
- **Frontend-only phases:** Phases 1–10 (Mock/local functional flows, Riverpod state, repository interfaces)
- **Core backend integration:** Phases 11–12 (Supabase Auth, PostgreSQL, RLS, Realtime)
- **External API integration:** Phases 13–15 (Geolocator, Discovery API, MapLibre/MapTiler, ORS Matrix/Directions, E2E Recovery)

## Current status
- **Current Phase:** Phase 3 (Application Shell, Authentication UI & Role Navigation)
- **Current Sub-Phase:** 3.8 completed (Comprehensive Auth Flow & Role Navigation Verification)
- **Completed work:**
  - Phase 1 & Phase 2 approved and finalized (`chore(phase-1): approve flutter foundation`, `chore(phase-2): approve bedlink design system`).
  - Sub-phase 3.1: Application Splash Screen & Initialization Flow (`lib/features/auth/presentation/screens/splash_screen.dart`).
  - Sub-phase 3.2: Role-Based Authentication Screen (`lib/features/auth/presentation/screens/login_screen.dart` with dual role selector and 10-digit ID/password validation).
  - Sub-phase 3.3: Mock Authentication Repository & Account Fixtures (`lib/features/auth/domain/repositories/auth_repository.dart`, `lib/features/auth/data/repositories/mock_auth_repository.dart`, `lib/features/auth/domain/models/auth_credentials.dart`).
  - Sub-phase 3.4: Ambulance Application Shell & Navigation Structure (`lib/features/ambulance/presentation/screens/ambulance_dashboard_screen.dart`, sequential workflow cards for Phases 4–9).
  - Sub-phase 3.5: Hospital Application Shell & Operational Sections (`lib/features/hospital/presentation/screens/hospital_dashboard_screen.dart`, live capacity snapshot & Phase 8 operational module hubs).
  - Sub-phase 3.6: Declarative Route Configuration & Role Guards (`lib/app/router.dart` with `_GoRouterRefreshNotifier` linked to `sessionProvider`, role-based redirect protection).
  - Sub-phase 3.7: Session State Management & Auth Exceptions (`lib/shared/providers/session_provider.dart`, `lib/shared/widgets/errors/access_denied_screen.dart`, `lib/shared/widgets/errors/not_found_screen.dart`).
  - Sub-phase 3.8: Comprehensive Auth Flow & Role Navigation Verification (`test/app/router_test.dart`, `test/features/auth/auth_flow_test.dart`, `test/features/ambulance/ambulance_shell_test.dart`, `test/features/hospital/hospital_shell_test.dart`).
  - `PHASE_3_REPORT.md` generated.

## Verification results
- `flutter analyze`: 0 issues found (strict mode enabled).
- `flutter test`: 59/59 tests passed across 12 test suites.
- `flutter build web`: Built cleanly to `build/web` (115.9s).
- Compact viewport validation: 320dp width verified without RenderFlex overflow.

## Current files
- `lib/core/theme/*`
- `lib/shared/models/*`, `lib/shared/providers/*`, `lib/shared/widgets/*`
- `lib/features/auth/*`
- `lib/features/ambulance/*`
- `lib/features/hospital/*`
- `lib/features/matching/*`, `lib/features/reservation/*`, `lib/features/navigation/*` (scaffolded shells)
- `lib/features/design_system/*`
- `lib/app/router.dart`, `lib/app/app.dart`, `lib/main.dart`
- `test/app/*`, `test/features/*`, `test/shared/*`, `test/core/*`
- `PHASE_3_REPORT.md`

## Next recommended task
Await manual testing and explicit user approval (`APPROVED`) to create `chore(phase-3): approve authentication and role navigation`, then proceed to Phase 4 (Ambulance Patient Intake & Clinical Triage UI).
