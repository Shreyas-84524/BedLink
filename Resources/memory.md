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
- **Current Phase:** Phase 5 — Bed Need Assessment
- **Current Sub-Phase:** 5.8 completed (Verification & Complete Integration)
- **Completed work:**
  - Phases 1, 2, 3 & 4 completed and committed.
  - Sub-phase 5.1: Patient Summary Banner (`lib/features/ambulance/presentation/widgets/intake_patient_summary_card.dart` reading `patientIntakeProvider`).
  - Sub-phase 5.2: Clinical Resource Search (`lib/features/ambulance/presentation/widgets/clinical_resource_search_section.dart` with instant clear & autocomplete).
  - Sub-phase 5.3: Auto-Suggest Clinical Resources (`lib/features/ambulance/presentation/widgets/clinical_resource_suggestions.dart` dynamically suggesting resources based on patient chief complaint).
  - Sub-phase 5.4: Active Requirement Chips (`lib/features/ambulance/presentation/widgets/active_requirements_section.dart` with BedLinkRequirementChip, quantity adjusters, and clear all).
  - Sub-phase 5.5: Frequent Requirement Shortcuts / Emergency Preset Bundles (`lib/features/ambulance/presentation/widgets/emergency_presets_section.dart` with Cardiac Emergency, Polytrauma ICU, Respiratory Failure, Pediatric ICU).
  - Sub-phase 5.6: BedLink Clinical Resource Catalogue (`lib/features/ambulance/domain/models/clinical_resource.dart`, `lib/features/ambulance/domain/models/clinical_resource_catalogue.dart`).
  - Sub-phase 5.7: Riverpod Requirement State & Hard-Filter Validation (`lib/features/ambulance/domain/models/bed_requirement_state.dart`, `lib/features/ambulance/presentation/providers/requirement_provider.dart`, enforcing rule: at least one countable bed/equipment required).
  - Sub-phase 5.8: Screen Integration, Responsive Testing & Quality Gates (`lib/features/ambulance/presentation/screens/bed_requirements_screen.dart`, `test/features/ambulance/requirement_provider_test.dart`, `test/features/ambulance/bed_requirements_screen_test.dart`).
  - `PHASE_5_REPORT.md` generated at root.

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 87/87 tests passed across 15 suites (100% pass rate).
- `flutter build web`: Built cleanly to `build/web`.
- Compact viewport validation: 320dp, 360dp, 400dp widths verified with zero RenderFlex overflow.

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
- `PHASE_1_REPORT.md`, `PHASE_2_REPORT.md`, `PHASE_3_REPORT.md`, `PHASE_4_REPORT.md`, `PHASE_4_RECOVERY_AUDIT.md`, `PHASE_5_REPORT.md`

## Next recommended task
Await manual testing and explicit user approval (`APPROVED`) to create `chore(phase-5): approve bed need assessment`, then proceed to Phase 6 (Hospital Discovery & Match Grid Frontend).
