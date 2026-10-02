# BedLink Project Memory

Operational memory for BedLink development.

## Current responsibility
Complete BedLink Flutter frontend (Ambulance Dispatch & Hospital Staff interfaces).

## Current development model
15 Major Phases × 8 Sub-Phases = 120 Sub-Phases.

## Phase categorization
- **Frontend-only phases:** Phases 1–10 (Mock/local functional flows, Riverpod state, repository interfaces) — **COMPLETE & FROZEN**
- **Core backend integration:** Phases 11–12 (Supabase Auth, PostgreSQL, RLS, Realtime)
- **External API integration:** Phases 13–15 (Geolocator, Discovery API, MapLibre/MapTiler, ORS Matrix/Directions, E2E Recovery)

## Current status
- **Current Phase:** Phase 10 — Frontend Resilience + Complete Mock E2E (Approved & Frozen)
- **Current Sub-Phase:** Phase 10 complete & approved; frontend Phases 1–10 officially frozen; ready for Phase 11 (Supabase Setup & Auth Integration).
- **Completed work:**
  - Phases 1 through 9 completed, verified, and approved in Git history.
  - Phase 10 Frontend Resilience + Complete Mock E2E fully implemented & verified:
    - Sub-phase 10.1: Loading States (`BedLinkLoadingIndicator`, `BedLinkSkeletonCard`).
    - Sub-phase 10.2: Empty States (`BedLinkEmptyState`).
    - Sub-phase 10.3: Offline / Reconnecting States (`ConnectivityStatus`, `connectivityProvider`, `ConnectivityBanner`, `MedNetLiveBadge`).
    - Sub-phase 10.4: Error / Failure States (`BedLinkErrorState`, `NotFoundScreen`, `AccessDeniedScreen`).
    - Sub-phase 10.5: Accessibility + Cheap-Phone Optimization (320dp, 360dp, 375dp, 390dp verified; touch targets $\ge 48$dp; WCAG AA contrast).
    - Sub-phase 10.6: Complete Mock Ambulance ↔ Hospital Workflow (`MockEmergencyCoordinator`, `DevFixtureCenter`).
    - Sub-phase 10.7: Regression / Widget / Provider Tests (25 new resilience, connectivity, cross-role, and guard tests; 172/172 full repository tests passing).
    - Sub-phase 10.8: Frontend Freeze Audit (`FRONTEND_FREEZE_AUDIT.md`, `PHASE_10_REPORT.md`).

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 172/172 tests passed across 26 test suites (100% pass rate).
- `flutter build web`: Built cleanly to `build/web` (exit code 0).
- Compact viewport validation: 320dp, 360dp, 375dp, 390dp widths verified with zero RenderFlex overflow.
- Frontend Freeze: Complete; UI layer locked; backend handoff matrix defined.

## Current files
- `lib/core/theme/*`
- `lib/shared/models/*`, `lib/shared/providers/*`, `lib/shared/widgets/*`
- `lib/features/auth/*`
- `lib/features/ambulance/*`
- `lib/features/hospital/*`
- `lib/features/matching/*`
- `lib/features/reservation/*`
- `lib/features/navigation/*`
- `lib/features/design_system/*`
- `lib/app/router.dart`, `lib/app/app.dart`, `lib/main.dart`
- `test/*`
- `FRONTEND_FREEZE_AUDIT.md`
- `PHASE_1_REPORT.md` through `PHASE_10_REPORT.md`

## Next recommended task
Proceed to Phase 11 — Supabase Setup & Auth Integration upon user instruction.
