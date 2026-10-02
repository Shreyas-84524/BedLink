# BedLink Product Requirements Document

> Right bed. Right hospital. Right now.

Status: implementation specification for the Mumbai hackathon MVP. Read with `Architecture.md`, `rules.md`, `Phases.md`, `design.md`, and `memory.md`. Where this document describes user behavior, `Architecture.md` defines the server contract.

## 1. Product overview

BedLink coordinates an ambulance crew and a hospital for a time-sensitive transfer. It filters hospitals by mandatory clinical capability and currently available resources, compares road travel time, asks one hospital at a time to accept, atomically holds the requested resources, and guides the ambulance to the accepting hospital. BedLink is decision support, not medical advice or a dispatch authority. Crews retain clinical judgment and established emergency escalation channels.

## 2. Problem statement

The nearest hospital may lack a required specialty, bed, ventilator, or willingness to receive the patient. Availability may be old, and a phone call or rejected request can cost critical minutes. The product must make compatibility, information age, road ETA, acceptance, and hold status visible in one flow.

## 3. Vision

Shorten the time from “we need a suitable hospital” to “a compatible hospital has accepted and a resource is held.”

## 4. Goals

1. Let hospital staff update a displayed resource count in about 10 seconds and confirm unchanged data in one action.
2. Show ambulance crews only clinically compatible, currently feasible ranked candidates, with ETA and availability age.
3. Give each offered hospital 120 seconds from server `created_at`; advance automatically after rejection or expiry.
4. Prevent two requests from holding the same last unit of a resource.
5. Preserve the coordination workflow if an ambulance app disconnects and reconcile it on return.
6. Provide a route to the accepted hospital and a clear arrival action.

## 5. Non-goals

Diagnosis, treatment recommendation, medical records, billing, insurance, full hospital inventory, ambulance fleet dispatch, guaranteed traffic prediction, and replacing official emergency communications are outside the MVP.

## 6. Target users

- Hospital operators and nurses who report critical resource availability and respond to offers.
- Ambulance crews who specify mandatory requirements, monitor acceptance, navigate, and confirm arrival.

## 7. User roles

`hospital_staff` is bound to one hospital; `ambulance_crew` is bound to one ambulance. `admin` is reserved for controlled setup and monitoring, with no admin app required for the MVP. A dispatcher may use a crew account during a demo but is not a separate authorization role.

## 8. Core user stories

| Actor | Story | Observable result |
|---|---|---|
| Hospital staff | Adjust an ICU count with large controls | New effective availability and update time appear after server confirmation |
| Hospital staff | Confirm counts have not changed | All relevant resource freshness times refresh without changing quantities |
| Hospital staff | Review an incoming request | Mandatory needs, ETA, server deadline, and Accept/Reject appear |
| Ambulance crew | Request ICU + ventilator + cardiac care | Hospitals missing any mandatory item are excluded |
| Ambulance crew | Lose signal during an offer | Backend advances offers and holds resources; app catches up on reconnect |
| Ambulance crew | Receive acceptance | Hospital, held items, ETA, route, and arrival action appear |

## 9. Complete MVP feature set

Secure role login; seeded Mumbai hospital directory; hospital capability and resource reporting; freshness labels; location capture; mandatory requirements; configurable radius expansion; OpenRouteService Matrix ETA; deterministic ranking; server-owned sequential offers; 120-second response deadline; automatic fallback; atomic multi-resource hold; Supabase Realtime updates; local active-request pointer; reconnect fetch; MapLibre route from OpenRouteService Directions with MapTiler tiles; arrival and cancellation flows; accessible failure and empty states. Static directory data is curated separately from live BedLink-reported counts.

## 10. Hospital-side requirements

- Dashboard shows hospital name, six countable resource types, capability badges, last confirmed time, incoming offer, and active holds. Countable types: `general_bed`, `emergency_bed`, `icu_bed`, `ventilator`, `oxygen_bed`, `pediatric_icu_bed`.
- `cardiac_care`, `trauma_care`, and `burns_care` are static capability flags. Pediatric ICU is both an explicit capability and a countable resource; both must be true/available for a mandatory pediatric ICU request.
- One tap on `+`/`-` proposes a count change; only a successful server response updates authoritative quantity. Prevent negative values and changes that consume already held capacity. A quick change makes previously reported occupancy/unavailable breakdown unknown, so load becomes “unavailable” until staff explicitly reconcile it. Provide a compact reconciliation action for total/occupied/unavailable counts.
- “Confirm no change” refreshes the hospital's active resource freshness timestamps after server validation; it never changes counts or capability.
- Incoming offer includes mandatory requirements, estimated arrival, deadline, and explicit Accept/Reject. A late Accept receives “Offer expired” and cannot create a hold.
- Active holds show request, quantities, state, arrival ETA, and a release/cancel outcome.

## 11. Ambulance-side requirements

- Crew can initiate one active request per ambulance, choose at least one mandatory countable resource and any additional mandatory capabilities, view/confirm captured GPS coordinates, and submit. Urgency is a simple display field (`routine`, `urgent`, `critical`), not a medical triage algorithm.
- Show ranked suitable hospitals with road ETA, matching resource counts, capability, freshness in minutes, and load when known. The default action starts automatic sequential offers in ranked order; the crew does not need to manually contact each candidate.
- Show current offered hospital, remaining time as an indicative countdown, prior rejection/timeout, and automatic next-hospital progress.
- On confirmation show held items, hospital details, reservation ID, and route. Allow arrival confirmation and cancellation; explain that cancellation releases active holds.
- On return from offline/app restart, recover from locally stored request ID and fetch the full current server state before showing a final status.

## 12. Authentication requirements

Supabase Auth is the authority. Every user has a profile with a role and a hospital or ambulance association enforced by RLS and server checks. Provision demo accounts with unique 10-digit numeric **display IDs** and distinct generated passwords; the display ID is not the Auth user primary key and must not equal the password. Any simplified credential handout is demo-only and must never be described as production security. Sessions are refreshed through Supabase Auth; expired or invalid sessions route to login without losing the local active-request pointer.

## 13. Hospital discovery requirements

Start with a configurable 5 km radius, then 10 and 15 km, up to a configurable safe maximum (MVP default 30 km), stopping when at least five suitable candidates are found or the maximum is reached. Straight-line distance is only a coarse radius prefilter. Do not let an expansion step bypass mandatory filtering or freshness labeling. Bound the Matrix call to a configurable shortlist and expose a retry state if routing fails.

## 14. Resource filtering requirements

Each selected requirement is mandatory. Countable requirements need effective `available_count >= requested_quantity` and supported capability where applicable. Care capabilities require an enabled capability row. Exclude unavailable or inactive hospitals. If a count is unknown, treat it as unavailable. Never show a partially compatible hospital as an eligible offer; a separate explanatory no-match view may identify why none qualified.

## 15. Hospital ranking requirements

Use deterministic, documented scoring after hard filters. Reference weights: clinical/resource match 40%, road ETA 25%, freshness 15%, spare capacity 10%, load 10%. Clinical score measures optional margin/extra matching only; all mandatory requirements have already passed. Missing load receives a conservative neutral score and “Load unavailable.” Tie-break by shorter ETA, fresher data, then stable hospital ID. Weights and thresholds are server configuration, not hardcoded UI behavior. This is decision support, not medical AI. Record score inputs and rank for reproducibility.

## 16. Data freshness requirements

Show age from server `last_confirmed_at` for every count used in the result. The card displays the oldest relevant required-resource timestamp and can show per-resource ages in details. Buckets are `[0,5)` fresh, `[5,15)` recent, `[15,30)` aging, and `>=30` stale minutes; unknown is “Not reported.” Stale entries are visibly marked and penalized. For MVP, stale data can be considered for discovery but an offer requires fresh enough data under a configurable hard maximum (default 30 minutes); otherwise the hospital is excluded from automatic offering. A confirmation refreshes timestamps but cannot override an unavailable resource.

## 17. Two-minute offer requirements

One pending offer per emergency request. Server sets `expires_at = created_at + 120 seconds`. Both roles see status and deadline. The on-screen countdown is advisory; server time determines acceptance. Offer state values are `pending`, `accepted`, `rejected`, `timed_out`.

## 18. Accept/reject requirements

Only staff assigned to the offered hospital may respond. Acceptance atomically verifies the offer is pending and unexpired, checks every required resource again, creates reservation and reservation items, increments held/decrements available, marks offer accepted, and confirms the request. Rejection records an optional reason and immediately advances the request. Duplicate responses are idempotent or return the already settled state.

## 19. Timeout requirements

A server scheduler scans expired offers at least every 10 seconds for the demo configuration; the processing delay is shown honestly if infrastructure is slow. It atomically marks an expired pending offer `timed_out`, then advances to the next candidate. Late acceptance fails. Recovery scans also find stranded `searching`/`offering` requests after a function crash. Client disconnects have no effect on expiry.

## 20. Automatic fallback requirements

The server offers candidates in persisted rank order, never repeating a settled candidate. It advances on rejection, timeout, or resource race during acceptance. If none remain, request becomes `no_match` with a cause such as `all_rejected`, `all_timed_out`, `capacity_lost`, or `no_candidates`. Notify connected users via Realtime; disconnected clients discover the latest state by fetch.

## 21. Reservation/hold requirements

One reservation per confirmed request with one item per countable resource. Hold quantity is normally one per selected countable requirement unless the request explicitly specifies more. Creation is a single PostgreSQL transaction and locks affected inventory rows in stable order. `available_count` decreases and `held_count` increases. On cancellation/release, reverse exactly once. On arrival, the hold moves to occupied capacity in the same transaction; the reservation becomes `arrived`. Staff then manage completion. An unaccepted offer never reserves capacity. MVP does not auto-expire an accepted hold while the ambulance is en route; manual release/cancellation is explicit.

## 22. Realtime requirements

While connected, subscribe only to authorized request, offer, reservation, and relevant hospital inventory changes. Realtime is a signal to fetch/merge authoritative state; duplicate/out-of-order events must not regress the UI. Re-query after subscription setup and on reconnect. The backend never waits for a subscriber to continue.

## 23. Offline/reconnect requirements

Persist `active_request_id`, `ambulance_id` display reference, last known state, and reservation ID in `shared_preferences` (non-sensitive pointers only). Do not store patient details or credentials there. A request submission needs server acknowledgment before it is shown as active; if acknowledgment is lost, retry with an idempotency key and fetch by that key before creating another. Offline screens show cached status as potentially outdated and disable irreversible actions. Reconnect performs an authenticated state fetch and replaces the cache.

## 24. Map and routing requirements

Use `geolocator` for GPS with permission rationale and retry. Use OpenRouteService Matrix via Edge Function to compare road duration. After acceptance, use Directions via Edge Function for route geometry, distance, and duration; draw it with `maplibre_gl` and MapTiler tiles. Map is supplemental: text destination, address, ETA, and a retry state remain visible if tiles fail. Do not claim traffic-aware or turn-by-turn navigation unless actually provided.

## 25. Error and empty states

| Condition | Required behavior |
|---|---|
| GPS denied/unavailable | Explain permission or accuracy issue; allow retry and safe manual coordinate entry for demo, visibly labeled |
| No network/Supabase unavailable | Show last known status as unverified; keep server-owned workflow; retry fetch on return |
| Realtime disconnected | Show connection badge and poll/fetch current state on reconnection |
| Matrix/Directions unavailable | Do not invent ETA or route; retry, and keep confirmed destination/address visible |
| Map tiles unavailable | Keep text route summary/destination and a map retry action |
| No nearby/clinically compatible hospital | Distinct reasons; allow radius retry or requirement review, never silently relax mandatory criteria |
| All rejected/all timed out | End as `no_match` with reason; provide retry/new request and emergency escalation copy |
| Resource lost/reservation race | Reject acceptance atomically, record reason, advance to next candidate |
| Stale data | Label age; exclude beyond offer threshold; invite hospital to reconfirm |
| Auth/session/role failure | Deny mutation, prompt re-login or show access denied; preserve request pointer |
| Invalid response/cancellation | Fail closed, show retry or current server state; cancel only after confirmed server result |

## 26. Security requirements

All writes require authenticated identity, role binding, RLS, and server-side validation. Service role and OpenRouteService secrets stay on the server. No direct client writes to offers, reservations, or inventory hold fields. Rate-limit submission/response endpoints and validate coordinate, quantity, enum, and ownership inputs. Log security-relevant failures without secrets.

## 27. Data privacy requirements

MVP stores urgency, selected requirements, coordinates, ambulance identity, status, and event times; it does not require patient name, Aadhaar, phone, or medical history. Limit precise location to authorized active workflow participants and delete or coarsen old request location data under a retention policy decided before real deployment. Demo data must be clearly identified as simulated availability.

## 28. Performance requirements

Targets under demo connectivity, measured at p95: hospital count update acknowledgment <= 2 seconds; request creation to first offer <= 10 seconds when routing works; accepted response to ambulance confirmed state <= 3 seconds while connected; reconnect state fetch <= 5 seconds. Timeout sweep runs at least every 10 seconds; expiry decision uses exact server timestamp. Display progress and retry when targets are missed. These are targets, not guaranteed clinical service levels.

## 29. Accessibility and cheap-phone requirements

Minimum 48x48 logical-pixel touch targets; body text at least 14sp, critical numbers at least 18sp; legible light theme in sunlight; high-contrast semantic labels and icons; never convey status by color alone. Support text scaling to 200%, screen reader labels, keyboard focus where available, reduced motion, small 320dp widths, and low-memory Android devices. Avoid elaborate animation and heavy map rendering on list screens.

## 30. MVP acceptance criteria

1. Hospital staff signs in and changes/recertifies a count; ambulance sees the server-confirmed value and age.
2. ICU + ventilator + cardiac requirement excludes a hospital lacking any one of them.
3. Search expands configured radii, uses Matrix road ETA, and persists the ranked candidate order.
4. Exactly one pending offer exists per request; a late acceptance fails after its 120-second server deadline.
5. Rejection and timeout advance without an ambulance action; all exhausted candidates yield `no_match`.
6. Concurrent acceptance/requests for one final ICU unit produce at most one active hold; no negative availability.
7. An ambulance offline during fallback reconnects to the accepted hospital and correct reservation.
8. Confirmed request shows a Directions route or a truthful routing error with destination details; arrival updates request, reservation, and inventory consistently.
9. Hospital A cannot view or change Hospital B's private offers or inventory; crew cannot mutate a reservation directly.
10. The complete demo can run with seeded, clearly labeled simulated dynamic availability without claiming live public availability.

## 31. Out-of-scope features

Admin UI, clinical diagnosis, patient records, dispatch optimization, integrated calls/SMS, automatic external hospital data import, payment, inventory beyond listed resources, background GPS tracking, and guaranteed navigation guidance.

## 32. Future enhancements

Verified provider integrations, richer specialty catalog, push notifications, hospital onboarding, detailed occupancy by ward, accessibility field testing, multilingual UI, operational monitoring, and clinically governed ranking evaluation. Any real-world deployment requires hospital agreements, data governance, and operational safety review.
