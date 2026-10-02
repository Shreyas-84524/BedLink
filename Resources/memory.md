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
- **Current Sub-Phase:** Phase 13 Verification Complete; Ready for User Manual Testing & Approval.
- **Completed work:**
  - Integrated `geolocator: ^13.0.2` and Android foreground location permissions (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`).
  - Implemented `LocationRepository`, `GeolocatorLocationRepository`, `MockLocationRepository`, and `ambulanceLocationProvider` (Central Mumbai `18.9980°N, 72.8300°E` fallback).
  - Implemented `GeoUtils.haversineDistanceKm` calculating spherical great-circle distances and human-friendly distance formatting.
  - Added `latitude`, `longitude`, `hasCoordinates` to `HospitalMatch` and populated coordinates across mock and Supabase DTO models.
  - Safely filtered out 21 null-coordinate hospitals from distance discovery without database modifications, preserving all 245 hospital records in `public.hospitals`.
  - Implemented deterministic radius progression (`5 km -> 10 km -> 15 km max`) in `SupabaseHospitalDiscoveryRepository`.
  - Supported real backend requirements (`icu_bed`, `general_bed`, `emergency_bed`, `trauma_care`) while flagging unsupported capabilities (`ventilator`, `oxygen_bed`, `pediatric_icu`, `cardiac_care`, `burns_care`) as unverified.
  - Wired `hospitalDiscoveryRepositoryProvider` to `MatchingNotifier.runSearchProgression` while preserving Phase 6 frozen UI geometry and animations.
  - Authored `PHASE_13_REPORT.md` (all 26 sections) and `HUMAN_INTERVENTION_PHASE_13.md`.
  - Authored 33 new automated tests, bringing the test suite to **261 / 261 passing tests (100% pass rate)**.
  - Zero database mutations; preserved all backend tables (`public.hospitals`, `public.beds`, `public.ambulance_requests`).

## Architecture & Integration Details
- **Location Provider Location:** `lib/core/services/location/location_provider.dart`
- **Geo Math Utility:** `lib/core/utils/geo_utils.dart`
- **Discovery Repository Location:** `lib/features/matching/data/repositories/supabase_hospital_discovery_repository.dart`
- **Discovery Provider:** `lib/features/matching/presentation/providers/hospital_discovery_provider.dart`
- **Real Supported Bed Types:** `icu_bed`, `general_bed`, `emergency_bed`
- **Supported Capabilities:** `trauma_care`, `emergency_care`, `icu_care`
- **Radius Progression:** 5 km -> 10 km -> 15 km ceiling
- **Distance Metric:** Haversine great-circle distance (Road distance/ETA strictly deferred to Phase 14)

## Verification results
- `flutter analyze`: 0 issues found (strict analysis enabled).
- `flutter test`: 261/261 tests passed across all test suites (100% pass rate, zero regressions from 228 baseline).
- `flutter build web`: Built cleanly with `--dart-define-from-file=config/supabase.json` (exit code 0).
- Security audit: 0 raw secrets or private keys in codebase; `config/supabase.json` remains Git-ignored.
- Database integrity: 100% preserved; zero DDL/DML statements executed.

## Next recommended task
User manual testing and verification of Phase 13. Following explicit user approval, create approval commit `chore(phase-13): approve location and discovery integration` and proceed to Phase 14 (Real Routing + Map Integration).
