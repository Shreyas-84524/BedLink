# BedLink Implementation Roadmap (15-Phase Architecture)

> **Role & Responsibility:** Frontend-first architecture and implementation for the complete BedLink emergency hospital coordination platform (Ambulance/Dispatch and Hospital Staff interfaces), transitioning from a backend-independent mock foundation (Phases 1–10) to real Supabase, Realtime, and external API integration (Phases 11–15).

---

## Global Git & Delivery Rules for All 15 Phases

Every AI agent and human engineer working on BedLink must strictly adhere to the two-commit lifecycle:

```text
               ┌────────────────────────────────────────────────────────┐
               │  Sub-Phases X.1 → X.8 (Implementation & Local Testing) │
               │  NO COMMITS ALLOWED DURING SUB-PHASES                  │
               └───────────────────────────┬────────────────────────────┘
                                           │
                                           ▼
               ┌────────────────────────────────────────────────────────┐
               │  Run Full Automated Checks (analyze, tests, builds)    │
               └───────────────────────────┬────────────────────────────┘
                                           │
                                           ▼
               ┌────────────────────────────────────────────────────────┐
               │  Commit #1: feat(phase-x): complete <phase-name>       │
               └───────────────────────────┬────────────────────────────┘
                                           │
                                           ▼
               ┌────────────────────────────────────────────────────────┐
               │  STOP IMMEDIATELY. Hand over for manual human testing. │
               │  If issues found: fix -> rerun validation -> NO COMMIT │
               └───────────────────────────┬────────────────────────────┘
                                           │
                         [Human explicitly sends "APPROVED"]
                                           │
                                           ▼
               ┌────────────────────────────────────────────────────────┐
               │  Commit #2: chore(phase-x): approve <phase-name>       │
               │  Phase is officially complete.                         │
               └────────────────────────────────────────────────────────┘
```

1. **Zero Intermediate Commits:** No commits may be created during intermediate sub-phases (`X.1` to `X.8`).
2. **Commit #1 (Implementation):** Created only after all 8 sub-phases are finished, automated validation passes, report generated, and `memory.md` updated.
   - Format: `feat(phase-x): complete <phase-name>`
   - Example: `feat(phase-1): bootstrap flutter project and core architecture`
3. **Mandatory Stop:** After Commit #1, the agent **MUST STOP** immediately. Never proceed to the next phase without explicit approval.
4. **Issue Resolution:** If manual testing uncovers defects, fix the issues and rerun automated checks without creating new commits.
5. **Commit #2 (Manual Approval):** Created only when the user explicitly provides the instruction `APPROVED`.
   - Format: `chore(phase-x): approve <phase-name>`
   - Example: `chore(phase-1): approve flutter foundation`
6. **Maximum 2 Commits Per Phase:** No WIP, fix, sub-phase, test, or cleanup commits inside a phase.
7. **Phase Scope Invariance:** Implement only the exact requested phase and sub-phases. Do not pull future requirements or backend connectivity forward into Phases 1–10.

---

## Roadmap Overview

| Phase Range | Focus Area | Backend/API Dependency |
| :--- | :--- | :--- |
| **Phases 1–10** | Complete Flutter Frontend (Ambulance + Hospital) | **None** (Pure Riverpod, mock repositories, deterministic fixtures) |
| **Phases 11–12** | Core Backend & Realtime Integration | **Supabase** (Auth, PostgreSQL, RLS, Realtime broadcast/changes) |
| **Phases 13–15** | External Service & End-to-End API Integration | **APIs & Edge Functions** (Geolocator, Discovery, ORS Matrix/Directions, MapLibre/MapTiler, E2E Recovery) |

---

# PHASE 1 — Flutter Project Bootstrap & Core Foundation

### Objective
Create the production Flutter application directly in the repository root and establish a clean, scalable feature-first architectural foundation with Riverpod and GoRouter.

### Scope
Flutter project creation, environment validation, foundation dependencies, feature-first directory layout, Riverpod root configuration, and structural placeholder routing. No final feature UI or backend connectivity.

### Eight Sub-Phases
- **1.1 Repository, documentation and development environment audit:** Verify Flutter SDK, Dart SDK, Android tooling, Chrome/Web runtime, git status, and ensure all existing documentation in `Resources/` is preserved.
- **1.2 Create the Flutter project directly in the existing BedLink repository:** Initialize the Flutter application (`bedlink`) directly at root without nested folders, targeting Android and Web.
- **1.3 Verify untouched Flutter baseline:** Execute baseline `flutter pub get`, `flutter analyze`, `flutter test`, and launch smoke test to confirm an uncorrupted Flutter baseline.
- **1.4 Add only foundation dependencies:** Add `flutter_riverpod` and `go_router` to `pubspec.yaml`; verify no premature API or database packages are introduced.
- **1.5 Create feature-first Flutter folder architecture:** Scaffold `lib/app/`, `lib/core/`, `lib/shared/`, and `lib/features/` (`auth`, `ambulance`, `hospital`, `matching`, `reservation`, `navigation`) with clear separation of presentation, domain, and data layers.
- **1.6 Configure Riverpod application foundation:** Wrap app root in `ProviderScope`, establish base provider conventions, AsyncValue state presentation patterns, and clean separation of concerns.
- **1.7 Configure routing and placeholder application structure:** Implement declarative GoRouter routing with guards and placeholder screens for `/`, `/login`, `/ambulance/*`, and `/hospital/*`.
- **1.8 Run complete Phase 1 validation and generate the Phase 1 report:** Run `flutter analyze`, `flutter test`, web/device smoke test, create `PHASE_1_REPORT.md`, and update `memory.md`.

### Expected Files / Modules
- `pubspec.yaml`, `analysis_options.yaml`
- `lib/main.dart`
- `lib/app/app.dart`, `lib/app/bootstrap.dart`, `lib/app/router.dart`
- `lib/core/constants/`, `lib/core/theme/`, `lib/core/errors/`, `lib/core/utils/`
- `lib/shared/widgets/`, `lib/shared/models/`
- `lib/features/{auth,ambulance,hospital,matching,reservation,navigation}/presentation/screens/`
- `test/widget_test.dart`, `test/app/router_test.dart`
- `PHASE_1_REPORT.md`

### Dependencies
- None (First phase).

### Automated Validation
- `flutter pub get` succeeds without version conflicts.
- `flutter analyze` returns 0 issues/warnings.
- `flutter test` executes all foundation and router tests with 100% pass rate.

### Manual Validation
- App launches in Chrome / Android emulator without runtime exceptions.
- Navigating to `/`, `/login`, `/ambulance`, and `/hospital` renders placeholder screens with designated labels.

### Exit Criteria
- Clean Flutter foundation running at repository root with zero analysis errors and functional GoRouter navigation.

### Implementation Commit
`feat(phase-1): bootstrap flutter project and core architecture`

### Approval Commit
`chore(phase-1): approve flutter foundation`

---

# PHASE 2 — BedLink Design System

### Objective
Implement the complete clinical design token system, typography, surfaces, buttons, badges, and form controls adhering to `Resources/design.md`.

### Scope
Design tokens, color schemes (high-contrast clinical slate `#0F172A`, medical teal `#0D9488`, critical red `#DC2626`, alert amber `#F59E0B`), typography (Chivo & JetBrains Mono), elevation, 48dp/56dp touch targets, reusable design system components, and component gallery verification screen.

### Eight Sub-Phases
- **2.1 Color and semantic design tokens:** Implement `AppColors` and Material `ColorScheme` with high-contrast clinical theme tokens, light surface hierarchy (`#F8FAFC`, `#FFFFFF`, `#CBD5E1`), and medical status palettes.
- **2.2 Typography:** Define `AppTypography` incorporating Chivo for UI labels/headers and JetBrains Mono for tabular metrics, countdown timers, and bed numbers.
- **2.3 Buttons:** Build primary action buttons (52/56px height, dark slate), critical action buttons (red), available action buttons (teal), secondary outlined buttons, and icon buttons with >=48dp tap bounds.
- **2.4 Cards and surfaces:** Implement clinical surface containers, high-contrast bordered cards, active/selected card states, and critical divert 3px left-accent borders.
- **2.5 Status chips and indicators:** Build standardized clinical badges for `Available/Open` (teal), `Warning/Surge` (amber), `Critical/Divert` (red), freshness indicators, and tabular countdown chips.
- **2.6 Form controls:** Implement high-visibility 52px input fields, search bars, counter increment/decrement controls (`+`/`-`), accessible checkboxes, and radio selectors.
- **2.7 Shared application header/chrome:** Create top operational app bar, role banner, breadcrumb/step indicators, and offline/sync status badge.
- **2.8 Visual verification:** Construct a design system catalog screen (`/design-system`) demonstrating all components at 320dp width and 200% text scale; verify WCAG contrast compliance.

### Expected Files / Modules
- `lib/core/theme/app_colors.dart`, `lib/core/theme/app_typography.dart`, `lib/core/theme/app_theme.dart`
- `lib/shared/widgets/buttons/bedlink_button.dart`, `lib/shared/widgets/buttons/bedlink_icon_button.dart`
- `lib/shared/widgets/cards/bedlink_card.dart`, `lib/shared/widgets/cards/bedlink_metric_card.dart`
- `lib/shared/widgets/badges/bedlink_badge.dart`, `lib/shared/widgets/badges/freshness_badge.dart`
- `lib/shared/widgets/inputs/bedlink_text_field.dart`, `lib/shared/widgets/inputs/bedlink_counter_control.dart`
- `lib/shared/widgets/app_bar/bedlink_app_bar.dart`
- `lib/features/design_system/presentation/design_system_catalog_screen.dart`
- `test/core/theme_test.dart`, `test/shared/widgets_test.dart`

### Dependencies
- Phase 1 (Flutter Foundation & Architecture).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Widget tests for button tap handling, counter clamping, and badge color/text rendering pass.

### Manual Validation
- Review Design System catalog at 320dp and 412dp screen widths under light theme.
- Confirm button touch targets measure >= 48dp.
- Confirm tabular numbers use JetBrains Mono without horizontal jitter.

### Exit Criteria
- Complete set of reusable clinical design system widgets ready for feature screen integration.

### Implementation Commit
`feat(phase-2): implement bedlink design system and ui tokens`

### Approval Commit
`chore(phase-2): approve bedlink design system`

---

# PHASE 3 — Application Shell, Authentication UI & Role Navigation

### Objective
Implement the authentication interface, mock session management, and role-based app shells for Ambulance Crews and Hospital Staff.

### Scope
Splash screen, role selection, 10-digit ID/password login UI, mock session provider, Ambulance Shell with bottom navigation/workflow bar, Hospital Shell with department navigation, error boundary, and session expiry simulation.

### Eight Sub-Phases
- **3.1 Splash/startup UI:** Implement initial loading screen with BedLink branding, environment check, and mock authentication routing.
- **3.2 Login UI:** Build high-contrast login screen supporting 10-digit numeric display ID and password, role toggle (`Ambulance Crew` vs `Hospital Staff`), and demo credential autofill shortcuts.
- **3.3 Mock authentication state:** Create `AuthNotifier` with deterministic demo users (`crew-101`, `hospital-kew-01`), mock login/logout, role switching, and session state.
- **3.4 Ambulance shell:** Construct ambulance workspace shell with persistent ambulance callsign/ID header, active emergency status badge, and workflow navigation container.
- **3.5 Hospital shell:** Construct hospital staff shell with hospital identity header, department selector, emergency alert banner, and resource navigation.
- **3.6 Role-based navigation:** Wire GoRouter redirect guards based on Riverpod `authStateProvider` to isolate `/ambulance/*` and `/hospital/*` routes.
- **3.7 Session/error frontend states:** Build session expiration dialog, unauthorized role access barrier, and retryable error boundaries.
- **3.8 Verification:** Verify login/logout transitions, role switching, and route protection with automated tests and interactive testing.

### Expected Files / Modules
- `lib/features/auth/domain/models/user_session.dart`, `lib/features/auth/domain/models/user_role.dart`
- `lib/features/auth/presentation/providers/auth_provider.dart`
- `lib/features/auth/presentation/screens/splash_screen.dart`, `lib/features/auth/presentation/screens/login_screen.dart`
- `lib/features/ambulance/presentation/screens/ambulance_shell_screen.dart`
- `lib/features/hospital/presentation/screens/hospital_shell_screen.dart`
- `lib/app/router.dart` (updated with role guards)
- `test/features/auth/auth_flow_test.dart`

### Dependencies
- Phase 2 (Design System).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Provider and widget tests verify login state changes and router redirects for unauthenticated and wrong-role access.

### Manual Validation
- Log in as Ambulance Crew -> redirected to Ambulance Shell; cannot navigate to `/hospital`.
- Log in as Hospital Staff -> redirected to Hospital Shell; cannot navigate to `/ambulance`.
- Logout clears session and routes back to `/login`.

### Exit Criteria
- Functional authentication and role-shell experience operating cleanly with mock state.

### Implementation Commit
`feat(phase-3): build auth ui, mock session, and role shells`

### Approval Commit
`chore(phase-3): approve auth ui and role navigation`

---

# PHASE 4 — Ambulance Patient Intake

### Objective
Recreate the approved Patient Information / Active Intake interface for ambulance crews to rapidly record patient vitals, urgency, and clinical summary.

### Scope
Intake header with GPS lock indicator, patient demographic controls, biological sex selector, age selector, Emergency Severity Index (ESI) / clinical urgency tier, chief complaint selector, notes input, and Riverpod intake form state.

### Eight Sub-Phases
- **4.1 Active intake header:** Build emergency dispatch header displaying ambulance unit ID, timestamp, simulated GPS coordinates, and intake step progress.
- **4.2 Patient identity:** Implement patient name / unknown identity toggle ("Unknown / Unconscious Patient" quick switch) and triage tag ID field.
- **4.3 Biological sex selection:** Build high-visibility segmented buttons for Male, Female, and Unknown/Other with clear touch targets.
- **4.4 Patient age selector:** Implement rapid age category selector (Adult, Pediatric, Infant, Geriatric) with explicit numeric age slider/keypad entry.
- **4.5 ESI / clinical urgency:** Create 3-level clinical urgency selector (`Routine`, `Urgent`, `Critical`) with color-coded severity tags and clinical guidance prompts.
- **4.6 Chief complaint and diagnostic notes:** Build categorized chief complaint chips (Cardiac, Trauma, Respiratory, Stroke, Burns, Pediatric, General) and clinical text field.
- **4.7 Riverpod intake state + validation:** Implement `PatientIntakeNotifier` with validation ensuring mandatory fields are filled before enabling progression to Bed Needs.
- **4.8 Complete intake verification:** Test intake form validation, rapid-fill scenarios, state resets, and UI responsiveness at 320dp width.

### Expected Files / Modules
- `lib/features/ambulance/domain/models/patient_intake.dart`, `lib/features/ambulance/domain/models/clinical_urgency.dart`
- `lib/features/ambulance/presentation/providers/intake_provider.dart`
- `lib/features/ambulance/presentation/screens/patient_intake_screen.dart`
- `lib/features/ambulance/presentation/widgets/intake_header.dart`
- `lib/features/ambulance/presentation/widgets/urgency_selector.dart`
- `lib/features/ambulance/presentation/widgets/chief_complaint_picker.dart`
- `test/features/ambulance/patient_intake_test.dart`

### Dependencies
- Phase 3 (App Shell & Role Navigation).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Widget tests verify form validation (disabling "Next" button when required fields are missing).
- Unit tests verify `PatientIntake` immutability and state updates.

### Manual Validation
- Fill patient intake under 15 seconds using quick presets and verify smooth transition to requirement step.
- Verify 320dp viewport displays all inputs without layout overflow.

### Exit Criteria
- Complete, validated patient intake interface with reactive Riverpod state.

### Implementation Commit
`feat(phase-4): build ambulance patient intake flow`

### Approval Commit
`chore(phase-4): approve ambulance patient intake`

---

# PHASE 5 — Bed Need Assessment

### Objective
Implement the BedLink Clinical Requirement Assessment interface for ambulance crews to specify mandatory countable resources and care capabilities.

### Scope
Patient summary banner, clinical resource catalog search, quick resource auto-suggest, selected requirement chips with quantity selectors, frequent requirement bundles, Riverpod requirement state, and validation requiring at least one countable resource.

### Eight Sub-Phases
- **5.1 Patient summary:** Display condensed summary card of the active patient intake at the top of the assessment screen.
- **5.2 Clinical resource search:** Implement instant filter/search for countable beds, equipment, and medical capabilities.
- **5.3 Auto-suggest clinical resources:** Suggest relevant resources automatically based on the chief complaint selected in Phase 4 (e.g., Cardiac -> `icu_bed` + `cardiac_care`).
- **5.4 Active requirement chips:** Build high-contrast requirement chips with quantity increment/decrement (`+`/`-`) and clear remove actions.
- **5.5 Frequent requirement shortcuts:** Provide one-tap emergency preset bundles: `Cardiac Emergency`, `Polytrauma ICU`, `Respiratory Failure (Ventilator)`, `Pediatric ICU`.
- **5.6 BedLink clinical resource catalogue:** Implement standardized resource models covering `icu_bed`, `ventilator`, `oxygen_bed`, `emergency_bed`, `general_bed`, `pediatric_icu_bed`, `cardiac_care`, `trauma_care`, `burns_care`, `pediatric_icu_care`.
- **5.7 Riverpod requirement state:** Build `BedRequirementNotifier` enforcing the mandatory rule: **at least one countable resource is required** to search.
- **5.8 Verification:** Verify catalog search, bundle selection, quantity adjustment, validation guards, and edge cases with automated tests.

### Expected Files / Modules
- `lib/features/ambulance/domain/models/resource_type.dart`, `lib/features/ambulance/domain/models/bed_requirement.dart`
- `lib/features/ambulance/presentation/providers/requirement_provider.dart`
- `lib/features/ambulance/presentation/screens/bed_requirement_screen.dart`
- `lib/features/ambulance/presentation/widgets/requirement_chip.dart`
- `lib/features/ambulance/presentation/widgets/requirement_preset_grid.dart`
- `lib/features/ambulance/presentation/widgets/resource_search_bar.dart`
- `test/features/ambulance/bed_requirement_test.dart`

### Dependencies
- Phase 4 (Patient Intake).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Unit tests prove that selecting only care capabilities without a countable resource fails validation.
- Widget tests prove preset buttons populate exact requirement sets.

### Manual Validation
- Tap "Cardiac Emergency" preset -> verify `icu_bed` + `cardiac_care` chips appear.
- Adjust ICU quantity to 2 -> verify requirement state reflects count.
- Tap "Find Suitable Hospitals" -> advances to Discovery.

### Exit Criteria
- Validated clinical requirement selector adhering to BedLink's hard-filter requirements.

### Implementation Commit
`feat(phase-5): implement bed need assessment and resource catalog`

### Approval Commit
`chore(phase-5): approve bed need assessment`

---

# PHASE 6 — Hospital Discovery & Match Grid Frontend

### Objective
Recreate the approved Hospital Match Grid interface displaying ranked hospital candidates with travel time, resource availability, freshness indicators, and facility capabilities using mock discovery data.

### Scope
Searching/matching radar animation, patient requirements bar, ranked hospital cards, primary recommended destination highlight, freshness and load tags, mock route mini-preview, expandable candidate details, and hold initiation CTA.

### Eight Sub-Phases
- **6.1 Matching/searching state:** Implement active discovery searching screen with pulse/radar indicator, search radius progression indicator (5km -> 10km -> 15km), and mock candidate count.
- **6.2 Patient requirement summary:** Display sticky top bar showing active patient triage tag, mandatory resources, and search radius.
- **6.3 Primary hospital result card:** Build featured card for the #1 ranked hospital displaying name, road ETA (min), distance (km), matching bed count, care capability badges, and primary "Request 2-Min Hold" button.
- **6.4 Ranking/recommendation states:** Visual differentiation for #1 Top Match (teal accent), Compatible Alternate candidates, and Diverted/Ineligible facilities.
- **6.5 Availability/freshness/load indicators:** Implement high-visibility freshness badges (`<5 min fresh`, `<15 min recent`, `stale`) and capacity load chips (`85% Occupied`, `Load unavailable`).
- **6.6 Mock route preview:** Embed lightweight visual vector route preview card showing travel path and destination pin.
- **6.7 Complete ranked hospital list:** Render scrollable list of secondary ranked hospitals with quick-compare metrics and individual "Request Hold" triggers.
- **6.8 Verification:** Verify match grid rendering across various mock response fixtures (5 matches, 1 match, 0 matches/no compatible hospitals).

### Expected Files / Modules
- `lib/features/matching/domain/models/hospital_match.dart`, `lib/features/matching/domain/models/match_score.dart`
- `lib/features/matching/data/mock_hospital_data.dart`
- `lib/features/matching/presentation/providers/matching_provider.dart`
- `lib/features/matching/presentation/screens/hospital_match_screen.dart`
- `lib/features/matching/presentation/widgets/primary_hospital_card.dart`
- `lib/features/matching/presentation/widgets/hospital_match_tile.dart`
- `lib/features/matching/presentation/widgets/freshness_tag.dart`
- `test/features/matching/hospital_match_test.dart`

### Dependencies
- Phase 5 (Bed Need Assessment).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Widget tests verify that match list accurately reflects provider state and handles empty/no-match states cleanly.

### Manual Validation
- Trigger hospital search -> observe brief searching indicator -> view ranked candidate cards.
- Verify top card highlights shortest ETA and available ICU bed count.
- Tap "Request 2-Min Hold" on top hospital -> navigates to Hold screen.

### Exit Criteria
- Pixel-perfect, high-contrast Hospital Match Grid operating with realistic mock Mumbai hospital data.

### Implementation Commit
`feat(phase-6): build hospital discovery and match grid frontend`

### Approval Commit
`chore(phase-6): approve hospital discovery grid`

---

# PHASE 7 — Two-Minute Hold & Confirmation Frontend

### Objective
Recreate the approved Hold Confirmation experience with animated 2-minute circular countdown, target bed summary, sequential fallback status, and simulation controls for acceptance/rejection/timeout.

### Scope
Hold confirmation screen, high-visibility 120-second circular countdown timer, target destination card, patient handoff preview, automatic fallback progress tracker, mock accepted transition, and mock rejection/timeout fallback transitions.

### Eight Sub-Phases
- **7.1 Hold confirmation screen:** Build dedicated emergency hold screen with active hospital name, reservation request ID, and urgent status indicator.
- **7.2 Circular 2-minute countdown:** Implement 120-second circular countdown clock with high-contrast JetBrains Mono time display (`02:00` -> `00:00`) and color transitions (teal -> amber at 30s -> red at 10s).
- **7.3 Target destination/bed card:** Display destination hospital address, reserved bed type, equipment items, and direct hospital telephone contact button.
- **7.4 Inbound patient summary:** Display condensed patient vitals and clinical requirements currently being reviewed by the hospital.
- **7.5 Automatic fallback status:** Implement fallback progress tracker showing: "Hospital #1 Contacted -> (Pending) -> Fallback: Hospital #2 on standby".
- **7.6 Mock accepted state:** Build instant transition to "Bed Reserved & Confirmed" state with green confirmation banner and "Start Navigation" primary action.
- **7.7 Mock rejected/timeout/fallback states:** Build demo simulation drawer/actions to trigger mock "Hospital Rejected" or "Offer Timed Out", demonstrating automatic visual advance to the next hospital.
- **7.8 Verification:** Verify countdown timer accuracy, timer cancellation on dispose, fallback state transitions, and cancellation dialog.

### Expected Files / Modules
- `lib/features/reservation/domain/models/hold_status.dart`, `lib/features/reservation/domain/models/reservation_offer.dart`
- `lib/features/reservation/presentation/providers/hold_timer_provider.dart`
- `lib/features/reservation/presentation/screens/hold_confirmation_screen.dart`
- `lib/features/reservation/presentation/widgets/circular_countdown.dart`
- `lib/features/reservation/presentation/widgets/fallback_progress_tracker.dart`
- `lib/features/reservation/presentation/widgets/mock_offer_controller_drawer.dart`
- `test/features/reservation/hold_confirmation_test.dart`

### Dependencies
- Phase 6 (Hospital Match Grid).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Timer unit tests verify tick rate, expiration handling, and state mutation.
- Widget tests verify fallback advance when an offer is rejected or expires.

### Manual Validation
- Start hold -> watch 120-second timer countdown.
- Trigger "Simulate Accept" -> screen transitions immediately to confirmed state with "Start Navigation" button.
- Trigger "Simulate Reject" -> watch timer reset for next ranked hospital.

### Exit Criteria
- Fully functioning hold countdown and fallback presentation with demo controls.

### Implementation Commit
`feat(phase-7): build two-minute hold and confirmation frontend`

### Approval Commit
`chore(phase-7): approve hold confirmation flow`

---

# PHASE 8 — Complete Hospital Staff Frontend

### Objective
Build the complete hospital-side interface allowing triage staff to manage critical bed inventories with <=10 second rapid adjustments, confirm data freshness, and accept/reject incoming emergency ambulance requests.

### Scope
Hospital overview dashboard, 6 countable resource inventory tiles, rapid one-tap `+`/`-` counters, "Confirm No Change" freshness action, incoming emergency offer modal/alert, accept/reject workflows, and active incoming reservations list.

### Eight Sub-Phases
- **8.1 Hospital dashboard:** Build triage console dashboard displaying hospital identity (e.g., "KEM Hospital"), active department, bed census overview, and emergency banner.
- **8.2 Resource inventory:** Render the 6 standard countable resources (`general_bed`, `emergency_bed`, `icu_bed`, `ventilator`, `oxygen_bed`, `pediatric_icu_bed`) with available, held, and occupied counts.
- **8.3 Fast one-tap availability controls:** Implement large 48dp `+`/`-` tap targets enabling staff to modify bed availability in under 10 seconds with instantaneous optimistic visual updates.
- **8.4 Freshness + Confirm No Change:** Build prominent "Confirm No Change" CTA button that refreshes all resource freshness timestamps (`Just now`) in one tap without altering counts.
- **8.5 Incoming emergency request:** Build urgent incoming transfer modal showing ambulance callsign, patient age/sex, mandatory requirements (e.g., `ICU Bed + Ventilator`), ETA, and 120s server countdown.
- **8.6 Accept/reject frontend states:** Implement one-tap "Accept & Hold Beds" (teal CTA) and "Unable to Accept / Divert" (red CTA with rejection reason selector).
- **8.7 Active holds/reservations:** Build active reservations table displaying inbound ambulances, held resource types, estimated arrival time, and "Mark Arrived" action.
- **8.8 Complete hospital frontend verification:** Validate 10-second rapid inventory updates, incoming offer alert display, accept/reject flows, and UI resilience on tablets and phones.

### Expected Files / Modules
- `lib/features/hospital/domain/models/hospital_resource.dart`, `lib/features/hospital/domain/models/incoming_offer.dart`
- `lib/features/hospital/presentation/providers/hospital_inventory_provider.dart`
- `lib/features/hospital/presentation/screens/hospital_dashboard_screen.dart`
- `lib/features/hospital/presentation/widgets/resource_counter_tile.dart`
- `lib/features/hospital/presentation/widgets/confirm_no_change_button.dart`
- `lib/features/hospital/presentation/widgets/incoming_offer_dialog.dart`
- `lib/features/hospital/presentation/widgets/active_reservations_list.dart`
- `test/features/hospital/hospital_dashboard_test.dart`

### Dependencies
- Phase 3 (App Shell & Role Navigation).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Widget tests verify `+`/`-` controls update inventory counts and prevent negative values.
- Unit tests verify "Confirm No Change" timestamp refresh logic.

### Manual Validation
- Test rapid inventory adjustment: change 3 resource counts in < 10 seconds.
- Trigger incoming emergency offer -> tap "Accept" -> verify bed moves from `Available` to `Held` and appears in Active Reservations.

### Exit Criteria
- Intuitive, high-speed hospital triage interface for rapid inventory management and transfer coordination.

### Implementation Commit
`feat(phase-8): build complete hospital staff frontend`

### Approval Commit
`chore(phase-8): approve hospital staff frontend`

---

# PHASE 9 — Navigation, En Route & Arrival Frontend

### Objective
Implement the en-route transit and hospital arrival interface for ambulance crews using mock routing data, showing turn-by-turn guidance, live ETA updates, held bed confirmation, and patient handoff completion.

### Scope
Confirmed transfer destination screen, navigation overview with route polyline preview, turn guidance instructions, dynamic ETA counter, persistent held-bed security banner, arrival confirmation trigger, and completed transfer handoff summary.

### Eight Sub-Phases
- **9.1 Confirmed destination:** Display confirmed hospital header with hospital address, trauma desk direct phone line, and reserved reservation token ID.
- **9.2 Navigation screen:** Build transit navigation container with simulated GPS movement, mock map canvas, route path overlay, and destination marker.
- **9.3 Route instruction UI:** Implement high-contrast next-turn maneuver card (e.g., "In 400m, turn left onto Dr. E Moses Rd") with lane indicators.
- **9.4 Mock live ETA:** Display prominent tabular ETA and distance readouts (`12 MIN`, `4.2 KM`) with live minute decrement simulation.
- **9.5 Reservation/bed-held banner:** Maintain persistent top banner: "1 ICU BED & 1 VENTILATOR HELD AT DESTINATION" to reassure crew during transit.
- **9.6 Arrival confirmation:** Build slide-to-confirm / two-tap "Confirm Arrival at Emergency Department" action.
- **9.7 Completed handoff state:** Render successful handoff summary screen displaying total transit time, receiving hospital staff info, and "Complete & Return to Ready" action.
- **9.8 Verification:** Verify navigation UI layout, turn instruction sequence, arrival confirmation flow, and reset back to ready state.

### Expected Files / Modules
- `lib/features/navigation/domain/models/route_step.dart`, `lib/features/navigation/domain/models/transit_summary.dart`
- `lib/features/navigation/presentation/providers/navigation_provider.dart`
- `lib/features/navigation/presentation/screens/navigation_screen.dart`
- `lib/features/navigation/presentation/screens/handoff_complete_screen.dart`
- `lib/features/navigation/presentation/widgets/route_maneuver_card.dart`
- `lib/features/navigation/presentation/widgets/held_bed_banner.dart`
- `lib/features/navigation/presentation/widgets/arrival_action_button.dart`
- `test/features/navigation/navigation_flow_test.dart`

### Dependencies
- Phase 7 (Hold Confirmation).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Widget tests verify arrival action transitions to completed handoff screen.
- State tests verify navigation timer and route step progression.

### Manual Validation
- Tap "Start Navigation" from Hold screen -> see en-route navigation view with persistent held-bed banner.
- Tap "Confirm Arrival" -> see completed handoff summary -> tap "Return to Ready" -> resets to Ambulance Intake.

### Exit Criteria
- Complete ambulance en-route transit, arrival confirmation, and handoff experience.

### Implementation Commit
`feat(phase-9): build navigation en route and arrival frontend`

### Approval Commit
`chore(phase-9): approve navigation and arrival frontend`

---

# PHASE 10 — Frontend Resilience + Complete Mock E2E

### Objective
Complete the frontend hardening phase: implement comprehensive empty/error/offline presentation states, accessibility optimization for budget hardware, and verify the complete ambulance-to-hospital workflow entirely with mock repositories before any backend integration.

### Scope
Global loading skeletons, empty state illustrations, simulated offline/reconnecting banners, error recovery dialogs, 320dp width & 200% font scaling audits, automated end-to-end mock workflow test suite, and Phase 1–10 frontend freeze sign-off.

### Eight Sub-Phases
- **10.1 Loading states:** Implement non-blocking shimmer skeleton loaders for hospital match lists, dashboard inventories, and route calculations.
- **10.2 Empty states:** Build clinical empty states for "No Incoming Offers", "No Active Holds", "Search Criteria Too Restrictive", and "No Hospitals Nearby".
- **10.3 Offline/reconnecting states:** Implement unverified cached data banners ("Offline — Showing Last Known Data") and disabled action guards when disconnected.
- **10.4 Error/failure states:** Create user-safe error dialogs with actionable recovery buttons for GPS timeout, routing failure, offer expired, and authentication rejected.
- **10.5 Accessibility and cheap-phone optimization:** Audit and fix all tap targets (<48dp), small text (<14sp), and layout overflows at 320dp width and 200% font scaling across all screens.
- **10.6 Complete mock ambulance ↔ hospital workflow:** Implement seamless interactive demo toggle allowing a single tester to switch between Ambulance and Hospital roles in real time.
- **10.7 Frontend regression/widget/provider tests:** Execute comprehensive unit, widget, and provider test suites covering all frontend flows from Phase 1 through 10.
- **10.8 Phase 1–10 frontend freeze audit:** Generate `FRONTEND_FREEZE_REPORT.md` confirming 100% backend-independent frontend completion, zero analysis errors, and demo readiness.

### Expected Files / Modules
- `lib/shared/widgets/states/bedlink_loading_skeleton.dart`
- `lib/shared/widgets/states/bedlink_empty_state.dart`
- `lib/shared/widgets/states/offline_banner.dart`
- `lib/shared/widgets/states/bedlink_error_view.dart`
- `lib/features/demo/presentation/demo_controller_drawer.dart`
- `test/e2e/mock_e2e_workflow_test.dart`
- `FRONTEND_FREEZE_REPORT.md`

### Dependencies
- Phases 1–9.

### Automated Validation
- `flutter analyze` passes with 0 issues across the entire `lib/` and `test/` tree.
- `flutter test` executes complete widget and provider suite with 100% pass rate.

### Manual Validation
- Run complete end-to-end interactive demo without network:
  1. Login as Ambulance -> Intake -> Requirements (ICU + Vent) -> Find Hospitals.
  2. Switch to Hospital view -> Observe incoming offer -> Accept.
  3. Switch to Ambulance view -> Observe confirmation -> Navigate -> Confirm Arrival -> Complete Handoff.

### Exit Criteria
- Complete, rock-solid BedLink frontend demonstrable in its entirety without a live backend.

### Implementation Commit
`feat(phase-10): complete frontend resilience and mock e2e workflows`

### Approval Commit
`chore(phase-10): approve complete mock frontend freeze`

---

# PHASE 11 — Supabase Authentication & Core Data Integration

### Objective
Integrate real Supabase backend services: connect `supabase_flutter`, establish Supabase Auth, resolve user profiles and roles, and swap mock authentication/profile repositories with production implementations.

### Scope
Supabase client initialization, secure environment variable configuration, Supabase Auth (email/10-digit ID login), user profile and role resolution (`ambulance_crew` vs `hospital_staff`), session persistence, auth token refresh, and integration test suite.

### Eight Sub-Phases
- **11.1 Supabase client/environment setup:** Add `supabase_flutter` to `pubspec.yaml`, configure `AppConfig` to read `SUPABASE_URL` and `SUPABASE_ANON_KEY` via `--dart-define`, and initialize client in `bootstrap.dart`.
- **11.2 Supabase Auth:** Implement `SupabaseAuthRepository` for user sign-in, sign-out, session restoration, and password management.
- **11.3 Profiles and role resolution:** Query `profiles` table to resolve authenticated user UUID, role (`hospital_staff` or `ambulance_crew`), and organization association (`hospital_id` or `ambulance_id`).
- **11.4 Hospital repository implementation:** Implement `SupabaseHospitalRepository` to query static hospital directory and hospital capability tables.
- **11.5 Ambulance repository implementation:** Implement `SupabaseAmbulanceRepository` to query and bind active ambulance metadata.
- **11.6 Session recovery:** Build automatic session restoration on app startup and handle expired refresh tokens gracefully by redirecting to `/login`.
- **11.7 Remove production dependency on mock repositories:** Configure Riverpod provider overrides so production builds use Supabase repositories while test builds retain mock fixtures.
- **11.8 Integration verification:** Execute automated integration tests verifying real login, role queries, and error handling against Supabase backend.

### Expected Files / Modules
- `lib/core/config/app_config.dart`, `lib/core/data/supabase_client.dart`
- `lib/features/auth/data/supabase_auth_repository.dart`
- `lib/features/auth/domain/repositories/auth_repository.dart`
- `lib/features/hospital/data/supabase_hospital_repository.dart`
- `lib/features/ambulance/data/supabase_ambulance_repository.dart`
- `test/integration/supabase_auth_test.dart`

### Dependencies
- Phase 10 (Frontend Freeze) + Supabase Backend Schema/Migrations configured.

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Integration tests verify authentication, profile resolution, and RLS enforcement.

### Manual Validation
- Sign in with real seeded credentials for Ambulance Crew and Hospital Staff; verify correct role routing and profile header details.

### Exit Criteria
- Production Supabase Auth and core data repositories integrated and operational.

### Implementation Commit
`feat(phase-11): integrate supabase auth and core repositories`

### Approval Commit
`chore(phase-11): approve supabase auth and core data integration`

---

# PHASE 12 — Supabase Realtime + Hospital Resource + Reservation Integration

### Objective
Integrate real-time data synchronization: connect Supabase Realtime for live hospital inventory changes, incoming transfer offers, server-authoritative 120s offer expirations, and atomic reservation state tracking.

### Scope
Realtime channel subscription architecture, live `hospital_resources` updates, incoming `hospital_offers` subscriptions, Edge Function call integration for Accept/Reject, `reservations` tracking, and reconnection snapshot reconciliation.

### Eight Sub-Phases
- **12.1 Realtime architecture:** Build `RealtimeService` managing authorized Postgres Changes and Broadcast channel subscriptions with automatic resubscribe on reconnect.
- **12.2 Real hospital resource updates:** Wire hospital dashboard to execute `update-hospital-resource` and `confirm-hospital-availability` Edge Functions, updating authoritative PostgreSQL tables.
- **12.3 Incoming hospital offers:** Subscribe hospital dashboard to Postgres Changes on `hospital_offers` filtering for the staff's `hospital_id`.
- **12.4 Server-authoritative offer expiration:** Bind 120-second offer timer strictly to server `expires_at` timestamp; listen for server `timed_out` state transitions.
- **12.5 Accept/reject integration:** Connect Accept and Reject actions to `respond-to-offer` Edge Function with transactional inventory locks and capacity re-checks.
- **12.6 Reservation/hold integration:** Wire ambulance hold screen to listen for `reservations` and `hospital_offers` state updates via Realtime and snapshot polling.
- **12.7 Realtime reconnect reconciliation:** Implement authoritative snapshot fetch on network reconnect to eliminate missed realtime event race conditions.
- **12.8 Verification:** Verify multi-client live updates: hospital adjusts inventory -> ambulance discovery updates; ambulance requests hold -> hospital inbox rings in real time.

### Expected Files / Modules
- `lib/core/data/realtime_service.dart`
- `lib/features/hospital/data/supabase_inventory_repository.dart`
- `lib/features/reservation/data/supabase_reservation_repository.dart`
- `lib/features/hospital/presentation/providers/realtime_offers_provider.dart`
- `test/integration/realtime_sync_test.dart`

### Dependencies
- Phase 11 (Supabase Auth & Core Data).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Integration tests verify offer creation, acceptance, and realtime notification propagation between two distinct authenticated clients.

### Manual Validation
- Open Hospital on one device and Ambulance on another:
  - Ambulance requests hold -> Hospital instantly displays incoming alert.
  - Hospital taps Accept -> Ambulance instantly transitions to confirmed reservation.

### Exit Criteria
- Realtime coordination and server-authoritative hold progression operating seamlessly across devices.

### Implementation Commit
`feat(phase-12): integrate supabase realtime and reservation flows`

### Approval Commit
`chore(phase-12): approve supabase realtime integration`

---

# PHASE 13 — Location & Hospital Discovery API

### Objective
Integrate device GPS positioning and connect the ambulance discovery workflow to the server-authoritative Hospital Discovery and Radius Expansion backend API.

### Scope
`geolocator` integration, location permission management, GPS coordinates capture, `create-emergency-request` and `find-and-offer` Edge Function integration, dynamic search radius expansion (5->10->15->20->30 km), clinical requirement payload serialization, and discovery error recovery.

### Eight Sub-Phases
- **13.1 Geolocator integration:** Add `geolocator` package, implement `LocationService` with Android/Web permission rationale, timeout handling, and accuracy check.
- **13.2 Real ambulance coordinates:** Bind real GPS coordinates to the Ambulance Intake screen with high-accuracy GPS lock indicator and fallback manual coordinate dialog for indoor demo testing.
- **13.3 Hospital discovery backend/API:** Connect the search action to `create-emergency-request` and `find-and-offer` Edge Functions.
- **13.4 Dynamic search-radius handling:** Implement backend radius progression tracking in UI as server searches 5km, 10km, 15km, 20km, 30km bounds.
- **13.5 Clinical requirement request payload:** Serialize patient urgency, mandatory countable resource quantities, and required care capabilities into canonical API format.
- **13.6 Discovery response/domain mapping:** Map backend ranked candidate response (`request_candidates` with road ETA and match score) to Match Grid domain models.
- **13.7 Discovery/API error states:** Handle backend `NO_CANDIDATES`, `ROUTING_UNAVAILABLE`, `RATE_LIMITED`, and network timeout errors with retry and requirement relaxation advice.
- **13.8 Integration verification:** Test live GPS acquisition and discovery API execution against seeded Mumbai hospital coordinates.

### Expected Files / Modules
- `lib/core/services/location_service.dart`
- `lib/features/ambulance/data/emergency_request_api_client.dart`
- `lib/features/matching/data/supabase_discovery_repository.dart`
- `test/integration/discovery_api_test.dart`

### Dependencies
- Phase 12 (Realtime & Reservations).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Integration tests verify valid emergency request creation and candidate list parsing from backend responses.

### Manual Validation
- On a real device/emulator with GPS enabled: create intake -> verify real latitude/longitude -> search -> verify live ranked hospital results based on location.

### Exit Criteria
- Real device location capture and server-authoritative hospital discovery fully connected.

### Implementation Commit
`feat(phase-13): integrate geolocator and hospital discovery api`

### Approval Commit
`chore(phase-13): approve location and discovery api integration`

---

# PHASE 14 — MapLibre, MapTiler & OpenRouteService

### Objective
Integrate real vector map rendering and routing: configure MapLibre with MapTiler styles, render live hospital/ambulance markers, and display road route geometries from the server-proxied OpenRouteService Directions API.

### Scope
`maplibre_gl` setup, MapTiler style integration, ambulance location marker, destination hospital marker, server-proxied ORS Matrix road ETA in Match Grid, ORS Directions route polyline rendering, and map failure fallback.

### Eight Sub-Phases
- **14.1 MapLibre configuration:** Add `maplibre_gl` to `pubspec.yaml`, configure Android/Web platform permissions, and implement reusable `BedLinkMap` widget.
- **14.2 MapTiler configuration:** Configure public MapTiler vector tile style URLs via `AppConfig` with fallback offline style assets.
- **14.3 Ambulance location marker:** Render dynamic ambulance location marker with heading indicator and pulse effect.
- **14.4 Hospital markers:** Render destination hospital pin and nearby candidate pins with status callouts on the map.
- **14.5 OpenRouteService Matrix integration:** Display real road travel times and road distances calculated by server-side ORS Matrix in the Match Grid.
- **14.6 Real ETA/distance in Match Grid:** Wire candidate cards to display live driving durations instead of straight-line approximations.
- **14.7 OpenRouteService Directions + route rendering:** Request route geometry via `get-route` Edge Function and render high-contrast polyline on `maplibre_gl` canvas.
- **14.8 Map/routing verification:** Test map rendering, polyline fitting, zoom transitions, and text-only fallback when map tiles are unavailable.

### Expected Files / Modules
- `lib/features/navigation/presentation/widgets/bedlink_map_view.dart`
- `lib/features/navigation/data/supabase_routing_repository.dart`
- `lib/features/navigation/domain/models/map_marker.dart`, `lib/features/navigation/domain/models/route_geometry.dart`
- `test/features/navigation/map_routing_test.dart`

### Dependencies
- Phase 13 (Location & Discovery API).

### Automated Validation
- `flutter analyze` passes with 0 issues.
- Unit/widget tests verify GeoJSON route parsing, marker coordinate mapping, and map error fallback widgets.

### Manual Validation
- On confirmed reservation: map renders real Mumbai road geometry from ambulance location to destination hospital; text ETA and distance match polyline summary.

### Exit Criteria
- Vector maps and server-proxied road routing cleanly integrated with resilient textual fallbacks.

### Implementation Commit
`feat(phase-14): integrate maplibre maptiler and openrouteservice`

### Approval Commit
`chore(phase-14): approve map and routing integration`

---

# PHASE 15 — Complete Backend/API E2E, Offline Recovery & Release

### Objective
Perform end-to-end system hardening across the complete live stack: validate real multi-resource reservations, automatic server-side fallback progression, local active-request caching with `shared_preferences`, reconnection recovery, and produce the final hackathon production release.

### Scope
Live multi-resource emergency request flow, server fallback synchronization, local pointer persistence, offline reconnect recovery, arrival/completion backend mutation, multi-role adversarial stress testing, performance & accessibility audit, and final release report.

### Eight Sub-Phases
- **15.1 Complete real emergency request flow:** Verify complete live flow: Ambulance submits -> Server searches & ranks -> Hospital receives offer -> Hospital accepts -> Bed held -> Navigation routes -> Arrival confirmed.
- **15.2 Real automatic fallback UI synchronization:** Test real automatic fallback: Hospital #1 times out (120s) or rejects -> Server advances to Hospital #2 -> Ambulance UI updates automatically via Realtime.
- **15.3 Local active-request persistence:** Persist non-sensitive `active_request_id` and `reservation_id` in `shared_preferences` for crash and restart resilience.
- **15.4 Reconnection synchronization:** Simulate complete network drop during active transfer; reconnect app and verify full authoritative state restoration from PostgreSQL.
- **15.5 Arrival/completion backend API:** Connect "Confirm Arrival" to `confirm-arrival` Edge Function, moving inventory from `held_count` to `occupied_count` atomically.
- **15.6 Full ambulance ↔ hospital E2E testing:** Execute multi-device end-to-end testing matrix across Android phones, tablets, and Web browsers.
- **15.7 Security/performance/accessibility/frontend audit:** Run OWASP security review (zero exposed keys/secrets), performance audit (sub-2s updates), and accessibility validation (48dp targets, high contrast).
- **15.8 Final BedLink frontend readiness report:** Generate `FINAL_RELEASE_REPORT.md` documenting architecture, test results, demo credentials, and production deployment readiness.

### Expected Files / Modules
- `lib/core/local/local_storage_service.dart`
- `lib/features/ambulance/presentation/providers/active_request_sync_provider.dart`
- `test/e2e/live_backend_e2e_test.dart`
- `FINAL_RELEASE_REPORT.md`
- `Resources/memory.md` (final update)

### Dependencies
- Phases 1–14.

### Automated Validation
- `flutter analyze` passes with 0 issues.
- `flutter test` passes 100% across all unit, widget, and integration suites.
- Complete live E2E test passes without race conditions or state desynchronization.

### Manual Validation
- Run final rehearsal of complete hackathon demo scenario:
  1. Hospital adjusts inventory.
  2. Ambulance requests `ICU + Ventilator`.
  3. First hospital rejects -> automatically falls back to second hospital.
  4. Second hospital accepts -> bed held -> ambulance receives route.
  5. Ambulance disconnects and reconnects -> state seamlessly recovered.
  6. Ambulance arrives -> staff completes intake -> inventory updates to occupied.

### Exit Criteria
- Fully validated, hackathon-ready, production-grade BedLink frontend with complete backend and API integration.

### Implementation Commit
`feat(phase-15): complete backend api e2e integration and final release`

### Approval Commit
`chore(phase-15): approve final bedlink production release`

---
