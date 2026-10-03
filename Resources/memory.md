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
  - Phase 14: Real Routing + Map Integration (MapLibre, MapTiler, OpenRouteService) — **NEXT**

## Current status
- **Current Phase:** Phase 13 — Real Location + Hospital Discovery Integration
- **Current Sub-Phase:** Phase 13 Location Defect Remediated; Ready for Manual Testing.
- **Completed work:**
  - Resolved manual test defect: eliminated silent Mumbai coordinate fallback (`18.9980, 72.8300`) in real mode.
  - Bound `locationRepositoryProvider` dynamically to `hospitalRepository.isRealBackend`: resolves `GeolocatorLocationRepository` in real mode and `MockLocationRepository` in offline/mock mode.
  - Initialized `AmbulanceLocationState.initial` with `location: null` when backed by real backend.
  - Enforced GPS permission gate in `MatchingNotifier.runSearchProgression`: halts search, clears matches, and surfaces actionable error prompt when location services are disabled or permission denied/deniedForever.
  - Added dedicated actionable status cards to `HospitalDiscoveryScreen`:
    - `SERVICE DISABLED`: "LOCATION SERVICES DISABLED" with buttons "OPEN LOCATION SETTINGS" / "RETRY".
    - `PERMISSION DENIED`: "LOCATION ACCESS REQUIRED" with button "ALLOW LOCATION".
    - `PERMISSION DENIED FOREVER`: "LOCATION PERMISSION BLOCKED" with button "OPEN APP SETTINGS".
    - `ERROR / TIMEOUT`: "UNABLE TO GET CURRENT LOCATION" with button "RETRY LOCATION".
  - Implemented `openAppSettings()` and `openLocationSettings()` in `LocationRepository` via Geolocator.
  - Added live GPS diagnostic section to `DevFixtureCenter` displaying location source (`REAL GPS` vs `MOCK FIXTURE`), status, and coordinates.
  - Added 8 integration tests in `test/features/matching/location_discovery_integration_test.dart` validating permission flow, real repo selection, null coordinates on error, halted discovery on denied permission, settings action, exact coordinates propagation, and coordinate-dependent hospital ranking.
  - Preserved working tree without creating new commits.

## Architecture & Integration Details
- **Location Provider Location:** `lib/core/services/location/location_provider.dart`
- **Location Repository:** `lib/core/services/location/location_repository.dart`
- **Geolocator Implementation:** `lib/core/services/location/geolocator_location_repository.dart`
- **Discovery Provider:** `lib/features/matching/presentation/providers/hospital_discovery_provider.dart`
- **Matching Provider:** `lib/features/matching/presentation/providers/matching_provider.dart`
- **Matching Screen:** `lib/features/matching/presentation/screens/hospital_discovery_screen.dart`
- **Dev Fixture Center:** `lib/shared/widgets/demo/dev_fixture_center.dart`

## Verification results
- `flutter analyze`: 0 issues found (clean static analysis).
- `flutter test --concurrency=1`: 269/269 tests passed across all test suites (100% pass rate).
- `flutter build web --release --dart-define-from-file=config/supabase.json`: Built cleanly (exit code 0).
- Working tree: All edits remain unstaged/uncommitted awaiting manual testing.

## Next recommended task
User manual testing of real location acquisition and hospital discovery in web/device runtime. Following approval, run `git add . && git commit -m "chore(phase-13): approve location and discovery integration"`.
