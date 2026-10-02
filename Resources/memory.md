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
  - Phase 12: Bed Availability & Live Inventory Synchronization — **NEXT**
- **External API integration:** Phases 13–15 (Geolocator, Discovery API, MapLibre/MapTiler, ORS Matrix/Directions, E2E Recovery)

## Current status
- **Current Phase:** Phase 11 — Supabase Connection + Existing Hospital Directory Integration
- **Current Sub-Phase:** Phase 11 Verification Complete & Frozen; Ready for User Approval before Phase 12.
- **Completed work:**
  - Phases 1 through 10 completed, verified, and frozen in Git history.
  - Pre-Phase-11 read-only audit completed (`SUPABASE_EXISTING_STATE_AUDIT.md`, `SUPABASE_GAP_SUMMARY.md`).
  - Connected frozen Flutter frontend to Supabase (`segutgypwupqjktrxztz`, `ap-south-1`) via `supabase_flutter: ^2.18.0`.
  - Zero database mutations performed; preserved all 245 hospitals, 1,191 beds, and 1 ambulance request intact.
  - Implemented `SupabaseConfig` with compile-time `--dart-define` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `APP_MODE`) and key-redacting `toString()`.
  - Implemented `SupabaseHospitalDto` mapping 14 database columns, nullable coordinates, care capability normalizer, and simulated availability.
  - Implemented `HospitalRepository` interface, `MockHospitalRepository`, and `SupabaseHospitalRepository`.
  - Implemented `hospitalRepositoryProvider` with dynamic mode switching and test overrides.
  - Connected `MatchingNotifier` and `HospitalDiscoveryScreen` with non-breaking RLS default-deny warning and data source badge.
  - Configured safe client initialization in `AppBootstrap` with zero-crash guarantee.
  - Authored `HUMAN_INTERVENTION_PHASE_11.md` and `PHASE_11_REPORT.md` (all 22 required sections).

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 197/197 tests passed across all test suites (100% pass rate, zero regressions).
- `flutter build web`: Built cleanly to `build/web` (exit code 0).
- Security audit: 0 raw secrets, service roles, or JWT tokens in codebase.
- Database integrity: 100% preserved; zero DDL/DML statements executed.

## Current files
- `PHASE_11_REPORT.md`
- `HUMAN_INTERVENTION_PHASE_11.md`
- `SUPABASE_EXISTING_STATE_AUDIT.md`
- `SUPABASE_GAP_SUMMARY.md`
- `FRONTEND_FREEZE_AUDIT.md`
- `PHASE_1_REPORT.md` through `PHASE_10_REPORT.md`
- `lib/core/config/supabase_config.dart`
- `lib/core/data/supabase_client_provider.dart`
- `lib/features/hospital/domain/repositories/hospital_repository.dart`
- `lib/features/hospital/data/repositories/mock_hospital_repository.dart`
- `lib/features/hospital/data/repositories/supabase_hospital_repository.dart`
- `lib/features/hospital/data/models/supabase_hospital_dto.dart`
- `lib/features/hospital/presentation/providers/hospital_repository_provider.dart`
- `lib/**/*`
- `test/**/*`

## Next recommended task
Await user review & approval of Phase 11. Project administrator executes the read-only SELECT policy on `public.hospitals` in Supabase SQL Editor. Then proceed to Phase 12 (Bed Availability & Live Inventory Synchronization).
