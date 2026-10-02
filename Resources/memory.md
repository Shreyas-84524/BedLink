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
- **Current Phase:** Phase 4 — Ambulance Patient Intake
- **Current Sub-Phase:** 4.8 completed (Complete Intake Screen Integration & Responsive Widget Tests)
- **Completed work:**
  - Phase 1, 2 & 3 completed and approved.
  - Sub-phase 4.1: Active Intake Header (`lib/features/ambulance/presentation/widgets/intake_header.dart`).
  - Sub-phase 4.2: Patient Identity Section (`lib/features/ambulance/presentation/widgets/patient_identity_section.dart`).
  - Sub-phase 4.3: Biological Sex Selection (`lib/features/ambulance/presentation/widgets/biological_sex_selector.dart`, `lib/features/ambulance/domain/models/biological_sex.dart`).
  - Sub-phase 4.4: Patient Age Selector & Demographic Cohorts (`lib/features/ambulance/presentation/widgets/patient_age_selector.dart`).
  - Sub-phase 4.5: Clinical Urgency / ESI Acuity Selector (`lib/features/ambulance/presentation/widgets/clinical_urgency_selector.dart`, `lib/features/ambulance/domain/models/clinical_urgency.dart`).
  - Sub-phase 4.6: Chief Complaint & Diagnostic Notes (`lib/features/ambulance/presentation/widgets/chief_complaint_section.dart`).
  - Sub-phase 4.7: Riverpod Intake State Management & Form Validation (`lib/features/ambulance/domain/models/patient_intake.dart`, `lib/features/ambulance/presentation/providers/intake_provider.dart`, `test/features/ambulance/intake_provider_test.dart`).
  - Sub-phase 4.8: Complete Intake Screen Integration & Responsive Widget Tests (`lib/features/ambulance/presentation/screens/patient_intake_screen.dart`, `test/features/ambulance/patient_intake_screen_test.dart`).
  - `PHASE_4_REPORT.md` and `PHASE_4_RECOVERY_AUDIT.md` generated.

## Verification results
- `flutter analyze`: 0 issues found (strict mode enabled).
- `flutter test`: 69/69 tests passed across 13 test suites (100% pass rate).
- `flutter build web`: Built cleanly to `build/web`.
- Compact viewport validation: 320dp, 360dp, and 390dp width verified without RenderFlex overflow.

## Current files
- `lib/core/theme/*`
- `lib/shared/models/*`, `lib/shared/providers/*`, `lib/shared/widgets/*`
- `lib/features/auth/*`
- `lib/features/ambulance/*`
- `lib/features/hospital/*`
- `lib/features/matching/*`, `lib/features/reservation/*`, `lib/features/navigation/*`
- `lib/features/design_system/*`
- `lib/app/router.dart`, `lib/app/app.dart`, `lib/main.dart`
- `test/*`
- `PHASE_1_REPORT.md`, `PHASE_2_REPORT.md`, `PHASE_3_REPORT.md`, `PHASE_4_REPORT.md`, `PHASE_4_RECOVERY_AUDIT.md`

## Next recommended task
Await manual testing and explicit user approval (`APPROVED`) to create `chore(phase-4): approve ambulance patient intake`, then proceed to Phase 5 (Bed Need Assessment).
