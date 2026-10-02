# HUMAN INTERVENTION REQUIRED FOR LIVE SUPABASE ENVIRONMENT (PHASE 11)

**Project:** BedLink (`segutgypwupqjktrxztz`)  
**Phase:** Phase 11 — Supabase Connection + Existing Hospital Directory Integration  
**Status:** Code Complete & Tested (Ready for Live Configuration)

---

## 1. Overview & Context

In accordance with the **Strict Backend Read-Only Rule** and **Mandatory Configuration Handoff Rule** for Phase 11:
- The codebase was developed with zero hardcoded credentials, full mock fallback capability, and resilient error translation.
- No changes, table modifications, or RLS policies were created in the Supabase database by the AI agent.
- To run the application against the live Supabase database rather than the built-in mock fallback, two external configuration items and one administrative database policy approval are required from the project administrator.

---

## 2. Required Values

### 1. `SUPABASE_URL`
- **Description:** The unique API URL for the BedLink Supabase project.
- **Reference Project:** `segutgypwupqjktrxztz` (Region: `ap-south-1`)
- **Default Format:** `https://segutgypwupqjktrxztz.supabase.co`
- **Where to obtain:** 
  1. Open [Supabase Dashboard](https://supabase.com/dashboard)
  2. Select organization **Syntax Slayers** -> Project **BedLink** (`segutgypwupqjktrxztz`)
  3. Navigate to **Project Settings** (gear icon) -> **API** -> **Project URL**

### 2. `SUPABASE_ANON_KEY` / PUBLISHABLE KEY
- **Description:** The anonymous public API key used by client applications to interact with Supabase through PostgREST and Realtime.
- **Security Note:** This is a public key intended for client-side usage; it respects Row-Level Security (RLS) policies. **DO NOT** use or provide the `service_role` secret!
- **Where to obtain:**
  1. Open [Supabase Dashboard](https://supabase.com/dashboard)
  2. Select organization **Syntax Slayers** -> Project **BedLink** (`segutgypwupqjktrxztz`)
  3. Navigate to **Project Settings** -> **API** -> **Project API Keys**
  4. Copy the key labeled `anon` `public`

---

## 3. How to Pass These Values at Build / Runtime

BedLink uses Flutter's compile-time environment flags (`--dart-define`) to avoid leaking credentials into source code, files, or Git history.

### Running with Live Supabase:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://segutgypwupqjktrxztz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<YOUR_ANON_PUBLIC_KEY> \
  --dart-define=APP_MODE=supabase
```

### Building Web Release with Live Supabase:
```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://segutgypwupqjktrxztz.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<YOUR_ANON_PUBLIC_KEY> \
  --dart-define=APP_MODE=supabase
```

### Running in Mock Mode (Default Fallback):
If omitted or `APP_MODE=mock` is passed, the app automatically runs against the verified in-memory mock repository without errors:
```bash
flutter run
```

---

## 4. Required Supabase SQL Approval (RLS Policy)

During the Pre-Phase-11 Read-Only Audit, we verified that:
1. `public.hospitals` has Row-Level Security (RLS) enabled.
2. There are **zero (0)** RLS policies configured on `public.hospitals`.
3. Under PostgreSQL RLS rules, 0 policies means **default deny** for all `anon` and `authenticated` roles.

### Behavior in BedLink Frontend:
The BedLink application detects this permission error gracefully (`42501` / `PGRST301`) and sets `isRlsBlock = true`. It displays a non-disruptive banner notifying the operator that RLS is blocking direct client queries and falls back to safe cached directory items without crashing.

### Administrative SQL to Enable Read Access:
To permit Flutter clients to query active hospitals directly via the anon key, run the following SQL statement in the [Supabase SQL Editor](https://supabase.com/dashboard/project/segutgypwupqjktrxztz/sql):

```sql
-- Allow anonymous and authenticated users to read active hospital directory entries
CREATE POLICY "Allow public read access to active hospitals"
ON public.hospitals
FOR SELECT
TO anon, authenticated
USING (is_active = true);
```

> **Verification:** Once executed, queries to `supabase.from('hospitals').select('*').eq('is_active', true)` will successfully return the 245 Mumbai hospital records.

---

## 5. Summary Checklist

- [ ] Obtain `anon` public key from Supabase Dashboard
- [ ] Run client with `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...`
- [ ] Execute `Allow public read access to active hospitals` SELECT policy in Supabase SQL Editor
- [ ] Verify live directory shows 245 hospitals with Mumbai coordinates in Hospital Discovery screen
