# BedLink Development Rules

These rules govern future Codex and human changes. Read `PRD.md`, `Architecture.md`, `design.md`, `Phases.md`, and `memory.md` before implementing a phase. If a requirement conflicts, stop the affected change, identify the conflict, and update the source documents together before coding.

## 1. General coding rules

Implement the named phase/sub-phase and preserve unrelated working behavior. Keep changes reviewable, small, and tied to acceptance criteria. Fix root causes instead of hiding errors. Do not fabricate successful backend responses or live availability.

## 2. Approved tech stack

Flutter/Dart; Riverpod; Supabase Auth, PostgreSQL, Realtime, Edge Functions, Cron; `geolocator`; `maplibre_gl`; MapTiler tiles; OpenRouteService Matrix and Directions; GitHub. PostgreSQL **tables**, never “collections.” A stack replacement needs an explicit architecture decision.

## 3. Approved libraries

Core candidates: `flutter_riverpod`, `supabase_flutter`, `geolocator`, `maplibre_gl`, and `shared_preferences` for non-sensitive recovery pointers. `flutter_test` is the default unit/widget test tool. Use only the package versions compatible with the chosen Flutter SDK, verified from official package/API documentation and `pubspec.yaml` at implementation time. Add a focused dependency only when a concrete requirement cannot be met with this list or the SDK.

## 4. Libraries to avoid

Do not add a second state-management system, a second database/backend SDK, Firebase, Google Maps, Hive/Isar for this small pointer cache, heavy animation/UI kits, or generated networking frameworks without a documented need. No direct ORS client in Flutter.

## 5. Architecture rules

Flow: UI -> Riverpod controller -> repository/service -> Supabase/Edge Function. PostgreSQL is authoritative; Edge Functions orchestrate; transaction SQL owns inventory and workflow state transitions. No business logic in widgets. No long-running function waits for an offer deadline.

## 6. Flutter rules

Use feature-first folders in `Architecture.md`. Keep screens responsive at 320dp width and 200% text scaling. Render loading/error/empty/offline states explicitly. Dispose map/subscriptions/controllers. Do not block rendering on map tiles for critical information.

## 7. Dart rules

Enable strict analysis/lints. Use typed immutable models, explicit nullable fields, exhaustive state handling, UTC timestamps, and validated JSON parsing. Avoid `dynamic` past serialization boundaries and avoid force-unwrapping untrusted server fields. Use meaningful names matching canonical database values.

## 8. Riverpod rules

Providers manage session, repositories, current request, hospital inbox, and route. Controllers coordinate UI intents and invalidate/refetch snapshots; they do not calculate authoritative ranking, expiry, or holds. Scope subscriptions and avoid duplicate listeners after navigation/resume.

## 9. Supabase rules

Use migrations for all schema/RLS/function changes. Never edit production schema only in the dashboard. Verify Auth JWT in Edge Functions. Do not use service-role access as a shortcut to skip ownership checks. Fetch authoritative state after reconnect and after Realtime subscription setup.

## 10. PostgreSQL rules

Use UUID internal keys, UTC `timestamptz`, foreign keys, checks, partial unique indexes, and constraints from `Architecture.md`. Keep resource codes, role values, and lifecycle strings canonical. Use a transaction/RPC for multi-table transitions. Keep SQL functions narrowly scoped and review execution privileges/search paths. A quick availability update invalidates the old occupancy/load breakdown until explicitly reconciled. No implicit inventory math in client code.

## 11. Realtime rules

Realtime is an update signal, not durable state. Apply authorized subscriptions only. Fetch a snapshot after connection/reconnection and ignore stale versions. If Realtime drops, display connection status and recover via fetch; never assume silence means no state change.

## 12. Edge Function rules

Functions validate identity, role, associations, inputs, and idempotency. Return stable error codes and correlation IDs. Use bounded external calls and retries. Call transactional database functions for state changes. The scheduled recovery function must be idempotent and batch bounded.

## 13. MapLibre rules

Use `maplibre_gl` with MapTiler styles/tiles. Route geometry comes from server-proxied OpenRouteService Directions. Show textual destination, ETA, and distance outside the map. Handle missing tiles without blocking arrival/confirmation screens.

## 14. OpenRouteService rules

ORS API key stays server-side. Matrix supplies actual road ETA for ranking; Directions supplies the accepted route. Use `[longitude, latitude]` as ORS coordinate order. Validate null/unreachable results and quotas. Never call straight-line distance a road ETA or invent a route on API failure.

## 15. Authentication rules

Supabase Auth user UUID is identity. A 10-digit numeric hospital/ambulance ID is a display/login reference, not the password or primary key. Demo accounts use distinct generated passwords. Always derive role and association from the authenticated profile, not client body fields. Session expiry returns to login without erasing a recoverable request pointer.

## 16. RLS rules

Enable RLS on all app tables, default deny, and explicitly test hospital-vs-hospital and ambulance-vs-ambulance isolation. Deny direct client mutation of offer/reservation/hold/lifecycle fields. Prefer invoker functions. Security-definer functions must live in a non-exposed schema, validate caller, set empty `search_path`, and schema-qualify objects. Never disable RLS to make a feature work.

## 17. Secrets and environment rules

Never commit credentials, service-role keys, ORS keys, tokens, or patient data. Public Supabase URL/publishable key and constrained MapTiler client key may be supplied by build config; they are not authorization. Server secrets use Supabase secret management/Vault. Examples contain names/placeholders only.

## 18. Offline state rules

Persist only non-sensitive `active_request_id`, ambulance reference, reservation ID, and last shown state with `shared_preferences`. Mark cached state unverified. After reconnect, refresh session and fetch authoritative snapshot. Retried submission uses an idempotency key; do not create duplicate requests when acknowledgment was lost. Server workflow continues regardless of client network.

## 19. Error handling rules

Use typed error codes and user-safe messages. Show actionable retry/escalation states for GPS permission, location failure, auth/session/role failure, no candidates, stale data, ORS/tiles/Supabase outage, invalid response, capacity race, cancellation, and exhausted offers. Never silently swallow an exception or show a hold before transaction commit.

## 20. API failure handling

Set request timeouts and bounded retries with backoff for idempotent reads/external routing. Avoid automatic retries of non-idempotent writes without a key. On ORS failure, leave discovery retryable and do not fabricate ETA. On invalid server shape, log correlation ID and show a safe error state.

## 21. Network failure handling

Differentiate offline, timeout, and server rejection. Keep last known state visible with timestamp but unverified. Disable mutation actions until connected and acknowledged. Reconcile on app resume and reconnect, including if no Realtime event arrived.

## 22. Timeout rules

Offer deadline is `expires_at = created_at + 120 seconds` on the server. Client timer is visual only. Accept RPC checks exact server time under lock. Cron/recovery sweeps expired offers and stranded requests; never rely on a Flutter timer to call fallback. Document sweep cadence and observed delay in tests.

## 23. Concurrency rules

Lock request/offer/inventory rows in stable order. Maintain one pending offer and one reservation per request with database constraints. Return current state on duplicate operations. Test simultaneous last-unit acceptance, accept-vs-timeout, cancel-vs-arrival, and repeat requests.

## 24. Reservation safety rules

Every request needs at least one countable resource. Multi-resource hold is all-or-nothing in one transaction. Recheck capabilities and counts at accept time. Never allow negative available/held counts. Release exactly once; arrival moves held to occupied exactly once. No direct client decrement, no partial hold, no success UI before committed reservation. Do not auto-expire an accepted en-route hold in the MVP.

## 25. Logging rules

Record request events and sanitized Edge Function correlation logs. Include state transition, reason code, elapsed time, and ORS status class. Exclude JWTs, passwords, keys, patient identifiers, and precise coordinates by default. Investigate errors; do not suppress them to make tests green.

## 26. Naming conventions

Database: `snake_case` tables/columns and lowercase state strings. Dart: `UpperCamelCase` types, `lowerCamelCase` members, `snake_case.dart` files. Resource codes: `general_bed`, `emergency_bed`, `icu_bed`, `ventilator`, `oxygen_bed`, `pediatric_icu_bed`. Capability codes: `cardiac_care`, `trauma_care`, `burns_care`, `pediatric_icu_care`. Use these exact values in schema, API, models, seeds, and docs.

## 27. File size and separation rules

Keep one clear responsibility per file and avoid giant screens/functions. Extract repeated UI controls and pure mapping/scoring helpers when it improves readability. Do not split a small cohesive feature into empty layers. Keep migrations additive and ordered.

## 28. UI/UX rules

Follow `design.md`: calm clinical palette, large controls, visible freshness, ETA, resource counts, offer status, and clear error text. Red is for expiry/destructive/critical warnings, not every primary action. Count changes and acceptance require an acknowledged server result. Avoid dense forms and decorative effects.

## 29. Accessibility rules

At least 48x48dp interactive targets, meaningful semantics, 14sp minimum body text, 200% text scaling, status text plus color/icon, strong contrast, logical focus order, and reduced motion. Verify at 320dp width and outdoors-oriented light theme.

## 30. Testing rules

After Flutter changes run `flutter analyze` and relevant `flutter test` suites; report if toolchain unavailable. After schema changes run migration validation and SQL/RLS tests with at least two hospitals and ambulances. After Edge changes run function unit/integration tests and failure-path checks. Required workflow tests: filter, ranking determinism, 120-second deadline, rejection/timeout fallback, exhausted candidates, atomic multi-item hold, last-unit race, cancellation/release, offline snapshot recovery, and authorization isolation. Test meaningful behavior rather than duplicating implementation internals. Do not claim unrun tests passed.

## 31. Git rules

Use focused commits/PRs on a `codex/` branch unless project direction changes. Do not commit generated secrets, local `.env`, vendor folders, or unrelated formatting. Review `git diff` and test output before committing. Update docs and `memory.md` with consequential architecture decisions.

## 32. AI agent behavior rules

- Never invent APIs or dependency behavior; verify official docs/current installed versions when implementing.
- Never assume a package exists without checking `pubspec.yaml`.
- Never silently replace the approved stack or add unnecessary libraries.
- Never bypass RLS, implement reservations only in Flutter, or make client time authoritative.
- Never put mock/demo data in production paths unless explicitly permitted and visibly labeled.
- Never claim public datasets provide real-time availability without verification.
- Never suppress errors, fabricate backend success, or rewrite unrelated files for a scoped task.
- Preserve functioning features, implement one named phase at a time, run relevant analysis/tests, and summarize limitations honestly.
- Update `memory.md` after a meaningful milestone with current phase, verified tests, active issues, and next action; keep it concise rather than a running transcript.
