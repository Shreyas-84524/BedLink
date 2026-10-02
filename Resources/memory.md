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
- **Current Phase:** Phase 6 — Hospital Discovery & Match Grid Frontend (Approved)
- **Current Sub-Phase:** Phase 6 complete & approved; ready for Phase 7 (Two-Minute Hold & Confirmation Frontend).
- **Completed work:**
  - Phases 1, 2, 3, 4, 5 & 6 completed, verified, and approved.
  - Sub-phase 6.1: Matching/Searching State Telemetry (`lib/features/matching/presentation/widgets/matching_search_indicator.dart` with animated radar sweep, 5km -> 10km -> 15km progression).
  - Sub-phase 6.2: Patient Requirement Summary Bar (`lib/features/matching/presentation/widgets/patient_requirement_summary_bar.dart` consuming `patientIntakeProvider` and `bedRequirementProvider`).
  - Sub-phase 6.3: Primary Hospital Result Card (`lib/features/matching/presentation/widgets/primary_hospital_card.dart` for #1 KEM Hospital with road ETA, distance, capacity, route preview, and hold CTA).
  - Sub-phase 6.4: Ranking & Recommendation States (`RecommendationTier`: `topMatch`, `strongMatch`, `compatible`, `divertRisk`, `incompatible`).
  - Sub-phase 6.5: Availability / Freshness / Load Indicators (`FreshnessBadge`, `HospitalLoadBadge`, `RecommendationTierBadge` using `semantic_tokens.dart`).
  - Sub-phase 6.6: Mock Route Preview (`lib/features/matching/presentation/widgets/mock_route_preview.dart` with pure Flutter vector route canvas).
  - Sub-phase 6.7: Complete Ranked Hospital List (`lib/features/matching/presentation/widgets/hospital_match_tile.dart` with 5 deterministic Mumbai hospitals).
  - Sub-phase 6.8: Verification, Edge Cases & Riverpod Integration (`HospitalDiscoveryScreen`, `selectedHospitalProvider`, fixture switcher, 320dp responsive audit).
  - `PHASE_6_REPORT.md` generated at root.

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 103/103 tests passed across 17 suites (100% pass rate).
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
- `PHASE_1_REPORT.md`, `PHASE_2_REPORT.md`, `PHASE_3_REPORT.md`, `PHASE_4_REPORT.md`, `PHASE_4_RECOVERY_AUDIT.md`, `PHASE_5_REPORT.md`, `PHASE_6_REPORT.md`

## Next recommended task
Proceed to Phase 7 — Two-Minute Hold & Confirmation Frontend upon user instruction.
