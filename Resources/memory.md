# BedLink Project Memory

Operational memory for BedLink development.

## Current responsibility
Complete BedLink Flutter frontend & Supabase cloud backend integration (Ambulance Dispatch & Hospital Staff interfaces).

## Current development model
15 Major Phases × 8 Sub-Phases = 120 Sub-Phases.

## Phase categorization
- **Frontend-only phases:** Phases 1–10 (Mock/local functional flows, Riverpod state, repository interfaces) — **COMPLETE & FROZEN**
- **Core backend integration:** Phases 11–12 (Supabase Auth, PostgreSQL, RLS, Realtime)
  - Phase 11: Supabase Connection + Existing Hospital Directory Integration — **COMPLETE & VERIFIED**
  - Phase 12: Bed Availability & Live Inventory Synchronization — **COMPLETE & VERIFIED**
- **External API integration:** Phases 13–15 (Geolocator, Discovery API, MapLibre/MapTiler, ORS Matrix/Directions, E2E Recovery)
  - Phase 13: Real Location + Hospital Discovery Integration — **COMPLETE & VERIFIED**
  - Phase 14: Real Routing + Map Integration (MapLibre, MapTiler, OpenRouteService) — **COMPLETE & VERIFIED**
  - Phase 15: Complete Backend/API E2E, Offline Recovery & Release — **COMPLETE & VERIFIED**

## Current status
- **Current Phase:** Phase 15 — Real Backend E2E + Auth + Mock Removal + Release
- **Current Sub-Phase:** Phase 15 Release Complete (Sub-phases 15.1 to 15.8 Complete & Verified).
- **Completed work:**
  - Implemented Phase 15 Real Backend E2E + Auth + Mock Removal + Release:
    - **15.1 Real Supabase Auth & Role-Based Access Control:**
      - Created `SupabaseAuthRepository` implementing GoTrue email/password authentication.
      - Implemented canonical identifier mapping (`amb.$id@bedlink.org` and `hosp.$id@bedlink.org`).
      - Enforced role validation (`ambulance_crew` vs `hospital_staff`) with automatic wrong-role sign-out and exception blocking.
      - Integrated session restoration in `SessionNotifier` and `SplashScreen`.
    - **15.2 Real Emergency Requests Persistence:**
      - Defined `EmergencyRequest` domain model matching `public.ambulance_requests` schema.
      - Implemented `SupabaseEmergencyRequestRepository` with CRUD and Supabase Realtime channel stream listeners.
      - Created `activeEmergencyRequestProvider` for in-flight request management and startup recovery.
    - **15.3 Server-Authoritative Holds & Concurrency Protection:**
      - Implemented `SupabaseBedMutationRepository` executing atomic bed slot reservations, occupancy updates, and releases on `public.beds` with optimistic concurrency locking.
      - Enhanced `HoldTimerNotifier` to resolve fallbacks from real `matchingProvider.matches`, dispatch real emergency requests to Supabase, and stream live status updates.
    - **15.4 Real Hospital Triage Dashboard & Live Stream:**
      - Connected `HospitalStateNotifier` to `watchHospitalRequests` Realtime stream.
      - Wired `acceptRequest()`, `rejectRequest()`, and `markHoldArrived()` to Supabase mutation repositories.
    - **15.5 Production Mock Isolation:**
      - Strictly isolated `MockHospitalData`, `MockLocationRepository`, and `DevFixtureCenter` behind `config.useMock`.
      - Suppressed demo credentials cards, fixture switcher buttons, and mock offer controller bars in production mode.
    - **15.6 Active Workflow Recovery & Reconnect:**
      - Connected `SplashScreen` to restore persisted sessions and in-flight active emergency requests.
      - Connected `NavigationStateNotifier` arrival and handoff actions to update Supabase status.
    - **15.7 Testing & Release Verification:**
      - Added comprehensive `phase15_backend_e2e_test.dart` suite covering all 5 areas.
      - Passed `flutter analyze` with 0 issues.
      - Passed `flutter test --concurrency=1` with 345/345 tests green (100% pass rate).
      - Successfully compiled release web bundle: `flutter build web --release --dart-define-from-file=config/supabase.json`.
- **Files changed:**
  - `lib/core/config/supabase_config.dart`
  - `lib/core/data/supabase_client_provider.dart`
  - `lib/features/ambulance/domain/models/emergency_request.dart`
  - `lib/features/ambulance/domain/repositories/emergency_request_repository.dart`
  - `lib/features/ambulance/data/repositories/mock_emergency_request_repository.dart`
  - `lib/features/ambulance/data/repositories/supabase_emergency_request_repository.dart`
  - `lib/features/ambulance/presentation/providers/emergency_request_provider.dart`
  - `lib/features/auth/domain/repositories/auth_repository.dart`
  - `lib/features/auth/data/repositories/supabase_auth_repository.dart`
  - `lib/features/auth/presentation/screens/login_screen.dart`
  - `lib/features/auth/presentation/screens/splash_screen.dart`
  - `lib/features/hospital/domain/repositories/bed_mutation_repository.dart`
  - `lib/features/hospital/data/repositories/supabase_bed_mutation_repository.dart`
  - `lib/features/hospital/presentation/providers/bed_repository_provider.dart`
  - `lib/features/hospital/presentation/providers/hospital_state_provider.dart`
  - `lib/features/hospital/presentation/screens/hospital_requests_screen.dart`
  - `lib/features/matching/presentation/providers/matching_provider.dart`
  - `lib/features/navigation/presentation/providers/navigation_state_provider.dart`
  - `lib/features/reservation/presentation/providers/hold_timer_provider.dart`
  - `lib/features/reservation/presentation/screens/hold_confirmation_screen.dart`
  - `lib/shared/providers/session_provider.dart`
  - `lib/shared/widgets/chrome/bedlink_app_bar.dart`
  - `lib/shared/widgets/demo/dev_fixture_center.dart`
  - `test/features/phase15/phase15_backend_e2e_test.dart`
  - `PHASE_15_REPORT.md`
- **Verification results:**
  - `flutter analyze`: 0 issues found.
  - `flutter test --concurrency=1`: 345/345 tests passed across all test suites (100% pass rate).
  - `flutter build web --release --dart-define-from-file=config/supabase.json`: Built successfully (`√ Built build\web`).
- **Next recommended task:**
  - Launch & Final Deployment. Platform is fully verified end-to-end.
