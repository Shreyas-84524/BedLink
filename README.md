# BedLink

> **Right bed. Right hospital. Right now.**

BedLink is a real-time emergency bed coordination platform designed to help ambulance crews identify the most suitable hospital for a critical patient, confirm that the required resource is actually available, and temporarily hold that resource before arrival.

Instead of routing an ambulance to the nearest hospital only by distance, BedLink considers the patient's clinical requirements, live bed availability, estimated travel time, data freshness, and current hospital load.

---

## Problem Statement

An ambulance crew carrying a critical patient needs the nearest hospital that has the **right resource available right now**.

The required resource may include:

- ICU bed
- Ventilator
- Oxygen-supported bed
- General emergency bed
- Cardiac care
- Trauma care
- Burns care
- Pediatric ICU

In real-world emergency situations, the nearest hospital may not be the correct hospital.

A hospital may:

- Have no ICU bed available
- Have no ventilator
- Not support the required specialty
- Be operating at very high load
- Have availability information that has not been updated recently
- Reject the incoming patient after the ambulance has already started moving toward it

BedLink aims to solve this coordination gap.

---

## Solution Overview

BedLink has three core parts:

### 1. Hospital Bed Update System

Hospital staff get a minimal, mobile-first interface that allows them to update critical resource availability within approximately **10 seconds**.

Each resource can be updated using large `-` and `+` controls.

Example:

```text
ICU Beds
[ - ]    04    [ + ]

Ventilators
[ - ]    02    [ + ]

Oxygen Beds
[ - ]    08    [ + ]

Updated just now
```

Hospital staff can also press:

```text
CONFIRM NO CHANGE
```

to refresh the data timestamp without manually editing every resource.

---

### 2. Ambulance Hospital Matching

The ambulance crew provides:

- Current GPS location
- Required bed/resource
- Required specialty
- Patient urgency

BedLink filters incompatible hospitals and ranks suitable hospitals using:

- Clinical/resource match
- Estimated travel time
- Data freshness
- Available capacity
- Current hospital load

The system is designed to answer:

> **Which hospital can actually receive this patient fastest and most reliably right now?**

---

### 3. Confirm-and-Hold Workflow

Once the ambulance selects a hospital, BedLink sends an emergency request to that hospital.

The hospital gets approximately **2 minutes** to:

- Accept
- Reject

If accepted:

- The required resource is temporarily held
- The ambulance receives confirmation
- The hospital sees the ambulance as inbound
- Navigation can begin

If rejected or timed out:

- BedLink automatically forwards the request to the next-best ranked hospital
- The ambulance crew does not have to restart the search manually

---

# Core Workflow

```text
Ambulance creates emergency request
            |
            v
BedLink filters compatible hospitals
            |
            v
OpenRouteService calculates ETA
            |
            v
BedLink ranks hospitals
            |
            v
Request sent to Hospital A
            |
       +----+----+
       |         |
    ACCEPT     REJECT / TIMEOUT
       |         |
       v         v
 Create Hold   Hospital B
       |         |
       v         v
 Ambulance    Continue automatically
 Confirmed
       |
       v
 Navigation
       |
       v
 Arrival
```

---

# User Roles

BedLink MVP contains three roles.

## Hospital Staff

Responsible for:

- Updating available beds/resources
- Confirming unchanged availability
- Receiving emergency requests
- Accepting or rejecting requests
- Monitoring active bed holds
- Preparing for incoming ambulances

## Ambulance / Dispatcher

Responsible for:

- Entering patient requirements
- Sharing ambulance location
- Viewing ranked hospitals
- Requesting a bed
- Receiving confirmation
- Navigating to the accepted hospital
- Confirming arrival

## Admin

Responsible for:

- Managing hospitals
- Monitoring hospital freshness
- Monitoring active emergency requests
- Reviewing overall platform activity

Admin functionality is secondary for the hackathon MVP.

---

# MVP Screens

## Shared

### 1. Splash / App Entry

Checks the current login session and routes the user to the correct role-based dashboard.

### 2. Login

Authentication for:

- Hospital staff
- Ambulance/dispatcher
- Admin

---

## Hospital Screens

### 3. Hospital Bed Update Dashboard

The most important hospital screen.

Displays:

- ICU beds
- Ventilator availability
- Oxygen beds
- General emergency beds
- Cardiac care
- Trauma care
- Burns care
- Pediatric ICU

Hospital staff should be able to update counts using one-tap controls.

### 4. Quick Availability Confirmation

Allows staff to confirm that current availability remains unchanged.

This refreshes `last_updated_at`.

### 5. Incoming Emergency Request

Displays:

- Required resources
- Required specialty
- Ambulance ETA
- Request countdown
- Accept button
- Reject button

### 6. Accepted Request / Active Hold

Shows:

- Reservation ID
- Requested resource
- Ambulance identifier
- Current ETA
- Hold status

### 7. Active Holds

Lists resources currently reserved for inbound ambulances.

---

## Ambulance Screens

### 8. Dispatcher Home

Starting point for ambulance crews.

Main action:

```text
FIND HOSPITAL
```

### 9. Patient Requirements

Allows selection of:

- ICU
- Ventilator
- Oxygen
- Emergency bed
- Cardiac
- Trauma
- Burns
- Pediatric ICU

The ambulance GPS location is captured automatically where possible.

### 10. Matching / Searching

Shown while BedLink:

- Filters hospitals
- Checks availability
- Requests travel times
- Calculates rankings

### 11. Ranked Hospital Results

Shows hospitals ordered by suitability.

Each listing displays:

- Hospital name
- ETA
- Required-resource availability
- Specialty compatibility
- Hospital load
- Data age

Example:

```text
City Hospital

ETA: 8 min
ICU: 3 available
Ventilators: 2 available
Cardiac Care: Available
Load: Moderate

Updated 2 min ago

[ REQUEST BED ]
```

### 12. Hospital Details

Displays deeper hospital information before sending the request.

### 13. Request Pending

Displays:

- Selected hospital
- Request status
- 2-minute countdown

### 14. Automatic Fallback

Shown when the current hospital rejects or times out.

Example:

```text
Hospital A did not accept the request.

Automatically contacting Hospital B...
```

### 15. Bed Confirmed

Shows:

- Accepted hospital
- Held resource
- Reservation ID
- ETA
- Navigation button

### 16. Navigation / En Route

Shows:

- Route
- Distance
- ETA
- Hospital destination
- Bed-hold confirmation

### 17. Arrival Confirmation

Allows the ambulance to mark:

```text
ARRIVED
```

The held resource then moves into hospital-managed occupied status.

### 18. No Match Available

Shown if no hospital currently satisfies the emergency requirements.

Possible options:

- Retry
- Expand search radius
- Modify requirements
- Show partially compatible hospitals

---

# Critical Hospital Facilities in the MVP

For the initial version, BedLink focuses on approximately **8 critical resources/capabilities**:

1. ICU Beds
2. Ventilator Beds
3. Oxygen Beds
4. General Emergency Beds
5. Cardiac Care
6. Trauma Care
7. Burns Care
8. Pediatric ICU

These provide sufficient clinical diversity for the hackathon while keeping the hospital update interface simple.

---

# Hospital Availability vs Hospital Capability

BedLink separates hospital information into two categories.

## Static Capabilities

These usually do not change frequently:

- Cardiac care
- Trauma center
- Burns unit
- Pediatric intensive care
- Specialty services

## Dynamic Availability

These change frequently:

- ICU beds available
- Ventilators available
- Oxygen beds available
- Emergency beds available
- Held beds
- Current load

This prevents the system from treating a hospital with zero current beds as though it has lost its permanent clinical capabilities.

---

# Hospital Ranking Logic

BedLink should first apply **hard compatibility filters**.

For example:

```text
Patient requires:
ICU + Ventilator + Cardiac Care
```

A hospital without cardiac capability should normally be removed before ranking.

Compatible hospitals can then be scored using:

```text
Score =
Clinical Match
+ ETA
+ Data Freshness
+ Capacity
+ Hospital Load
```

A possible MVP weighting:

| Factor | Weight |
|---|---:|
| Clinical / Resource Match | 40% |
| Estimated Travel Time | 25% |
| Data Freshness | 15% |
| Available Capacity | 10% |
| Hospital Load | 10% |

The exact weights can be tuned later.

---

# Data Freshness

Every hospital listing must display how old its availability data is.

Example:

```text
Updated just now
Updated 4 min ago
Updated 13 min ago
Updated 31 min ago
```

Suggested freshness categories:

```text
0-5 min    Fresh
5-15 min   Recent
15-30 min  Aging
30+ min    Stale
```

Old information should reduce a hospital's ranking.

---

# Hospital Load

For the MVP, hospital load can be estimated as:

```text
Load = Occupied Operational Beds / Total Operational Beds
```

Suggested categories:

```text
0-60%     Low
60-85%    Moderate
85-100%   High
```

This can later be calculated per department or specialty.

---

# Bed / Resource Lifecycle

A resource should follow a controlled state lifecycle.

```text
AVAILABLE
   |
   v
REQUESTED
   |
   v
HELD
   |
   v
OCCUPIED
   |
   v
AVAILABLE
```

Additional transitions include:

```text
REQUESTED -> REJECTED
REQUESTED -> TIMED_OUT
HELD -> RELEASED
```

The server remains the authoritative source of truth.

---

# Offline and Poor-Network Handling

Emergency vehicles may temporarily enter poor-network or no-network areas.

BedLink is designed so that the hospital-selection workflow **does not depend on the ambulance remaining online**.

Example:

```text
Ambulance creates request
        |
        v
Server starts hospital-offer workflow
        |
        v
Ambulance loses network
        |
        X

Server continues independently:

Hospital A rejects
        |
        v
Hospital B receives request
        |
        v
Hospital B accepts
        |
        v
Bed hold created
```

When the ambulance reconnects:

```text
Flutter app detects connectivity
        |
        v
Reads locally stored activeRequestId
        |
        v
Fetches latest request state
        |
        v
Server responds:
CONFIRMED - Hospital B
```

---

# Realtime + REST Synchronization

BedLink uses a hybrid synchronization model.

## Realtime

While connected:

```text
Hospital Accepts
      |
      v
Supabase Realtime
      |
      v
Ambulance instantly receives confirmation
```

## REST / State Synchronization

REST is used for recovery after connectivity loss.

REST does **not** maintain a permanent connection.

When connectivity returns, the ambulance requests the latest server-side state.

Example:

```text
GET /emergency-requests/{requestId}
```

The server returns the authoritative current state.

Example response:

```json
{
  "requestId": "BL-9281",
  "status": "confirmed",
  "hospital": "City Hospital",
  "bedType": "ICU",
  "bedHeld": true
}
```

---

# Local Offline State

The Flutter application stores the active emergency request ID locally.

Example:

```text
activeRequestId = BL-9281
```

This allows the app to recover after:

- Network loss
- App restart
- Phone restart
- Temporary background suspension

Suggested local storage:

- Hive
- Isar
- SharedPreferences for very small state

---

# Request States

The overall emergency request can use:

```text
SEARCHING
OFFERED
CONFIRMED
EN_ROUTE
ARRIVED
FAILED
CANCELLED
```

Individual hospital offers can use:

```text
PENDING
ACCEPTED
REJECTED
TIMED_OUT
```

Example:

```text
Hospital A -> REJECTED
Hospital B -> TIMED_OUT
Hospital C -> ACCEPTED

Overall Emergency -> CONFIRMED
```

---

# Two-Minute Acceptance Logic

When a hospital receives an offer:

```text
created_at
expires_at
```

with:

```text
expires_at = created_at + 2 minutes
```

The Flutter UI may display a countdown, but the **server timestamp** determines whether the offer is still valid.

This prevents device-clock manipulation and ensures consistency.

---

# Automatic Hospital Fallback

Hospital fallback is controlled entirely by the backend.

```text
Hospital A
    |
    v
REJECT / TIMEOUT
    |
    v
Server selects next ranked hospital
    |
    v
Hospital B
    |
    v
ACCEPT
    |
    v
Create Hold
```

The ambulance does not need to remain online for this sequence to continue.

---

# Routing and ETA

BedLink uses **OpenRouteService** for routing.

## Stage 1 - Hospital Ranking

The **Matrix API** is used to calculate estimated travel times from the ambulance to multiple candidate hospitals.

Example:

```text
Ambulance
  |
  +-- Hospital A -> 7 min
  +-- Hospital B -> 11 min
  +-- Hospital C -> 5 min
  +-- Hospital D -> 16 min
```

These ETAs are used in the hospital ranking algorithm.

## Stage 2 - Navigation

Once a hospital accepts, the **Directions API** is used to obtain:

- Full road route
- Distance
- Travel duration
- Route geometry

The route can then be drawn on the Flutter map.

---

# Map Strategy

The MVP can use either:

### Option A

```text
Google Maps Flutter
+
OpenRouteService
```

Google Maps is used for map visualization.

OpenRouteService provides routing and ETA.

### Option B

```text
MapLibre
+
MapTiler
+
OpenRouteService
```

This provides a more open mapping stack.

For the hackathon, either option is valid.

---

# Recommended Technology Stack

## Frontend

- Flutter
- Dart

## State Management

- Riverpod

## Backend

- Supabase

## Database

- PostgreSQL via Supabase

## Authentication

- Supabase Auth

## Realtime Communication

- Supabase Realtime

## Server-Side Logic

- Supabase Edge Functions

## Local Offline Storage

- Hive or Isar

## Maps

- Google Maps Flutter  
  **or**
- MapLibre + MapTiler

## Routing / ETA

- OpenRouteService

## GPS

- Flutter `geolocator`

## Version Control

- GitHub

---

# High-Level Architecture

```text
                    BEDLINK
                       |
        +--------------+--------------+
        |                             |
        v                             v
Hospital Flutter App          Ambulance Flutter App
        |                             |
        +--------------+--------------+
                       |
                       v
                   Supabase
          +------------+------------+
          |            |            |
          v            v            v
        Auth       PostgreSQL     Realtime
                       |
                       v
                Edge Functions
                       |
          +------------+------------+
          |                         |
          v                         v
 OpenRouteService              Map Provider
 Routing / ETA               Maps / Tiles
```

---

# Suggested Backend Tables

```text
profiles
hospitals
hospital_capabilities
bed_inventory
ambulances
emergency_requests
hospital_offers
bed_holds
request_events
```

---

# Example Hospital Table

```text
id
name
address
ward
latitude
longitude
load_level
last_updated_at
```

---

# Example Bed Inventory Table

```text
id
hospital_id
bed_type
total
available
held
occupied
updated_at
```

---

# Example Hospital Capabilities

```text
hospital_id
cardiac
trauma
burns
pediatric_icu
```

---

# Mumbai Hospital Dataset Strategy

For the Mumbai MVP, hospital information can be sourced from publicly available datasets such as:

- BMC / MCGM hospital information
- OpenCity Mumbai hospital datasets
- Government of India National Hospital Directory
- ABDM Health Facility Registry
- OpenStreetMap for missing geographic coordinates

These sources provide **static hospital information**.

BedLink itself manages dynamic information such as:

- ICU availability
- Ventilator availability
- Oxygen availability
- Resource holds
- Current load
- Last update time

---

# Suggested Hospital Dataset Fields

```text
hospital_id
name
address
ward
latitude
longitude
hospital_type

icu_beds
ventilator_beds
oxygen_beds
emergency_beds

cardiac
trauma
burns
pediatric_icu

current_load
last_updated_at
```

---

# Server-Side Safety

Critical bed operations should never be trusted directly to the client.

For example, the client should not perform:

```text
availableBeds = availableBeds - 1
```

Instead:

```text
Flutter
   |
   v
Supabase Edge Function
   |
   v
Database Transaction
   |
   +-- Check available > 0
   +-- Create bed hold
   +-- Decrease available
   +-- Increase held
```

This helps prevent:

- Double booking
- Race conditions
- Invalid reservations
- Concurrent update conflicts

---

# Data Privacy

The MVP should avoid collecting unnecessary patient-identifying information.

The hospital primarily needs:

- Patient urgency
- Required bed/resource
- Required specialty
- Ambulance identifier
- ETA

Avoid storing unless genuinely necessary:

- Patient name
- Aadhaar
- Detailed medical history
- Personal contact information

---

# MVP Development Priority

The recommended build order is:

### Phase 1 - Foundation

- Flutter project
- Supabase integration
- Authentication
- Role-based navigation

### Phase 2 - Hospital Availability

- Bed update dashboard
- Data freshness
- Realtime synchronization

### Phase 3 - Ambulance Matching

- Patient requirement form
- Hospital filtering
- OpenRouteService Matrix integration
- Ranking engine

### Phase 4 - Confirmation Workflow

- Hospital request
- Two-minute countdown
- Accept
- Reject
- Timeout
- Automatic fallback

### Phase 5 - Bed Hold

- Transaction-safe reservation
- Active holds
- Confirmation to ambulance

### Phase 6 - Offline Recovery

- Local request persistence
- Reconnect synchronization
- Server-authoritative state recovery

### Phase 7 - Navigation

- Accepted-hospital route
- ETA
- Arrival confirmation

### Phase 8 - Demo Polish

- Loading states
- Error states
- Empty states
- Responsive phone UI
- Demo hospital dataset

---

# Hackathon Demo Scenario

A strong demo can follow this sequence.

### Step 1

Hospital A reports:

```text
ICU: 1
Ventilator: 1
Updated 22 min ago
```

Hospital B reports:

```text
ICU: 2
Ventilator: 2
Updated 1 min ago
```

### Step 2

Ambulance creates an emergency request:

```text
Critical Cardiac Patient
Requires ICU + Ventilator
```

### Step 3

BedLink checks:

- Capability
- Resource availability
- Travel time
- Freshness
- Load

Hospital B ranks above Hospital A even if Hospital A is geographically closer.

### Step 4

Hospital B receives the emergency request.

### Step 5

Hospital B rejects.

BedLink automatically forwards the request.

### Step 6

Hospital A accepts.

### Step 7

The ICU bed is held.

### Step 8

The ambulance receives:

```text
BED CONFIRMED
Hospital A
ICU + Ventilator
ETA: 7 min
```

### Step 9

Navigation begins.

### Step 10

Ambulance arrives and confirms arrival.

This demonstrates the complete BedLink value proposition in one workflow.

---

# Key Differentiators

## 1. Clinical Matching

BedLink does not simply find the closest hospital.

It finds a hospital that can actually handle the patient.

## 2. Live Availability

Hospitals can update availability in seconds.

## 3. Data Freshness

Every hospital listing shows how old its information is.

## 4. ETA-Aware Ranking

Hospital ranking uses actual estimated travel time.

## 5. Confirm Before Routing

The ambulance can obtain hospital acceptance before committing to the destination.

## 6. Bed Hold

An accepted resource is temporarily held for the incoming ambulance.

## 7. Automatic Fallback

Rejected or timed-out requests automatically move to the next hospital.

## 8. Offline-Tolerant Workflow

The backend continues working even if the ambulance temporarily loses connectivity.

---

# Future Enhancements

Possible post-MVP features include:

- SMS fallback when mobile data is unavailable but cellular service exists
- Hospital response reliability scoring
- Availability confidence score
- Traffic-aware routing
- Ambulance fleet management
- Government control room dashboard
- Hospital performance analytics
- Emergency department-specific load
- Automatic stale-data reminders
- Multi-city rollout
- Integration with government hospital systems
- Integration with emergency helplines
- Predictive bed-demand analytics

---

# Project Vision

BedLink aims to reduce the time between:

```text
"We need a hospital."
```

and:

```text
"A suitable bed is confirmed and waiting."
```

The system focuses not just on discovering hospitals, but on coordinating the complete emergency handoff between ambulance crews and hospitals.

---

## One-Line Pitch

> **BedLink is a real-time emergency bed coordination network that finds the right hospital, confirms the required resource, and holds it before the ambulance arrives.**

---

## Tagline

> **Right bed. Right hospital. Right now.**
