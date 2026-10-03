# Human Intervention Log — Phase 13

**Date:** 2026-10-03  
**Phase:** 13 — Real Location + Hospital Discovery Integration  
**Status:** ZERO EXTERNAL SECRETS REQUIRED  

---

## 1. External Credentials / API Keys

- **No external API keys are required for Phase 13.**
  - GPS positioning uses the device's native hardware sensors via `geolocator`.
  - Supabase connectivity uses the existing `config/supabase.json` configured in Phase 11.
  - OpenRouteService and MapTiler keys belong strictly to **Phase 14** and are NOT needed in Phase 13.

---

## 2. Runtime Location Permission Behavior

When launching BedLink on a physical device, emulator, or browser:

### Android Device / Emulator
1. Upon triggering hospital discovery, Android will present the runtime dialog:  
   *"Allow BedLink to access this device's location?"*
2. Select **"While using the app"** or **"Only this time"**.
3. If denied or if location services are disabled, BedLink automatically and safely falls back to Central Mumbai reference coordinates (`18.9980°N, 72.8300°E`) without crashing.

### Web Browser
1. The browser will present a prompt:  
   *"localhost wants to know your location"*.
2. Click **"Allow"** to enable real browser geolocation.
3. If blocked or running headless, the application seamlessly defaults to Central Mumbai reference coordinates.

---

## 3. Testing Real Discovery Against Supabase

To run the application with live Supabase configuration:

```powershell
.\scripts\run.ps1
```

Or run release web build:

```powershell
.\scripts\build-web.ps1
```
