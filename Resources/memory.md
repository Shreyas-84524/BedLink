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
- **Current Phase:** Phase 1 (Flutter Project Bootstrap & Core Foundation)
- **Current Sub-Phase:** 1.8 completed (Phase 1 validation passed)
- **Completed work:**
  - `Resources/Phases.md` reconfigured to 15-phase roadmap with 2-commit per phase rule.
  - Flutter project created at repository root targeting Android and Web.
  - Strict static analysis enabled (`strict-casts`, `strict-inference`, `strict-raw-types`).
  - Foundation dependencies configured (`flutter_riverpod`, `go_router`).
  - Feature-first folder structure established (`app/`, `core/`, `shared/`, `features/`).
  - Riverpod root configured with `bootstrap.dart`, `sessionProvider`, and error boundaries.
  - GoRouter routing established with all required `/`, `/login`, `/ambulance/*`, `/hospital/*` placeholder screens.
  - 18 unit/widget/routing tests created and verified.
  - `PHASE_1_REPORT.md` generated.

## Verification results
- `flutter analyze`: 0 issues found (strict mode enabled).
- `flutter test`: 18/18 tests passed across 4 test suites.
- `flutter build web`: Built cleanly to `build/web`.

## Current files
- `pubspec.yaml`, `analysis_options.yaml`
- `lib/main.dart`, `lib/app/*`, `lib/core/*`, `lib/shared/*`, `lib/features/*`
- `test/widget_test.dart`, `test/app/router_test.dart`, `test/shared/session_provider_test.dart`, `test/core/constants_test.dart`
- `PHASE_1_REPORT.md`, `Resources/Phases.md`

## Next recommended task
Await manual testing and explicit user approval (`APPROVED`) to create `chore(phase-1): approve flutter foundation`, then proceed to Phase 2 (BedLink Design System).
