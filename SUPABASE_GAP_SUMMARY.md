# BEDLINK SUPABASE READINESS

### Project:
`BedLink` (`segutgypwupqjktrxztz`, Region: `ap-south-1`) — Organization: Syntax Slayers (`eiqvmdzxonzuvbzzzupi`)

---

### Phase 11:
**25% ready**  
Missing:
- User profiles table (`profiles`) linked to `auth.users`
- Role assignment system (`ambulance_crew` vs `hospital_staff`)
- Ambulance registry table (`ambulances`)
- Seed demo user accounts in `auth.users`
- Row-Level Security (RLS) policies on `hospitals`, `profiles`, and `ambulances`
- Unique 10-digit human display identifier column (`display_id char(10)`) on hospitals and ambulances

---

### Phase 12:
**5% ready**  
Missing:
- Normalized aggregate resource table (`hospital_resources`) supporting 6 countable clinical types
- Normalized capabilities table (`hospital_capabilities`)
- Incoming hospital dispatch/offers table (`hospital_offers`)
- Server-authoritative 120-second offer timeout state machine
- Reservation and bed-hold tables (`reservations`, `reservation_items`)
- Atomic capacity hold and release PostgreSQL RPCs (`SELECT FOR UPDATE`)
- Audit trail event logging table (`request_events`)
- Supabase Realtime publication configuration (`supabase_realtime`)

---

### Phase 13:
**20% ready**  
Missing:
- Dynamic discovery and candidate persistence table (`request_candidates`)
- PostGIS extension or composite B-tree spatial index on `hospitals(latitude, longitude)`
- Hospital discovery and radius expansion Edge Function (`find-and-offer`)
- Standardized emergency request requirement payload serialization

---

### Phase 14:
**0% ready**  
Missing:
- Server-proxied OpenRouteService routing Edge Function (`get-route`)
- Server-side ORS API secret management in Supabase Vault / Environment
- Matrix road ETA calculation backend pipeline
- Route geometry cache table

---

### Phase 15:
**0% ready**  
Missing:
- Scheduled workflow recovery and timeout sweeper Edge Function / cron worker (`recover-workflows`)
- Bed arrival confirmation RPC (`confirm_arrival` moving `held_count` -> `occupied_count`)
- End-to-end multi-role live stress test suite against cloud backend

---

### Tables Reusable As-Is:
- `public.hospitals` (245 real Mumbai hospital facilities; 224 with verified GPS coordinates, ward numbers, and simulated availability flags. Minor schema extension needed for `display_id` and `directory_updated_at`).

---

### Tables Requiring Changes:
- `public.beds` (Currently implements an individual 1-row-per-bed slot model for only 3 types; needs replacement or transformation into `hospital_resources` aggregate inventory counters).
- `public.ambulance_requests` (Prototype incident record with 1 test row; needs replacement by canonical `emergency_requests` with full 9-state lifecycle).

---

### Missing Tables:
- `public.profiles`
- `public.ambulances`
- `public.hospital_capabilities`
- `public.hospital_resources`
- `public.emergency_requests`
- `public.emergency_request_requirements`
- `public.request_candidates`
- `public.hospital_offers`
- `public.reservations`
- `public.reservation_items`
- `public.request_events`

---

### Security Concerns:
- **Default Deny Lockout:** RLS is enabled on all public tables, but zero policies exist. All client requests are currently rejected. Explicit SELECT/INSERT/UPDATE policies must be applied prior to Flutter client integration.
- **Concurrency & Race Conditions:** Zero server-side transactional RPCs currently exist. Direct client-side updates to bed inventory would introduce severe race conditions and double-booking bugs.

---

### Recommended First Action:
Author the Phase 11 PostgreSQL foundation migration: add `display_id` to `hospitals`, create `profiles` and `ambulances` tables, establish strict RLS policies, and seed demo accounts in `auth.users` for Ambulance Crew and Hospital Staff.
