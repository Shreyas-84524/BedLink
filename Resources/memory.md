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
- **Current Phase:** Phase 8 — Complete Hospital Staff Frontend (Approved)
- **Current Sub-Phase:** Phase 8 complete & approved; ready for Phase 9 (Active Navigation & Live Transit Frontend).
- **Completed work:**
  - Phases 1 through 7 completed, verified, and approved in Git history.
  - Phase 8 Complete Hospital Staff Frontend fully implemented & verified:
    - Sub-phase 8.1: Hospital Dashboard (`/hospital`) with live capacity snapshot, operational module navigation cards, and one-tap Confirm No Change.
    - Sub-phase 8.2: Resource Inventory Screen (`/hospital/resources`) with Critical Care, Acute & Emergency, and Specialized Clinical Units categorization.
    - Sub-phase 8.3: Fast One-Tap Availability Controls (`BedLinkCounterControl` steppers with strict non-negative and capacity ceiling bounds).
    - Sub-phase 8.4: Data Freshness Protocol (`HospitalFreshnessBar` with Confirm No Change action and interactive simulate-stale evaluation toggle).
    - Sub-phase 8.5: Incoming Emergency Triage Desk (`/hospital/requests`) with 120-second countdown timer, patient acuity, chief complaint, and required resource chips.
    - Sub-phase 8.6: Accept / Divert Triage Actions (Accept transitions available $\to$ held and creates active hold; Divert logs clinical reason; 120s timeout simulation).
    - Sub-phase 8.7: Active Holds & Inbound Transit (`/hospital/holds`) displaying inbound ambulance callsigns, live ETAs, reserved beds breakdown, patient check-in ("CONFIRM ARRIVED"), and capacity release controls ("RELEASE HOLD").
    - Sub-phase 8.8: Integration, Responsive Testing & Verification (320dp width audit, 17 unit and widget tests passing in hospital suites).
  - `PHASE_8_REPORT.md` generated at root.

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 134/134 tests passed across 21 suites (100% pass rate).
- `flutter build web`: Built cleanly to `build/web` (exit code 0).
- Compact viewport validation: 320dp, 360dp, 375dp, 390dp widths verified with zero RenderFlex overflow.

## Current files
- `lib/core/theme/*`
- `lib/shared/models/*`, `lib/shared/providers/*`, `lib/shared/widgets/*`
- `lib/features/auth/*`
- `lib/features/ambulance/*`
- `lib/features/hospital/*` (domain models, providers, widgets, screens)
- `lib/features/matching/*`
- `lib/features/reservation/*`
- `lib/features/navigation/*`
- `lib/features/design_system/*`
- `lib/app/router.dart`, `lib/app/app.dart`, `lib/main.dart`
- `test/*`
- `PHASE_1_REPORT.md` through `PHASE_8_REPORT.md`

## Next recommended task
Proceed to Phase 9 — Active Navigation & Live Transit Frontend upon user instruction.
