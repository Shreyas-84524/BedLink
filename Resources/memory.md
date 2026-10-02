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
- **Current Phase:** Phase 7 — Two-Minute Hold & Confirmation Frontend (Implemented)
- **Current Sub-Phase:** Phase 7 complete across all sub-phases 7.1–7.8; ready for user review and approval.
- **Completed work:**
  - Phases 1 through 6 completed, verified, and approved.
  - Phase 7 Two-Minute Hold & Confirmation Frontend fully implemented:
    - Sub-phase 7.1: Hold Confirmation Screen (`lib/features/reservation/presentation/screens/hold_confirmation_screen.dart` with safe recovery state and top lifecycle banner).
    - Sub-phase 7.2: Circular Two-Minute Countdown (`lib/features/reservation/presentation/widgets/circular_countdown.dart` with CustomPainter, JetBrains Mono, and 30s/10s color warnings).
    - Sub-phase 7.3: Target Destination / Bed Hold Card (`lib/features/reservation/presentation/widgets/target_hospital_hold_card.dart` with travel time, held resources, trauma phone & status badge).
    - Sub-phase 7.4: Inbound Patient Summary Card (`lib/features/reservation/presentation/widgets/inbound_patient_summary_card.dart` consuming Phase 4 intake and Phase 5 requirements).
    - Sub-phase 7.5: Automatic Safety Fallback UI (`lib/features/reservation/presentation/widgets/fallback_progress_tracker.dart` with sequential standby candidate resolution).
    - Sub-phase 7.6: Mock Accepted / Locked State (LOCKED status, green checkmark, enables `START EN-ROUTE NAVIGATION` CTA to `/ambulance/navigation`).
    - Sub-phase 7.7: Mock Rejected / Timed-Out / Fallback States (decline reason, timeout expiration, fallback advance button).
    - Sub-phase 7.8: Integration, Responsive Testing & Verification (320dp width audit, 14 unit and widget tests passing in reservation suite).
  - `PHASE_7_REPORT.md` generated at root.

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 117/117 tests passed across 19 suites (100% pass rate).
- `flutter build web`: Built cleanly to `build/web`.
- Compact viewport validation: 320dp, 360dp, 400dp widths verified with zero RenderFlex overflow.

## Current files
- `lib/core/theme/*`
- `lib/shared/models/*`, `lib/shared/providers/*`, `lib/shared/widgets/*`
- `lib/features/auth/*`
- `lib/features/ambulance/*`
- `lib/features/hospital/*`
- `lib/features/matching/*`
- `lib/features/reservation/*` (domain models, providers, widgets, screens)
- `lib/features/navigation/*`
- `lib/features/design_system/*`
- `lib/app/router.dart`, `lib/app/app.dart`, `lib/main.dart`
- `test/*`
- `PHASE_1_REPORT.md` through `PHASE_7_REPORT.md`

## Next recommended task
Await manual user review and approval of Phase 7. Upon approval, create `chore(phase-7): approve hold confirmation frontend` and proceed to Phase 8 only when instructed.
