# BedLink Implementation Roadmap

This roadmap is ordered to prove server safety before completing the polished flow. A request such as “Implement Phase 5.2” means implement only that numbered sub-phase, its tests, and any small prerequisite repair; do not silently start the next phase. The canonical API, schema, and states are in `Architecture.md`. No application code exists at the start of this roadmap.

## Shared delivery rule

For each sub-phase: inspect current files and `memory.md`; implement migrations before clients that need them; add meaningful tests; run applicable `flutter analyze`, `flutter test`, SQL/RLS tests, and Edge Function tests; update `memory.md` with what passed and what remains. A phase exits only when its listed validation is demonstrated, not when a screen merely renders.

## Phase 0 — Project foundation

**Objective:** Create reproducible development setup without implementing business flow.

**Sub-phases:**

- **0.1 Repository/toolchain:** Add Flutter project, SDK constraints, lint config, `.gitignore`, and setup instructions. Confirm Android emulator/device run.
- **0.2 Supabase local setup:** Initialize Supabase project config and migration/test folders; document local and hosted environments with placeholder variables only.
- **0.3 Demo data policy:** Define seed provenance and mark simulated dynamic counts; obtain/curate a small Mumbai static directory with source attribution and coordinate checks.

**Likely files/modules:** `pubspec.yaml`, `analysis_options.yaml`, `lib/main.dart`, `supabase/config.toml`, `supabase/seed.sql`, `README.md`, `.env.example` (planned paths).

**Database/backend work:** Empty migration baseline, local Supabase smoke test, seed plan. **Frontend work:** Bootable empty app. **Validation:** `flutter analyze`, `flutter test`, local Supabase start/migration smoke test. **Exit:** A clean checkout runs with no secrets committed. **Dependencies:** Documentation foundation.

## Phase 1 — Flutter architecture and design system

**Objective:** Establish role-neutral app structure and reusable clinical UI before feature screens.

**Sub-phases:**

- **1.1 App shell:** Router, error boundary, configuration loader, Supabase client provider, feature folders.
- **1.2 Design tokens:** Light-theme colors/type/spacing/components from `design.md`; 48dp controls and 320dp layouts.
- **1.3 State patterns:** Riverpod async/error/offline presentation and repository interfaces; no simulated successful backend results.

**Likely files/modules:** `lib/app/*`, `lib/core/*`, `lib/shared/*`, widget tests. **Database/backend work:** None beyond environment wiring. **Frontend work:** App shell, theme, shared components. **Validation:** Analyze, widget tests at 320dp and 200% text scale. **Exit:** Screen skeletons can use typed providers and consistent components. **Dependencies:** Phase 0.

## Phase 2 — Supabase identity and access

**Objective:** Prove role ownership and RLS before data-changing features.

**Sub-phases:**

- **2.1 Schema:** Migrate `hospitals`, `ambulances`, `profiles` with UUID internal keys and unique 10-digit display IDs.
- **2.2 Auth:** Supabase Auth login/session refresh, profile lookup, role-based routing, demo account provisioning with distinct passwords.
- **2.3 RLS:** Default-deny policies and cross-tenant access tests for two hospitals and two ambulances.

**Likely files/modules:** `supabase/migrations/*`, `supabase/tests/rls*`, `lib/features/auth/*`, `lib/app/router.dart`. **Database/backend work:** Auth link, profiles, RLS. **Frontend work:** Splash/login, role dashboards placeholders. **Validation:** Wrong role/association denied; valid user routed correctly; session expiration handled. **Exit:** Identity and access tests pass. **Dependencies:** Phases 0–1.

## Phase 3 — Hospital resource model and reporting

**Objective:** Make hospital capability and availability truthful, fast, and secure.

**Sub-phases:**

- **3.1 Schema/seed:** Add `hospital_capabilities`, `hospital_resources`, code constraints, nonnegative checks, timestamps; seed attributed static directory and visibly simulated dynamic values.
- **3.2 Server updates:** Add resource-count adjustment and “confirm no change” transactional functions/Edge endpoints with hospital ownership checks; prevent negative or over-capacity counts. Quick count changes clear stale occupancy/unavailable breakdown so load becomes unknown until explicit reconciliation.
- **3.3 Staff UI:** Dashboard, six count cards, three capability badges plus pediatric ICU support, confirm action, freshness, active error states.

**Likely files/modules:** `supabase/migrations/*`, `supabase/functions/update-hospital-resource/*`, `confirm-hospital-availability/*`, `lib/features/hospital_resources/*`. **Database/backend work:** Constraints and mutation APIs. **Frontend work:** Touch-friendly dashboard. **Validation:** Ten-second usability rehearsal; negative/unauthorized updates rejected; timestamp changes only after server success. **Exit:** Staff can report and recertify counts reliably. **Dependencies:** Phase 2.

## Phase 4 — Ambulance request creation

**Objective:** Persist one validated request with mandatory requirements.

**Sub-phases:**

- **4.1 Schema:** `emergency_requests`, `emergency_request_requirements`, at-least-one-countable-resource validation, active-request uniqueness/idempotency, request status/version.
- **4.2 Location and form:** GPS permission/accuracy states, mandatory requirement selection, urgency label, safe manual coordinate entry for demo.
- **4.3 Create endpoint:** Authenticated idempotent submission and active request recovery by user; UI stores pointer only after acknowledgment.

**Likely files/modules:** `supabase/migrations/*`, `create-emergency-request/*`, `lib/features/ambulance_request/*`, `lib/core/local/*`. **Database/backend work:** Request validation and creation. **Frontend work:** Dashboard, requirements, creation, loading/errors. **Validation:** Duplicate retry returns same request; invalid GPS/role/requirement rejected. **Exit:** One acknowledged request can be resumed. **Dependencies:** Phases 2–3.

## Phase 5 — Discovery and road ETA

**Objective:** Produce only clinically feasible hospitals and real road travel times.

**Sub-phases:**

- **5.1 Hard filtering:** Configurable radius expansion, capability/resource/freshness checks, explicit no-nearby vs no-compatible results.
- **5.2 ORS Matrix proxy:** Server-only key, one-source/many-destination Matrix call, null/unreachable/quota/timeouts handled without fake ETA.
- **5.3 Candidate persistence:** Store bounded candidate set with radius and ETA in `request_candidates`; expose restricted ranked-results projection (temporary pre-ranking order by ETA).

**Likely files/modules:** `supabase/functions/find-and-offer/*` discovery helper, `_shared/ors_client.ts`, migrations, `lib/features/discovery/*`. **Database/backend work:** Search query, ORS integration, candidates. **Frontend work:** Searching/result/empty/error views. **Validation:** ICU+ventilator+cardiac excludes a missing capability or count; 5→10→15 km expansion works; ORS errors never create an offer. **Exit:** Real ETA candidates persist. **Dependencies:** Phase 4.

## Phase 6 — Deterministic ranking

**Objective:** Rank eligible candidates transparently and reproducibly.

**Sub-phases:**

- **6.1 Score config:** Normalize clinical margin, ETA, freshness, capacity, load with canonical 40/25/15/10/10 weights and stable tie-break.
- **6.2 Snapshot/audit:** Persist component scores, algorithm version, final ranks; expose explanation to result cards.
- **6.3 Edge cases:** Unknown load, stale boundary, equal scores, missing ETA, reduced availability before offer.

**Likely files/modules:** `supabase/functions/_shared/ranking.ts`, `request_candidates` migration, `lib/features/discovery/*`. **Database/backend work:** Score calculation and persistence. **Frontend work:** Ranked cards with ETA/age/load. **Validation:** Deterministic fixtures and boundary tests; no incompatible hospital ranks. **Exit:** Same inputs yield same persisted order. **Dependencies:** Phase 5.

## Phase 7 — Sequential hospital offers

**Objective:** Contact one hospital at a time with a server deadline.

**Sub-phases:**

- **7.1 Offer schema/transition:** `hospital_offers`, `request_events`, one-pending partial index; open first offer from rank 1.
- **7.2 Hospital inbox:** Authorized Realtime signal plus snapshot fetch; incoming requirement/ETA/deadline UI.
- **7.3 Response path:** Authenticated Accept/Reject API skeleton; Accept validation and full hold commit arrive in Phase 9, so until then use integration fixture/staged flow and do not display confirmed status without reservation.

**Likely files/modules:** Migrations, `respond-to-offer/*`, `lib/features/hospital_offers/*`, `lib/features/ambulance_request/*`. **Database/backend work:** Offer transitions/authorization. **Frontend work:** Pending timer and inbox. **Validation:** Exactly one pending offer, wrong hospital denied, deadline server-generated. **Exit:** Offer is visible to correct hospital and server owns its state; accepted path is not claimed complete yet. **Dependencies:** Phase 6.

## Phase 8 — Timeout and automatic fallback

**Objective:** Make rejection/expiry progression independent of either phone.

**Sub-phases:**

- **8.1 Advance transaction:** Lock request, settle current offer, choose next unoffered rank, or `no_match`; idempotent repeat.
- **8.2 Scheduled recovery:** Supabase Cron runs bounded sweep for expired offers and stranded `searching`/`offering` requests; compare exact server deadline.
- **8.3 UI states:** Rejection, timeout, automatic fallback, all exhausted with reason and retry/new-request action.

**Likely files/modules:** Transaction migration, `recover-workflows/*`, `respond-to-offer/*`, request state UI. **Database/backend work:** Scheduler and recovery. **Frontend work:** Progress/empty states. **Validation:** Disconnect ambulance; reject/timeout advances; late Accept fails; no duplicate offer under overlapping sweeps. **Exit:** Backend reaches next candidate or `no_match` unaided. **Dependencies:** Phase 7.

## Phase 9 — Atomic reservation and hold

**Objective:** Make acceptance safe for multiple scarce resources.

**Sub-phases:**

- **9.1 Schema:** `reservations`, `reservation_items`, uniqueness and inventory checks.
- **9.2 Atomic accept:** Lock request/offer/inventory, recheck capability/count/deadline, hold all requested countable items, confirm request, emit event; capacity loss advances.
- **9.3 Release/arrival:** Idempotent cancel/release and arrival transaction; active holds/inbound UI and confirmed ambulance UI.

**Likely files/modules:** Migrations/SQL RPCs, `respond-to-offer/*`, `cancel-request/*`, `confirm-arrival/*`, hospital holds and ambulance confirmation screens. **Database/backend work:** Transaction functions. **Frontend work:** Held-item and arrival states. **Validation:** Two simultaneous requests for last ICU unit yield one hold; ICU+ventilator is all-or-nothing; repeat accept/cancel/arrival is safe. **Exit:** No confirmation without committed reservation; counts reconcile. **Dependencies:** Phase 8.

## Phase 10 — Realtime and offline recovery

**Objective:** Keep both roles informed and recover after signal loss.

**Sub-phases:**

- **10.1 Authorized subscriptions:** Enable publication/policies; request/offer/inventory invalidation and snapshot fetch on subscribe.
- **10.2 Local pointer:** `shared_preferences` active request/reservation pointer, last seen version/state, unverified offline badge.
- **10.3 Reconnect:** Session refresh, authoritative snapshot, version comparison, resubscribe/refetch; recover missing local pointer from server.

**Likely files/modules:** RLS/publication migration, `get-request-snapshot/*`, `lib/core/connectivity/*`, request/offer providers. **Database/backend work:** Safe snapshot and Realtime policy. **Frontend work:** Offline/reconnecting states. **Validation:** Ambulance disconnects during A reject/B timeout/C accept and later shows C's hold; duplicate events do not regress state. **Exit:** Workflow completes offline and UI reconciles. **Dependencies:** Phase 9.

## Phase 11 — Route and map

**Objective:** Show the accepted destination and usable route.

**Sub-phases:**

- **11.1 Directions proxy:** Authenticated ORS Directions call only for confirmed request; validate geometry/distance/duration.
- **11.2 Map:** `maplibre_gl` with MapTiler, markers and route; text address/ETA/distance always visible.
- **11.3 Failure handling:** Tile outage, Directions outage, GPS drift, route retry, arrival button usable without tiles.

**Likely files/modules:** `get-route/*`, `_shared/ors_client.ts`, `lib/features/navigation/*`, public map config. **Database/backend work:** Route authorization/proxy. **Frontend work:** Navigation and arrival screen. **Validation:** Route draws from real Directions response; no key in app; text fallback works. **Exit:** Accepted request can navigate and confirm arrival. **Dependencies:** Phases 9–10.

## Phase 12 — Integration and safety validation

**Objective:** Exercise full flow and close failure-path gaps.

**Sub-phases:**

- **12.1 End-to-end:** Seed three hospitals, create request, A rejects, B times out, C accepts, hold, route, arrival.
- **12.2 Adversarial:** Last-unit concurrency, late acceptance, cross-role access, stale data, ORS outage, Supabase outage, lost acknowledgment, cancellation.
- **12.3 Device/accessibility:** Small low-memory Android, 320dp, 200% text, screen reader labels, outdoor light theme; measure PRD performance targets.

**Likely files/modules:** Integration tests, SQL/RLS/function tests, fixes across features, docs. **Database/backend work:** Repair constraints/policies and monitoring. **Frontend work:** Fix accessibility/edge states. **Validation:** MVP acceptance criteria in `PRD.md` pass or each gap is explicitly recorded. **Exit:** Demo flow is repeatable and safety invariants hold. **Dependencies:** Phases 0–11.

## Phase 13 — Demo preparation

**Objective:** Present a truthful, reliable hackathon demonstration.

**Sub-phases:**

- **13.1 Fixture/reset:** Script seeded Mumbai static hospitals with attributed source and clearly labeled simulated availability; reset requests/offers/holds safely.
- **13.2 Runbook:** Document demo accounts, network/API prerequisites, fallback talk track, expected timestamps, and operator actions without exposing passwords in Git.
- **13.3 Final rehearsal:** Run full A reject/B timeout/C accept story, confirm metrics and no secrets/real patient data.

**Likely files/modules:** `supabase/seed.sql`, demo runbook, `README.md`, `memory.md`. **Database/backend work:** Safe demo reset/seed. **Frontend work:** Final copy and polish only. **Validation:** Two clean rehearsals from reset; all simulated data visibly marked. **Exit:** Demo is reproducible and limitations are stated. **Dependencies:** Phase 12.
