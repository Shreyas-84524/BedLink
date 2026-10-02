# BedLink Project Memory

Operational memory for future Codex work. Read the five specification files before implementation. Update this file after meaningful milestones; keep current facts and next action, not a giant changelog.

## Project identity

BedLink — “Right bed. Right hospital. Right now.” Mumbai hackathon MVP for ambulance-to-hospital coordination. It is decision support, not diagnosis or an official dispatch replacement.

## Current product definition

Hospital staff report six countable resources and three care capabilities plus pediatric ICU capability; ambulance crew submits at least one mandatory countable resource, optional additional mandatory capabilities, and GPS; server filters, obtains road ETA, ranks, offers sequentially for 120 seconds each, atomically holds all required countable resources, and supports route and arrival. Offline ambulance apps reconcile from server on return. See `PRD.md`.

## Approved technology stack

Flutter/Dart, Riverpod, Supabase Auth/PostgreSQL/Realtime/Edge Functions/Cron, `geolocator`, `maplibre_gl`, MapTiler, OpenRouteService Matrix/Directions, `shared_preferences` for non-sensitive recovery pointers, GitHub. No application dependencies are installed yet.

## Core architecture decisions

Flutter owns UI and local pointers; PostgreSQL owns truth and atomic state; Edge Functions own authenticated orchestration and ORS proxy; Cron sweeps expiries and stranded work; Realtime signals connected clients to fetch authoritative snapshots. No client-owned timeout, fallback, or inventory decrement. See `Architecture.md`.

## Current database decisions

Planned tables: `profiles`, `hospitals`, `hospital_capabilities`, `hospital_resources`, `ambulances`, `emergency_requests`, `emergency_request_requirements`, `request_candidates`, `hospital_offers`, `reservations`, `reservation_items`, `request_events`. UUID internal keys; unique 10-digit numeric display IDs. Six countable codes: `general_bed`, `emergency_bed`, `icu_bed`, `ventilator`, `oxygen_bed`, `pediatric_icu_bed`. Capability codes: `cardiac_care`, `trauma_care`, `burns_care`, `pediatric_icu_care`. Availability and held counts are separate. No migrations exist yet.

## Current UI decisions

Calm light clinical theme with teal primary, restrained red warnings, Roboto bundled/system font, >=48dp touch targets, >=14sp body text, 320dp/200% text support, visible freshness/ETA/hold status. See `design.md`.

## Current workflow decisions

Request states: `created`, `searching`, `offering`, `confirmed`, `en_route`, `arrived`, `completed`, `no_match`, `cancelled`. Offer states: `pending`, `accepted`, `rejected`, `timed_out`. Reservation states: `accepted`, `en_route`, `arrived`, `completed`, `released`. Offer deadline is exactly 120 server seconds; scheduled sweep targets 10-second cadence if supported by project config. Accepted hold has no automatic MVP expiry. Ranking weights are 40/25/15/10/10 after hard filtering. Search radii default to 5, 10, 15, 20, 30 km; minimum target five compatible hospitals; max 20 Matrix candidates. All values are configurable server-side.

## Completed work

Documentation foundation only: `PRD.md`, `Architecture.md`, `rules.md`, `Phases.md`, `design.md`, `memory.md`. Existing `README.md` was read as background and left unchanged. No application code, migration, dependency install, or live backend setup has been completed.

## Current phase

Planning / Documentation.

## Current sub-phase

Documentation generation.

## Current file being worked on

`memory.md`.

## Recently modified files

The six documentation files listed above.

## Last verified tests

Documentation review completed: section inventory, terminology search, Markdown fence check, Mermaid block check, and `git status` against the six requested files. No Flutter/backend tests are applicable yet.

## Known issues

No implemented system exists. Public Mumbai directory rows, credentials, MapTiler/ORS/Supabase project configuration, and actual device performance remain unverified. Existing `README.md` contains older option language (for example Google Maps/Hive/Isar) and should be aligned when implementation starts; the six new specification files are the implementation source of truth.

## Pending decisions

- Select and verify static Mumbai hospital records and attribution before seeding.
- Confirm Supabase project plan/config supports the desired 10-second Cron sweep; exact deadline validation is independent of sweep frequency.
- Choose retention period for precise location and request-event data before any real-world deployment.
- Establish operational escalation wording with intended demo/clinical partners before a real pilot.

## Next recommended task

Implement Phase 0.1 from `Phases.md` (Flutter project and reproducible toolchain setup), then proceed sub-phase by sub-phase. Do not start production implementation as part of this documentation task.

## Do not forget

Use Supabase Auth as identity; display ID is not a password. Use PostgreSQL tables and RLS. Do not claim public data is live availability. ORS key stays server-side. Hard-filter mandatory clinical needs. Recheck every resource and deadline in a transaction on accept. Reconcile state after reconnect. Update this memory after each meaningful milestone with current phase/sub-phase, affected files, exact tests run, open issue, and next action; remove stale entries rather than appending a long diary.
