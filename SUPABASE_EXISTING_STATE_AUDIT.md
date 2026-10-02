# BedLink — Supabase Existing State Read-Only Audit

**Project:** BedLink — Real-Time Emergency Hospital Coordination Platform  
**Target Project:** `BedLink` (`segutgypwupqjktrxztz`)  
**Organization:** Syntax Slayers (`eiqvmdzxonzuvbzzzupi`)  
**Audit Mode:** **100% READ-ONLY AUDIT (Zero Mutations Performed)**  
**Date:** October 2, 2026  
**Auditor:** Antigravity AI Assistant  

---

## 1. Executive Summary

Prior to initiating Phase 11 ("Supabase Authentication & Core Data Integration"), a comprehensive, read-only audit of the connected Supabase cloud infrastructure was performed. The objective is to establish an exact baseline of what backend assets already exist, evaluate their structural compatibility with the authoritative BedLink architecture (`Resources/Architecture.md`, `Resources/PRD.md`, `Resources/rules.md`), determine what can be reused as-is versus what requires refactoring or migration, and quantify readiness across Phases 11 through 15.

### Key Discoveries:
1. **High-Value Master Asset Discovered:** The Supabase database contains a fully populated master directory table `public.hospitals` with **245 real Mumbai hospitals** (including major municipal facilities like KEM Hospital, ENT Hospital, and private facilities like Wockhardt Hospital). 224 of these records possess verified Mumbai GPS coordinates (`18.91°N` to `19.25°N`, `72.81°E` to `73.00°E`), municipal ward classifications, bed counts, and an explicit `availability_is_simulated = true` flag adhering to BedLink development rule 15.
2. **Prototype Bed Slot Model vs. Aggregate Resource Pool Mismatch:** The current `public.beds` table contains 1,191 individual physical bed slots categorized into only three types (`emergency`, `general`, `ICU`). This differs fundamentally from BedLink's target schema, which requires aggregate integer resource pools (`hospital_resources`) supporting six countable clinical types (`general_bed`, `emergency_bed`, `icu_bed`, `ventilator`, `oxygen_bed`, `pediatric_icu_bed`) with atomic hold counters (`available_count`, `held_count`, `occupied_count`, `unavailable_count`) and freshness tracking (`last_confirmed_at`).
3. **Empty Identity, Role & Workflow Infrastructure:** There are zero registered users in `auth.users`, no `profiles` table, no `ambulances` master table, no `hospital_offers` table, no `reservations` table, no `request_events` audit table, no PostgreSQL RPCs or triggers, zero deployed Supabase Edge Functions, and zero publication tables in Supabase Realtime.
4. **Row-Level Security (RLS) State — Default Deny:** RLS is enabled (`rowsecurity = true`) on all three existing public tables (`hospitals`, `beds`, `ambulance_requests`), but **zero policies** exist in `pg_policies`. As a consequence, all non-admin client requests (from `anon` or `authenticated` roles) are unconditionally denied by PostgreSQL.

---

## 2. Supabase Project Overview

| Property | Value | Security / Verification Note |
| :--- | :--- | :--- |
| **Organization Name** | Syntax Slayers | Verified via Supabase Management API |
| **Organization ID** | `eiqvmdzxonzuvbzzzupi` | Org slug matching project owner |
| **Project Name** | BedLink | Confirmed dedicated BedLink project |
| **Project Reference ID** | `segutgypwupqjktrxztz` | Canonical project identifier |
| **Region** | `ap-south-1` (Mumbai, India) | Colocated with Mumbai fleet and hospital targets |
| **Database Host** | `db.segutgypwupqjktrxztz.supabase.co` | Managed PostgreSQL cluster |
| **PostgreSQL Version** | `17.11` (GA release channel) | `PostgreSQL 17.11 on aarch64-unknown-linux-gnu` |
| **Project Status** | `ACTIVE_HEALTHY` | Provisioned 2026-10-02T04:37:06.629Z |
| **Public URL** | `https://segutgypwupqjktrxztz.supabase.co` | Publishable client gateway |
| **Credentials & Secrets** | **REDACTED / SECURED** | Zero service-role keys, DB passwords, or JWT secrets revealed |

---

## 3. Auth Overview

An inspection of the Supabase GoTrue authentication subsystem was conducted:

| Auth Component | Current State | Details |
| :--- | :--- | :--- |
| **User Count (`auth.users`)** | `0` | No users currently exist in the authentication registry. |
| **Identities (`auth.identities`)** | `0` | No identity records. |
| **Auth Providers** | Default Email/Password | Standard GoTrue email provider enabled. No third-party OAuth or SAML configured. |
| **SSO Providers (`auth.sso_providers`)** | `0` | No enterprise SSO or SAML configurations present. |
| **Demo / Seed Users** | `None` | Seed test users for Ambulance Crew and Hospital Staff have not yet been provisioned. |
| **User-to-Profile Triggers** | `None` | No PostgreSQL trigger exists on `auth.users` to automatically synchronize profiles on user registration. |
| **Linkage to Application Entities** | `None` | Complete lack of foreign key links between authentication and domain models. |

---

## 4. Database Schema Inventory

The database contains one primary application schema: `public`. System schemas present include `auth`, `extensions`, `realtime`, `storage`, and `vault`.

### 4.1 Schema Inventory (`public`)

There are currently **three tables** in the `public` schema:

```text
public/
  ├── hospitals          (245 rows) - Mumbai Hospital Directory
  ├── beds               (1,191 rows) - Individual Bed Slots
  └── ambulance_requests (1 row) - Prototype Incident Record
```

#### Table Detail: `public.hospitals`
- **Inferred Purpose:** Master directory of Mumbai healthcare facilities.
- **Row Count:** 245
- **Columns:**
  - `id` (`uuid`, NOT NULL, DEFAULT `gen_random_uuid()`, PRIMARY KEY `hospitals_pkey`)
  - `name` (`varchar`, NOT NULL)
  - `address` (`text`, NOT NULL)
  - `latitude` (`numeric`, NULLABLE) — 224 populated, 21 NULL
  - `longitude` (`numeric`, NULLABLE) — 224 populated, 21 NULL
  - `hospital_load` (`integer`, NULLABLE, DEFAULT `0`)
  - `facilities` (`jsonb`, NULLABLE, DEFAULT `'[]'::jsonb`) — Contains string arrays e.g. `["Trauma Care", "Emergency", "ICU"]`
  - `is_active` (`boolean`, NULLABLE, DEFAULT `true`)
  - `created_at` (`timestamptz`, NULLABLE, DEFAULT `now()`)
  - `ward_name` (`text`, NULLABLE) — Municipal administrative ward (e.g., `A`, `E`, `F/S`, `K/W`)
  - `hospital_type` (`text`, NULLABLE) — `Private` (190), `Municipal` (33), `Government`/`Govt` (16), `Trust` (2), `BMC` (1), `Defence` (1), `NULL` (2)
  - `total_beds` (`integer`, NULLABLE) — Range: 1 to 2,250 beds; mean: 116 beds; 4 records NULL
  - `contact` (`text`, NULLABLE) — Phone/landline contacts
  - `availability_is_simulated` (`boolean`, NOT NULL, DEFAULT `true`)
- **Constraints:**
  - PK: `hospitals_pkey` (`id`)
  - Check: `hospitals_total_beds_check` (`CHECK (total_beds IS NULL OR total_beds >= 0)`)
- **Indexes:** Primary key index `hospitals_pkey` only. Zero spatial or b-tree coordinate indexes.
- **RLS:** `rowsecurity = true`, 0 policies.

#### Table Detail: `public.beds`
- **Inferred Purpose:** Prototype tracking of individual physical beds within hospitals.
- **Row Count:** 1,191
- **Columns:**
  - `id` (`uuid`, NOT NULL, DEFAULT `gen_random_uuid()`, PRIMARY KEY `beds_pkey`)
  - `hospital_id` (`uuid`, NOT NULL, FK `beds_hospital_id_fkey` -> `hospitals(id)` ON DELETE CASCADE)
  - `bed_type` (`varchar`, NOT NULL) — Distinct values: `'emergency'` (238), `'general'` (479), `'ICU'` (474)
  - `status` (`varchar`, NOT NULL, DEFAULT `'available'::varchar`) — Distinct values: `'available'` (373), `'occupied'` (376), `'reserved'` (442)
  - `updated_at` (`timestamptz`, NOT NULL, DEFAULT `now()`)
- **Constraints:**
  - PK: `beds_pkey` (`id`)
  - FK: `beds_hospital_id_fkey` (`hospital_id` REFERENCES `hospitals(id)` ON DELETE CASCADE)
  - Check: `beds_status_check` (`CHECK (status IN ('available', 'reserved', 'occupied'))`)
- **Indexes:** Primary key index `beds_pkey` only. Missing FK index on `hospital_id`.
- **RLS:** `rowsecurity = true`, 0 policies.

#### Table Detail: `public.ambulance_requests`
- **Inferred Purpose:** Prototype record for an emergency transfer request.
- **Row Count:** 1
- **Columns:**
  - `id` (`uuid`, NOT NULL, DEFAULT `gen_random_uuid()`, PRIMARY KEY `ambulance_requests_pkey`)
  - `ambulance_id` (`varchar`, NOT NULL) — Unvalidated string identifier (e.g. `'AMB001'`)
  - `bed_type` (`varchar`, NOT NULL) — Single requested bed type string (e.g. `'general'`)
  - `required_facilities` (`jsonb`, NULLABLE, DEFAULT `'[]'::jsonb`)
  - `latitude` (`numeric`, NOT NULL) — Request GPS latitude (e.g. `19.0760000`)
  - `longitude` (`numeric`, NOT NULL) — Request GPS longitude (e.g. `72.8777000`)
  - `status` (`varchar`, NOT NULL, DEFAULT `'pending'::varchar`)
  - `created_at` (`timestamptz`, NOT NULL, DEFAULT `now()`)
- **Constraints:**
  - PK: `ambulance_requests_pkey` (`id`)
  - Check: `ambulance_requests_status_check` (`CHECK (status IN ('pending', 'matched', 'completed', 'cancelled'))`)
- **Indexes:** Primary key index `ambulance_requests_pkey` only.
- **RLS:** `rowsecurity = true`, 0 policies.

---

## 5. BedLink Entity Mapping

Comparison between the target BedLink backend schema (`Architecture.md` §30) and the existing Supabase database:

| BedLink Target Entity | Existing Supabase Table | Match Quality | Technical & Architectural Notes |
| :--- | :--- | :--- | :--- |
| `profiles` | *(None)* | **MISSING** | No user profile table exists. Must be created in Phase 11 linking `auth.users(id)` to roles and organizations. |
| `hospitals` | `public.hospitals` | **MOSTLY USABLE** | High-quality master directory with 245 Mumbai hospitals. Needs addition of `display_id char(10) UNIQUE` and `directory_updated_at`. |
| `hospital_capabilities` | Embedded in `hospitals.facilities` | **PARTIAL** | Unstructured JSONB array (`facilities`) on `hospitals`. Lacks normalization, timestamps, and missing core capabilities (`cardiac_care`, `burns_care`, `pediatric_icu_care`). |
| `hospital_resources` | `public.beds` | **INCOMPATIBLE** | Current `beds` table tracks individual bed slots (1 row = 1 bed) across only 3 types. Target architecture requires normalized aggregate counter pools (`available_count`, `held_count`, `occupied_count`, `unavailable_count`, `last_confirmed_at`) across 6 countable types. |
| `ambulances` | *(None)* | **MISSING** | No vehicle or crew identity registry. `ambulance_requests` currently uses raw freeform strings. Must be created in Phase 11. |
| `emergency_requests` | `public.ambulance_requests` | **PARTIAL** | Prototype table exists with 1 row, but lacks user foreign keys (`created_by`), `idempotency_key`, `urgency`, `failure_reason`, `version`, and uses non-canonical status enum values. |
| `emergency_request_requirements` | *(None)* | **MISSING** | Target multi-resource requirements table is absent. Requests currently store only a single string `bed_type`. |
| `request_candidates` | *(None)* | **MISSING** | No persistence table for ranked candidate lists generated by the discovery engine. |
| `hospital_offers` | *(None)* | **MISSING** | Critical dispatch table missing. No 120-second timeout tracking, candidate rank, or offer progression state machine. |
| `reservations` | *(None)* | **MISSING** | No bed hold reservation table, arrival timestamps, or release tracking. |
| `reservation_items` | *(None)* | **MISSING** | Multi-resource hold breakdown table missing. |
| `request_events` | *(None)* | **MISSING** | Complete absence of audit trail or event logging infrastructure. |

---

## 6. Profiles & Roles Audit

- **Profile Table:** Does not exist.
- **Role Modeling:** There is no role column or enum in the database.
- **Target Roles (`ambulance_crew`, `hospital_staff`, `admin`):** Not implemented.
- **Organizational Linkage:** There is no schema linking a user to a specific `hospital_id` or `ambulance_id`.
- **Display Identifiers:** The 10-digit human-friendly numeric display identifier (`display_id char(10)`) mandated by `PRD.md` §12 and `Architecture.md` §30 does not exist.
- **Phase 11 Reusability:** **0% reusable as-is.** The profiles table and role resolution mechanism must be designed and applied via a formal migration during Phase 11.

---

## 7. Auth Audit

- **GoTrue State:** Active and accessible via Supabase CLI and client API.
- **User Population:** 0 users in `auth.users`.
- **Sign-up & Authentication:** Standard email/password provider is operational.
- **Demo Accounts:** No demo credentials have been created in the database.
- **Security Check:** Zero credentials, passwords, or authentication secrets were stored in or exposed by the database.

---

## 8. Hospitals Audit

- **Table:** `public.hospitals` (245 records).
- **Geographic Coverage:** Verified Mumbai Metropolitan Region (MMR).
  - Minimum Latitude: `18.9105537` (South Mumbai / Colaba)
  - Maximum Latitude: `19.2493572` (Borivali / Dahisar)
  - Minimum Longitude: `72.8142780` (Western Coastal belt)
  - Maximum Longitude: `72.9960510` (Eastern Suburbs / Mulund / Thane border)
  - 224 hospitals (91.4%) possess high-precision GPS coordinates.
  - 21 hospitals (8.6%) have `NULL` coordinates (small private nursing homes).
- **Administrative Breakdown:**
  - 24 administrative municipal wards represented (e.g., Ward A, C, D, E, F/N, F/S, G/N, H/E, K/W, P/S).
- **Capacity Range:** Total bed counts range from 1 to 2,250 beds (KEM Hospital). Mean: 116 beds.
- **Simulation Flag:** `availability_is_simulated = true` across all 245 records. This cleanly isolates test availability from real clinical operations.
- **Support for Clinical Categories:**
  - *ICU:* Mentioned in `facilities` JSONB (157 hospitals).
  - *Emergency / General:* Mentioned in `facilities` JSONB (169 hospitals).
  - *Trauma Care:* Mentioned in `facilities` JSONB (169 hospitals).
  - *Ventilator, Oxygen, Burns, Cardiac, Pediatric ICU:* **NOT represented** in the current table schema.

---

## 9. Hospital Resources Audit

- **Existing Structure:** Represented solely via `public.beds` (1,191 rows).
- **Modeling Strategy:** Individual bed slot model (each bed is an independent row with an `id`, `hospital_id`, `bed_type`, and `status`).
- **Shortcomings for BedLink Architecture:**
  1. *Resource Breadth:* Tracks only 3 types (`emergency`, `general`, `ICU`). Completely missing `ventilator`, `oxygen_bed`, and `pediatric_icu_bed`.
  2. *Concurrency & Lock Contention:* Reserving multiple beds requires selecting and updating multiple individual slot rows, which is vulnerable to deadlocks and race conditions compared to integer counter increments under row-level `SELECT FOR UPDATE` locks.
  3. *Invariants:* Does not track capacity breakdown (`total_capacity`, `available_count`, `held_count`, `occupied_count`, `unavailable_count`). Invariant `available + held + occupied <= total` cannot be enforced.
  4. *Freshness Tracking:* Has only `updated_at`. Lacks the critical `last_confirmed_at` timestamp required for staff "Confirm No Change" operations and freshness aging calculations.
- **Phase 12 Suitability:** **Incompatible.** Must be migrated to the normalized `hospital_resources` aggregate inventory model.

---

## 10. Capabilities Audit

- **Current Implementation:** Stored as an unindexed `jsonb` array column (`facilities`) inside `public.hospitals`.
- **Observed Values:** Exactly three string labels exist in the data: `"Trauma Care"`, `"Emergency"`, `"ICU"`.
- **Shortcomings:**
  - Non-relational JSONB querying prevents efficient SQL indexing and foreign key validation.
  - Missing mandatory clinical specialties defined in `PRD.md`: `cardiac_care`, `burns_care`, `pediatric_icu_care`.
  - No capability enable/disable flags or audit timestamps.
- **Recommended Action:** Create `hospital_capabilities` table (`hospital_id`, `capability_code`, `enabled`, `updated_at`), seed it by parsing the existing `facilities` JSONB data, and add the missing clinical capability flags.

---

## 11. Ambulance Audit

- **Existing Infrastructure:** No `ambulances` table exists.
- **Ad-hoc References:** `public.ambulance_requests` contains a raw string field `ambulance_id` (e.g. `'AMB001'`).
- **Telemetry / GPS:** Live vehicle coordinates are not stored in any table.
- **Phase 11 Suitability:** Missing. Must create `ambulances` table (`id uuid PK`, `display_id char(10) UNIQUE`, `label`, `is_active`) and establish proper foreign keys.

---

## 12. Emergency Requests Audit

- **Existing Table:** `public.ambulance_requests` (1 prototype record).
- **Lifecycle Status Enum:**
  - Allowed by current check constraint: `pending`, `matched`, `completed`, `cancelled`.
  - BedLink Canonical Target Lifecycle (`Architecture.md` §25): `created`, `searching`, `offering`, `confirmed`, `en_route`, `arrived`, `completed`, `no_match`, `cancelled`.
  - Gap: Missing 5 transition states; incorrectly uses `matched` instead of `confirmed`.
- **Missing Columns:**
  - `created_by` (FK -> `auth.users`)
  - `idempotency_key` (UUID per ambulance to prevent duplicate submissions)
  - `urgency` (`routine`, `urgent`, `critical`)
  - `failure_reason`
  - `version` (monotonic integer for optimistic concurrency)
  - `updated_at`

---

## 13. Request Requirements Audit

- **Current Structure:** Embedded inside `ambulance_requests` as a single `bed_type` varchar and `required_facilities` JSONB.
- **Architectural Requirement:** Normalized table `emergency_request_requirements(request_id, requirement_code, quantity, kind)` where `kind` is `resource` or `capability`.
- **Suitability:** Missing. Cannot represent compound clinical requirements (e.g. 1 ICU Bed + 1 Ventilator + Cardiac Care) in a normalized relational manner.

---

## 14. Hospital Offers Audit

- **Current Structure:** **Completely absent.**
- **Architectural Requirement:** `hospital_offers` table tracking `request_id`, `hospital_id`, `candidate_rank`, `status` (`pending`, `accepted`, `rejected`, `timed_out`), `created_at`, `expires_at`, `responded_at`, `reason_code`.
- **Critical Requirement:** Server-authoritative 120-second offer timeout and strict one-pending-offer partial unique constraint.
- **Readiness:** 0%. Must be implemented in Phase 12.

---

## 15. Reservations / Holds Audit

- **Current Structure:** **Completely absent.**
- **Architectural Requirement:** `reservations` table (`id`, `request_id UNIQUE`, `hospital_id`, `status`, `accepted_at`, `arrived_at`, `released_at`, `version`) and `reservation_items` table.
- **Concurrency & Double-Booking Protection:** None exists in the current database.
- **Readiness:** 0%. Must be implemented in Phase 12.

---

## 16. Request Events / Audit Trail

- **Current Structure:** **Completely absent.**
- **Architectural Requirement:** `request_events(id bigint PK, request_id, actor_user_id, event_type, from_status, to_status, reason_code, created_at)`.
- **Readiness:** 0%. Must be implemented in Phase 12.

---

## 17. Row-Level Security (RLS) Audit

| Table | RLS Enabled? | Number of Policies | Client Access (anon/auth) | Security Assessment |
| :--- | :--- | :--- | :--- | :--- |
| `public.hospitals` | **YES** | 0 | **BLOCKED (Default Deny)** | **NEEDS REVIEW / DEFECTIVE** — Fully secure against data leaks, but completely unreadable by client apps. |
| `public.beds` | **YES** | 0 | **BLOCKED (Default Deny)** | **NEEDS REVIEW / DEFECTIVE** — Unreadable and unwriteable by clients. |
| `public.ambulance_requests` | **YES** | 0 | **BLOCKED (Default Deny)** | **NEEDS REVIEW / DEFECTIVE** — Unreadable and unwriteable by clients. |

### RLS Findings:
- Zero permissive policies (`USING (true)`) exist.
- No privilege escalation vulnerabilities exist.
- However, because RLS is enabled with zero policies, **no Flutter client can query hospitals, beds, or requests** until appropriate SELECT/INSERT/UPDATE policies are defined.

---

## 18. Database Functions, Triggers & RPCs

- **User-Defined Functions (`public`):** 0 functions.
- **Triggers (`public`):** 0 triggers.
- **Security Definer Routines:** 0 routines.
- **Assessment:** All server-authoritative logic (atomic bed holds, offer settlement, timestamp updates, fallback progression) remains to be implemented.

---

## 19. Edge Functions Audit

- **Deployed Functions:** **0 functions deployed** (verified via `supabase functions list`).
- **Repository Source Code:** No Edge Function code files currently exist in the repository.
- **Target Functions Required (Phases 12–15):**
  - `update-hospital-resource`
  - `confirm-hospital-availability`
  - `create-emergency-request`
  - `find-and-offer`
  - `respond-to-offer`
  - `recover-workflows`
  - `get-route`

---

## 20. Realtime Configuration

- **Publication `supabase_realtime`:** Exists in PostgreSQL.
- **Published Tables:** **0 tables published** (`pg_publication_tables` is empty; `puballtables = false`).
- **Replica Identity:** Set to default (`d` - primary key) on all three public tables.
- **Assessment:** Realtime broadcasts and PostgreSQL change events are completely inactive. Realtime channels must be configured in Phase 12 for `hospital_offers`, `hospital_resources`, and `reservations`.

---

## 21. Storage Overview

- **Storage Buckets:** 0 buckets exist in `storage.buckets`.
- **Assessment:** BedLink's core MVP does not require object storage (patient records, scans, and attachments are non-goals). Current storage configuration is completely clean and requires no action.

---

## 22. PostGIS & Location Readiness

- **PostGIS Extension:** **NOT installed** in the database (`pg_extension` contains only `pg_stat_statements`, `pgcrypto`, `plpgsql`, `supabase_vault`, `uuid-ossp`).
- **Coordinate Storage:** Decimal coordinates stored as `numeric` in `public.hospitals` (`latitude`, `longitude`).
- **Spatial Indexes:** None.
- **Phase 13 Strategy:** As specified in `Architecture.md` §32:
  > *"A bounding-box index on latitude/longitude is sufficient for seeded Mumbai data; review query plans before adding PostGIS."*
  Because all 224 coordinate-equipped hospitals are confined to a compact ~40km bounding box in Mumbai, a composite B-tree index on `(latitude, longitude)` or PostGIS geography point indexing can easily satisfy discovery queries.

---

## 23. Existing Data Counts

| Table | Exact Row Count | Description / Notes |
| :--- | :--- | :--- |
| `public.hospitals` | **245** | Real Mumbai healthcare facilities; 224 with GPS, 21 null GPS; 100% simulated availability. |
| `public.beds` | **1,191** | Individual bed slot records (474 ICU, 479 general, 238 emergency). |
| `public.ambulance_requests` | **1** | Single prototype request record (`AMB001`, general bed, Bandra-Kurla coordinates). |
| `auth.users` | **0** | No registered user accounts. |
| `storage.buckets` | **0** | No buckets. |
| `vault.secrets` | **0** | No secrets. |

---

## 24. Foreign Key & Index Inventory

### Current Relationships:
```text
hospitals (id)
    ▲
    │ (CASCADE DELETE)
    └── beds (hospital_id)

ambulance_requests (isolated - no foreign keys)
```

### Missing Critical Indexes:
1. `beds(hospital_id)` — Foreign key index missing; causes sequential scans on deletes or joins.
2. `hospitals(latitude, longitude)` — Spatial/bounding-box lookup index missing.
3. `hospitals(display_id)` — Missing unique identifier index.
4. `ambulance_requests(ambulance_id, status)` — Lookup index missing.

---

## 25. Enums & State Models

- **Custom PostgreSQL Enums:** None. All statuses use `character varying` with `CHECK` constraints.
- **Bed Statuses:** `'available'`, `'reserved'`, `'occupied'`.
- **Ambulance Request Statuses:** `'pending'`, `'matched'`, `'completed'`, `'cancelled'`.
- **State Model Gaps:**
  - BedLink requires canonical statuses:
    - Requests: `created`, `searching`, `offering`, `confirmed`, `en_route`, `arrived`, `completed`, `no_match`, `cancelled`.
    - Offers: `pending`, `accepted`, `rejected`, `timed_out`.
    - Reservations: `accepted`, `en_route`, `arrived`, `completed`, `released`.

---

## 26. Legacy & Duplicate Structure Audit

- **`public.hospitals`:** **ACTIVE & PRIMARY ASSET.** High quality, real geographic dataset. Must be preserved and extended.
- **`public.beds`:** **LEGACY PROTOTYPE.** Uses individual slot model incompatible with aggregate capacity counters. Can be migrated to `hospital_resources` or retained as legacy alongside normalized tables.
- **`public.ambulance_requests`:** **LEGACY TEST ROW.** Single test row from early prototyping. Should be superseded by canonical `emergency_requests`.

---

## 27. Potentially Non-BedLink Objects — DO NOT TOUCH

An exhaustive scan across all database schemas was conducted to ensure no third-party or multi-tenant objects are inadvertently altered:
- **Application Schemas:** Only `public` exists.
- **Tables in `public`:** All 3 tables (`hospitals`, `beds`, `ambulance_requests`) are explicitly named for and belong to BedLink.
- **Other Schemas:** Standard Supabase system schemas (`auth`, `extensions`, `realtime`, `storage`, `vault`).
- **Conclusion:** There are **zero foreign or unrelated application tables** in this database. It is a dedicated BedLink project.

---

## 28. Phase Readiness Assessment

### Phase 11 — Supabase Authentication & Core Data Integration
- **Readiness: 25%**
- **Basis:**
  - `hospitals` table exists with 245 Mumbai facilities (valuable master data).
  - Missing: `profiles` table, `ambulances` table, `auth.users` seed accounts, RLS read/write policies, and `display_id` columns.

### Phase 12 — Supabase Realtime + Hospital Resources + Reservations
- **Readiness: 5%**
- **Basis:**
  - Prototype `beds` table exists but requires total re-architecture into `hospital_resources` integer pools.
  - Missing: `hospital_offers`, `reservations`, `reservation_items`, `request_events`, 120s timer triggers, atomic hold RPCs, and Realtime publications.

### Phase 13 — Location & Hospital Discovery API
- **Readiness: 20%**
- **Basis:**
  - 224 hospitals have real, verified Mumbai coordinates ready for discovery filtering.
  - Missing: `request_candidates` table, PostGIS / bounding-box indexes, and `find-and-offer` Edge Function.

### Phase 14 — MapLibre, MapTiler & OpenRouteService Backend Support
- **Readiness: 0%**
- **Basis:**
  - No routing proxy Edge Functions (`get-route`), no ORS matrix integration, no route geometry caching.

### Phase 15 — Complete Backend E2E, Offline Recovery & Release
- **Readiness: 0%**
- **Basis:**
  - No cron-based timeout/recovery workers (`recover-workflows`), no arrival reconciliation RPCs.

---

## 29. Gap Matrix

| Required Capability | Exists in DB? | Reusable As-Is? | Changes / Additions Needed | Target Phase |
| :--- | :--- | :--- | :--- | :--- |
| **Supabase Client Setup** | N/A (App) | No | Add `supabase_flutter`, configure URL/Anon key | Phase 11 |
| **Auth & GoTrue** | Yes | Partial | Provision demo crew and hospital staff accounts in `auth.users` | Phase 11 |
| **User Profiles** | No | No | Create `profiles` table with role and org FKs | Phase 11 |
| **Role Resolution** | No | No | Support `ambulance_crew` and `hospital_staff` via profiles | Phase 11 |
| **Ambulance Identity** | No | No | Create `ambulances` table (`display_id`, `label`, `is_active`) | Phase 11 |
| **Hospital Master Data** | Yes (245 rows) | **Yes** | Add `display_id char(10)` column and index | Phase 11 |
| **Hospital Capabilities** | Embedded JSONB | Partial | Normalize into `hospital_capabilities` table | Phase 11 / 12 |
| **Hospital Resources** | `beds` (Slots) | No | Create `hospital_resources` aggregate counter pools | Phase 12 |
| **Freshness Tracking** | No | No | Add `last_confirmed_at` and "Confirm No Change" RPC | Phase 12 |
| **Emergency Requests** | Prototype (1 row) | No | Create canonical `emergency_requests` with full lifecycle | Phase 12 / 13 |
| **Request Requirements** | Single string | No | Create `emergency_request_requirements` table | Phase 12 / 13 |
| **Hospital Offers** | No | No | Create `hospital_offers` with 120s server deadline | Phase 12 |
| **Bed Reservations** | No | No | Create `reservations` & `reservation_items` with atomic hold | Phase 12 |
| **Realtime Sync** | Disabled | No | Publish `hospital_resources`, `offers`, `reservations` | Phase 12 |
| **Event Audit Trail** | No | No | Create `request_events` table and trigger logging | Phase 12 |
| **Hospital Discovery** | No | No | Deploy `find-and-offer` Edge Function + B-tree/PostGIS index | Phase 13 |
| **ORS Routing Proxy** | No | No | Deploy `get-route` Edge Function with server-side secrets | Phase 14 |
| **Timeout Sweeper** | No | No | Deploy `recover-workflows` Edge Function or pg_cron worker | Phase 15 |
| **Arrival Handoff** | No | No | Create `confirm_arrival` RPC (held -> occupied) | Phase 15 |

---

## 30. Recommended Safe Implementation Order

To transition from the current database state to a fully integrated BedLink platform without data loss or downtime:

### Step 1: Phase 11 Backend Schema Foundation (Pre-requisite Migration)
1. **Preserve `hospitals`:** Keep the existing 245 hospital records intact. Add `display_id char(10) UNIQUE` and `directory_updated_at` columns.
2. **Create Core Identity Tables:**
   - Create `public.profiles` (`user_id -> auth.users`, `role`, `hospital_id`, `ambulance_id`, `display_id`).
   - Create `public.ambulances` (`id`, `display_id`, `label`, `is_active`).
3. **Provision Demo Users:** Seed demo Auth accounts for Ambulance Crew (`AMB-001` to `AMB-004`) and Hospital Staff (`HOSP-KEM`, `HOSP-WOCK`, etc.) with linked profiles.
4. **Establish Base RLS Policies:** Add strict, scoped `SELECT` policies for public hospital directories and role-isolated `profiles`/`ambulances` access.

### Step 2: Phase 11 Flutter Integration
1. Connect `supabase_flutter` with public URL and publishable key via `--dart-define`.
2. Implement `SupabaseAuthRepository`, `SupabaseHospitalRepository`, and `SupabaseAmbulanceRepository`.
3. Swap mock providers behind domain interfaces without touching frozen UI widgets.

### Step 3: Phase 12 Realtime, Resource & Reservation Schema
1. Create `hospital_resources` (6 countable types with aggregate capacity counters).
2. Create `hospital_capabilities` (4 clinical capability flags).
3. Create `emergency_requests`, `emergency_request_requirements`, `hospital_offers`, `reservations`, `reservation_items`, and `request_events`.
4. Implement PostgreSQL transactional RPCs (`create_bed_hold`, `respond_to_offer`, `update_hospital_resource`, `confirm_no_change`).
5. Add tables to `supabase_realtime` publication.

---

## 31. Identified Architectural Risks

1. **Missing Coordinate Outliers:** 21 of 245 hospitals currently have `NULL` latitude/longitude. Discovery queries using geographic distance filters will omit these facilities unless geocoded or filtered out gracefully.
2. **RLS Lockout Hazard:** Deploying client code before authoring explicit RLS policies will cause silent empty query results. RLS policies must precede Flutter client testing.
3. **Double-Booking Vulnerability:** If resource reservation is attempted via naive client-side PostgREST updates rather than atomic PostgreSQL row locks (`SELECT FOR UPDATE`), simultaneous requests will create negative bed inventory.

---

## 32. Final Audit Verdict

- **Audit Status:** **COMPLETED (100% READ-ONLY, ZERO MUTATIONS)**
- **Existing Asset Value:** **HIGH** (245 real Mumbai hospitals already seeded with GPS and ward data).
- **Backend Infrastructure Gap:** **SIGNIFICANT** (Auth users, profiles, resources, offers, reservations, RPCs, Edge Functions, and Realtime publications are completely unbuilt).
- **Proceed to Phase 11:** The database is in a clean, non-conflicting state ready for Phase 11 backend schema migration and client integration.
