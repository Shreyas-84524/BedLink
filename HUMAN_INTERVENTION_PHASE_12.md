# HUMAN INTERVENTION REQUIRED — PHASE 12

**Project:** BedLink (`segutgypwupqjktrxztz`)  
**Phase:** Phase 12 — Bed Availability & Live Inventory Synchronization  
**Status:** Code Complete & Tested (Ready for Database Policy Activation)

---

## ACTION 1: Read-Only RLS Policy on `public.beds`

### Required:
**YES** *(Only needed for live cloud PostgREST reads; without it, BedLink gracefully falls back to cached fixtures without crashing)*

### What:
Apply a read-only Row-Level Security (RLS) SELECT policy on `public.beds` in the Supabase SQL Editor.

### Why:
During the Supabase audit, it was verified that:
1. `public.beds` has `rowsecurity = true`.
2. There are currently zero (0) policies configured in `pg_policies`.
3. Under PostgreSQL security semantics, 0 policies enforces an unconditional **default-deny** filter on all non-admin client queries.
4. Consequently, PostgREST queries return `HTTP 200 OK` with an empty array `[]`.

### Exact backend area:
- **Schema:** `public`
- **Table:** `beds`

### Destructive:
**NO** *(This is a pure read permission grant; zero table structures, triggers, or existing rows are altered or deleted)*

### Safest option:
Execute the following non-destructive SQL statement in the [Supabase SQL Editor](https://supabase.com/dashboard/project/segutgypwupqjktrxztz/sql):

```sql
-- Allow anonymous and authenticated users to read hospital bed slots
CREATE POLICY "Allow public read access to beds"
ON public.beds
FOR SELECT
TO anon, authenticated
USING (true);
```

### When needed:
Execute when ready to allow the Flutter frontend to query live bed slots from Supabase `public.beds`.

---

## ACTION 2: Real Database Bed Mutations (Deferred)

### Required:
**NO** *(Deferred by design in Phase 12)*

### Details:
In accordance with Section 23 of the Phase 12 specification, direct writes to `public.beds` remain handled by the local compatibility layer (`MockBedInventoryMutationRepository`). No database write policies or triggers were modified or requested in this phase to prevent data corruption or race conditions.
