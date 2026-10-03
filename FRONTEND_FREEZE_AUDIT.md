# BedLink — Frontend Freeze Audit & Backend Handoff Specification (Phases 1–10)

**Project:** BedLink — Real-Time Emergency Bed Allocation Platform  
**Target:** Final Frontend Freeze Document prior to Phase 11 Backend Integration  
**Date:** October 2, 2026  
**Status:** **FROZEN & SIGNED OFF**  
**Static Analysis:** 0 issues / 0 warnings (`flutter analyze`)  
**Test Suite:** 172/172 tests passing (100% green across 26 test suites)  
**Web Target:** Successfully built (`flutter build web`, exit code 0)  

---

## 1. Executive Summary & Freeze Purpose

BedLink has successfully completed all 10 frontend-only phases (Phases 1 through 10, comprising 80 discrete sub-phases). The entire client-side application architecture, user experience, tactical clinical workflows, resilient state machines, responsive viewport support down to 320dp, WCAG AA accessibility standards, and end-to-end mock cross-role orchestration are finalized and frozen.

### Immutable Frontend Contract
This document establishes the **immutable handoff boundary** between the Flutter presentation layer and the forthcoming backend infrastructure (Phases 11–15). As agreed under architectural guidelines:
1. **Zero UI Rewrite:** Presentation widgets, screens, and component trees built in Phases 1–10 MUST NOT be rewritten or structurally altered when introducing real backend data.
2. **Provider Contract Stability:** Domain models (`PatientIntakeData`, `BedRequirementState`, `HospitalCandidate`, `HospitalOperationalState`, `NavigationProgressState`, `SessionState`, `ConnectivityStatus`) and Riverpod provider signatures serve as the exact interface contracts.
3. **Repository Pattern Swapping:** In Phase 11+, real Supabase clients, PostgREST queries, PostgreSQL triggers/RPCs, and Realtime channels will replace the mock notifiers and seed data strictly behind domain repository interfaces without leaking backend details into widgets.

---

## 2. Complete Inventory of Screens, Routes, Providers & Shared Widgets

### 2.1 Route & Screen Directory

| Route | Screen / View Component | Role Access | Primary Purpose |
| :--- | :--- | :--- | :--- |
| `/login` | `LoginScreen` | Public / Unauth | Role-based authentication switcher with demo quick-logins |
| `/access-denied` | `AccessDeniedScreen` | All | Security boundary rendering role-mismatch feedback |
| `/design-system` | `DesignSystemScreen` | All | Clinical design tokens, components, and responsive typography showcase |
| `/ambulance` | `AmbulanceDashboardScreen` | `ambulance_crew` | Crew mission cockpit with quick-start intake and telemetry overview |
| `/ambulance/intake` | `PatientIntakeScreen` | `ambulance_crew` | Emergency patient triage intake, vitals, mobility, and priority level |
| `/ambulance/requirements` | `BedNeedAssessmentScreen` | `ambulance_crew` | Dynamic bed requirement matrix, clinical presets, oxygen/isolation needs |
| `/ambulance/hospitals` | `HospitalDiscoveryScreen` | `ambulance_crew` | Real-time ranked hospital match cards, filter chips, radius expansion |
| `/ambulance/hold` | `HoldConfirmationScreen` | `ambulance_crew` | 2-minute countdown bed reservation, server-hold simulation, fallback protocol |
| `/ambulance/navigation` | `NavigationScreen` | `ambulance_crew` | Tactical vector polyline canvas, turn-by-turn routing, bay arrival confirmation |
| `/hospital` | `HospitalDashboardScreen` | `hospital_staff` | Live ER triage snapshot, bed capacity counters, pending inbound requests |
| `/hospital/resources` | `ResourceInventoryScreen` | `hospital_staff` | Real-time inventory editor for ICU, Ventilator, Oxygen, and General beds |
| `/hospital/requests` | `IncomingRequestsScreen` | `hospital_staff` | Live queue of incoming ambulance hold requests with Accept / Divert actions |
| `/hospital/holds` | `ActiveHoldsScreen` | `hospital_staff` | Active reservation monitoring with countdowns, patient ETA, and arrival marking |
| `/*` (Unknown) | `NotFoundScreen` | All | 404 Route recovery screen with redirect CTAs back to role dashboards |

---

### 2.2 Riverpod State Provider Inventory

| Provider Name | File Location | State Class / Type | Responsibilities |
| :--- | :--- | :--- | :--- |
| `sessionProvider` | `lib/shared/providers/session_provider.dart` | `SessionState` | Authentication state, active user profile, role switching (`ambulance_crew`, `hospital_staff`) |
| `connectivityProvider` | `lib/shared/providers/connectivity_provider.dart` | `ConnectivityStatus` | Global network state (`online`, `offline`, `reconnecting`), banner control, simulation cycling |
| `patientIntakeProvider` | `lib/features/ambulance/presentation/providers/intake_provider.dart` | `PatientIntakeData` | Full patient demographic, chief complaint, triage priority (P1–P4), and vitals |
| `bedRequirementProvider` | `lib/features/ambulance/presentation/providers/requirement_provider.dart` | `BedRequirementState` | Required clinical resources, equipment flags, acuity calculations, clinical presets |
| `hospitalMatchingProvider` | `lib/features/matching/presentation/providers/matching_provider.dart` | `HospitalMatchingState` | Scored and ranked hospital candidates, radius search expansion, filtering |
| `selectedHospitalProvider` | `lib/features/matching/presentation/providers/selected_hospital_provider.dart` | `HospitalCandidate?` | Active target hospital selected for reservation and navigation transit |
| `holdTimerProvider` | `lib/features/reservation/presentation/providers/hold_timer_provider.dart` | `HoldTimerState` | 120-second reservation countdown, ticking engine, fallback auto-trigger |
| `hospitalStateProvider` | `lib/features/hospital/presentation/providers/hospital_state_provider.dart` | `HospitalOperationalState` | Hospital ER inventory, capacity adjustments, incoming requests queue, active holds list |
| `navigationStateProvider` | `lib/features/navigation/presentation/providers/navigation_state_provider.dart` | `NavigationProgressState` | En route transit telemetry, step progress, speed/ETA calculations, arrival trigger |
| `mockEmergencyCoordinatorProvider` | `lib/shared/providers/mock_emergency_coordinator.dart` | `MockEmergencyCoordinator` | Cross-role mock orchestration bridging ambulance hold actions with hospital triage desk |

---

### 2.3 Shared UI Component Library

| Category | Component Classes | Design Token Adherence |
| :--- | :--- | :--- |
| **Chrome & Shell** | `AppScaffold`, `BedLinkAppBar`, `MedNetLiveBadge`, `ConnectivityBanner` | Elevation 0, 16dp horizontal padding, automatic offline banner injection |
| **Feedback & Status** | `BedLinkBadge`, `FreshnessBadge`, `HospitalLoadBadge`, `EmergencyUrgencyBadge`, `AvailabilityBadge`, `ConnectivityBadge` | Strict color token mapping: Critical Red, Warning Amber, Live Teal, Neutral Slate |
| **Interactive Controls** | `BedLinkButton`, `BedLinkIconButton`, `BedLinkSegmentedSelector`, `BedLinkCounterControl`, `BedLinkOptionCard`, `BedLinkRequirementChip`, `QuickAddChip` | $\ge 48\times 48$dp touch targets, bold clinical typography, explicit hit-testing |
| **Input Fields** | `BedLinkTextField`, `BedLinkSearchField`, `BedLinkValidationMessage` | 44–56dp height, high-contrast borders, clear buttons, inline validation |
| **Cards & Containers** | `BedLinkCard`, `BedLinkMetricCard`, `BedLinkSkeletonCard` | 8dp border radii, 1px crisp borders, clinical background elevation |
| **Resilience Displays** | `BedLinkLoadingIndicator`, `BedLinkEmptyState`, `BedLinkErrorState` | Semantic icons, spinner with status text, retry and fallback navigation buttons |
| **Dev & Demonstration** | `DevFixtureCenter` | Modal bottom sheet with quick connectivity switches, role actions, route jumpers, system reset |

---

## 3. Comprehensive Mock vs. Real Handoff Matrix (Phases 11–15)

This matrix defines the exact mapping from Phase 1–10 mock code to Phase 11+ Supabase and external service integration.

| Current Mock Provider / File | Current Mock Implementation | Phase 11+ Backend Replacement | Target Table / RPC / Channel | Interface Stability Guarantee |
| :--- | :--- | :--- | :--- | :--- |
| `SessionNotifier`<br>`lib/shared/providers/session_provider.dart` | In-memory session state with mock ambulance/hospital credentials | Supabase Auth (`supabase.auth.signInWithPassword`, session persistence) | `auth.users`, `public.profiles` (`id`, `role`, `hospital_id`, `ambulance_id`) | `SessionState` remains identical; UI consumes `sessionProvider.isAuthenticated` and `userRole`. |
| `PatientIntakeNotifier`<br>`lib/features/ambulance/presentation/providers/intake_provider.dart` | In-memory `PatientIntakeData` with local preset helpers | Supabase PostgREST insert into `incidents` / `patients` table | `public.incidents` (`id`, `triage_level`, `chief_complaint`, `vitals`, `ambulance_id`) | UI calls notifier methods; notifier delegates to `IncidentRepository.createIncident()`. |
| `BedRequirementNotifier`<br>`lib/features/ambulance/presentation/providers/requirement_provider.dart` | Static `ClinicalResourceCatalogue` with local preset matching | Supabase Edge Function: Match engine query payload | `POST /functions/v1/match-hospitals` | UI continues to watch `bedRequirementProvider`; output feeds match request body. |
| `MatchingNotifier`<br>`lib/features/matching/presentation/providers/matching_provider.dart` | Static `MockHospitalData` list sorted by mock scoring algorithm | Supabase Edge Function + PostGIS proximity + ORS Distance Matrix | `rpc/find_matching_hospitals` or `POST /functions/v1/match-hospitals` | `HospitalCandidate` model fields (`id`, `name`, `score`, `etaMinutes`, `availableBeds`) remain unchanged. |
| `HoldTimerNotifier`<br>`lib/features/reservation/presentation/providers/hold_timer_provider.dart` | Local 120-second periodic timer ticker with mock confirm/reject | Server-Authoritative Reservation: Supabase PostgreSQL RPC with advisory locks | `rpc/create_bed_hold(hospital_id, requirement_id)` returning `hold_expires_at` | Timer syncs against `hold_expires_at` timestamp from PostgreSQL rather than arbitrary client countdown. |
| `HospitalStateNotifier`<br>`lib/features/hospital/presentation/providers/hospital_state_provider.dart` | Local in-memory hospital state with synthetic request queue | Supabase Realtime Postgres Changes listener on `holds` & `capacity` | `public.hospital_inventory`, `public.holds` subscribed via `supabase.channel('hospital_feed')` | Notifier updates its internal `HospitalOperationalState` when Realtime events arrive; UI watches same state. |
| `NavigationStateNotifier`<br>`lib/features/navigation/presentation/providers/navigation_state_provider.dart` | CustomPainter mock canvas with static Mumbai waypoint coordinates | OpenRouteService Directions API + Geolocator GPS stream | `GET https://api.openrouteservice.org/v2/directions/driving-car` | `NavigationProgressState` remains the state emitted to UI; real GPS updates replace manual step simulator. |
| `MockEmergencyCoordinator`<br>`lib/shared/providers/mock_emergency_coordinator.dart` | Direct in-memory bridge calling Riverpod notifiers across roles | Supabase Realtime Broadcast & Postgres Triggers | Channel `emergency_dispatch_{hold_id}` | Coordinator replaced by Supabase Realtime channel event handlers. Dev Fixture Center remains for testing. |

---

## 4. Offline & Edge Resilience Matrix

| Screen / Feature | Offline State Behavior | Reconnecting State Behavior | Server Error / Timeout Behavior | Recovery Path |
| :--- | :--- | :--- | :--- | :--- |
| **Global App Shell** | Amber `ConnectivityBanner` appears at top; app bar badge shifts to `OFFLINE` (amber dot). | Blue `ConnectivityBanner` appears; app bar badge shifts to `RECONNECTING` (pulsing blue). | Inline `BedLinkErrorState` renders if critical request fails. | Tapping "RECONNECT" cycles state; state is automatically preserved across drops. |
| **Patient Intake** | Full intake form remains functional; inputs cached locally in memory. | Non-blocking banner; draft intake intact. | If save fails, red error card displayed with "RETRY SAVE". | Form data is NEVER wiped on network loss. Crew can proceed with triage. |
| **Hospital Matches** | Cached match candidates remain visible; warning badge indicates stale telemetry. | Automatic re-fetch triggered upon network restoration. | Shows `BedLinkErrorState` with "RETRY MATCH SEARCH" button. | Radius expansion button remains enabled; crew can re-query nearest hospitals. |
| **Hold Confirmation** | Hold timer continues countdown based on anchor timestamp; banner warns crew of network drop. | Reconnecting indicator displays; checks server hold confirmation status. | If reservation rejected or server drops hold, automatic Fallback Protocol engages. | "VIEW NEXT BEST HOSPITAL" button allows instantaneous redirect to candidate 2. |
| **Transit Navigation** | Turn-by-turn maneuvers and cached route polyline remain visible on screen. | Telemetry syncs in background; navigation step tracking continues. | Map fallback card informs crew to rely on local turn instructions. | "CONFIRM EMERGENCY ARRIVAL" button remains active regardless of connection state. |
| **Hospital Triage Desk** | Staff sees last known capacity snapshot; warning banner alerts to offline status. | Re-synchronizing indicator; queue updates automatically. | Capacity update failure displays snackbar with rollback. | Staff can continue to view incoming holds; manual refresh CTA available. |

---

## 5. Responsive & Accessibility Matrix

All screens have been verified across the four mandatory mobile device viewports:

| Viewport Width | Target Devices | RenderFlex Overflows | Touch Targets ($\ge 48$dp) | Contrast Ratio | Screen Reader Semantics |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **320dp** | Ultra-budget Android, JioPhone Next | **0 Overflows** | 100% compliant | $\ge 4.5:1$ (AA) | All icon buttons have semantic tooltips & labels |
| **360dp** | Standard budget Android (Redmi 9A, Samsung A03) | **0 Overflows** | 100% compliant | $\ge 4.5:1$ (AA) | Priority badges announce acuity tier |
| **375dp** | Standard iPhone (SE, 13 mini) | **0 Overflows** | 100% compliant | $\ge 4.5:1$ (AA) | Timers include readable minute/second formats |
| **390dp** | Modern standard smartphone (iPhone 14/15, Pixel 7) | **0 Overflows** | 100% compliant | $\ge 4.5:1$ (AA) | Status indicators announce online/offline state |

---

## 6. Cross-Role Event Synchronization Spec (Phases 11–13)

The lifecycle of an emergency hospital bed allocation follows this state transition diagram:

```
[Ambulance Crew]                        [Supabase Backend]                     [Hospital Staff]
       |                                         |                                     |
       |--- 1. Request Bed Hold ---------------->|                                     |
       |    (selects candidate & requirements)   |--- 2. Insert into `holds` --------->|
       |                                         |    (Status: pending_confirmation)   |--- 3. Incoming Alert Rings
       |                                         |<-- 4. Accept Hold ------------------|
       |                                         |    (rpc/confirm_bed_hold)           |    (Bed held: avail -> held)
       |<-- 5. Broadcast: Hold Confirmed --------|                                     |
       |    (Status: confirmed_locked)           |                                     |
       |                                         |                                     |
       |--- 6. Begin Navigation Transit -------->|                                     |
       |    (ETA & telemetry streaming)          |--- 7. Update En Route ETA --------->|
       |                                         |                                     |
       |--- 8. Confirm Bay Arrival ------------->|                                     |
       |    (arrived_at_hospital)                |--- 9. Mark Arrived ---------------->|
       |                                         |    (Bed: held -> occupied)          |--- 10. Direct to Trauma Bay
```

### Fallback Protocol Event Sequence:
1. **Hold Request Timeout (120s):** If hospital does not confirm within 2 minutes, backend Edge Function or Postgres cron expires the hold.
2. **Hospital Rejection:** If hospital staff taps "REJECT / DIVERT", status transitions to `diverted`.
3. **Ambulance Fallback Engagement:** Ambulance UI receives `diverted` or `expired` event, automatically displays candidate #2 with reason banner, and prompts crew to request hold at the fallback hospital.

---

## 7. Frontend Freeze Sign-Off

### Sign-Off Checklist
- [x] All 14 routes configured with GoRouter and role-based guards.
- [x] All 10 phases (Phases 1–10) implemented strictly within frontend boundaries.
- [x] Zero real backend dependencies imported (`supabase_flutter`, `openrouteservice`, `maplibre_gl` remain deferred to Phase 11+).
- [x] Zero `flutter analyze` errors, warnings, or lints across the entire codebase.
- [x] 100% pass rate across all 172 automated unit, widget, and integration tests.
- [x] 320dp responsive validation complete with zero RenderFlex overflow.
- [x] Cross-role mock coordination verified with happy path, rejection fallback, and timeout fallback scenarios.
- [x] Dev Fixture Center integrated for rapid demonstration and manual QA.

**Sign-off:** The BedLink frontend is officially **FROZEN**. Development may proceed to Phase 11 (Supabase Setup & Auth Integration) upon approval.
