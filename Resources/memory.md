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
  - Phase 13: Real Location + Hospital Discovery Integration — **NEXT**

## Current status
- **Current Phase:** Phase 12 — Bed Availability & Live Inventory Synchronization
- **Current Sub-Phase:** Phase 12 Verification Complete; Ready for User Manual Testing & Approval.
- **Completed work:**
  - Phases 1 through 11 completed, verified, and frozen in Git history.
  - Adapted existing `public.beds` table (1,191 slots) into frozen Phase 8 Hospital Resources UI without schema changes.
  - Implemented `SupabaseBedDto` (`lib/features/hospital/data/models/supabase_bed_dto.dart`) mapping `public.beds` schema.
  - Implemented `BedRepository` interface and `SupabaseBedRepository` (`lib/features/hospital/data/repositories/supabase_bed_repository.dart`).
  - Implemented `BedInventoryAdapter` (`lib/features/hospital/data/adapters/bed_inventory_adapter.dart`) aggregating slots into `HospitalResourceItem` pools and enforcing `available + held + occupied == total`.
  - Implemented `bedRepositoryProvider` with dynamic repository switching and test overrides.
  - Integrated `loadLiveBeds` and `refreshBedInventory` into `HospitalStateNotifier` without UI regression.
  - Created `BedInventoryMutationRepository` compatibility layer with safe local write fallback.
  - Authored `PHASE_12_REPORT.md` (all 28 sections) and `HUMAN_INTERVENTION_PHASE_12.md`.
  - Zero database mutations performed; preserved all 245 hospitals, 1,191 beds, and 1 ambulance request intact.

## Architecture & Integration Details
- **Bed Repository Location:** `lib/features/hospital/data/repositories/supabase_bed_repository.dart`
- **Aggregation Adapter Location:** `lib/features/hospital/data/adapters/bed_inventory_adapter.dart`
- **Real Supported Resource Types:** `ICU` (`icu_bed`), `General` (`general_bed`), `Emergency` (`er_bed`)
- **Unsupported Resources (Mock Only):** `ventilator`, `oxygen_bed`, `pediatric_icu`, and static capabilities
- **Real Read Status:** REAL (PostgREST queries operational; returns `[]` under default-deny RLS until policy applied)
- **Real Write Status:** DEFERRED / SAFE LOCAL FALLBACK (mutations operate locally to prevent race conditions)
- **RLS Status:** `rowsecurity = true` with 0 policies (default-deny); policy SQL documented in `HUMAN_INTERVENTION_PHASE_12.md`
- **Realtime Status:** NOT ENABLED (Supabase publication not configured; operates via pull/refresh)

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 228/228 tests passed across all test suites (100% pass rate, zero regressions).
- `flutter build web`: Built cleanly with `--dart-define-from-file=config/supabase.json` (exit code 0).
- Security audit: 0 raw secrets, service roles, or JWT tokens in codebase.
- Database integrity: 100% preserved; zero DDL/DML statements executed.

## Next recommended task
User manual testing and verification of Phase 12. Following explicit user approval, create approval commit `chore(phase-12): approve bed inventory integration` and proceed to Phase 13 (Real Location + Hospital Discovery Integration).
