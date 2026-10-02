---
name: Clinical Emergency & Critical Dispatch System
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#45464d'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#76777d'
  outline-variant: '#c6c6cd'
  surface-tint: '#565e74'
  primary: '#000000'
  on-primary: '#ffffff'
  primary-container: '#131b2e'
  on-primary-container: '#7c839b'
  inverse-primary: '#bec6e0'
  secondary: '#006a61'
  on-secondary: '#ffffff'
  secondary-container: '#86f2e4'
  on-secondary-container: '#006f66'
  tertiary: '#000000'
  on-tertiary: '#ffffff'
  tertiary-container: '#410002'
  on-tertiary-container: '#f63a35'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dae2fd'
  primary-fixed-dim: '#bec6e0'
  on-primary-fixed: '#131b2e'
  on-primary-fixed-variant: '#3f465c'
  secondary-fixed: '#89f5e7'
  secondary-fixed-dim: '#6bd8cb'
  on-secondary-fixed: '#00201d'
  on-secondary-fixed-variant: '#005049'
  tertiary-fixed: '#ffdad6'
  tertiary-fixed-dim: '#ffb4ab'
  on-tertiary-fixed: '#410002'
  on-tertiary-fixed-variant: '#93000b'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  headline-xl:
    fontFamily: Chivo
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.02em
  headline-xl-mobile:
    fontFamily: Chivo
    fontSize: 28px
    fontWeight: '800'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-lg:
    fontFamily: Chivo
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Chivo
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
    letterSpacing: 0em
  headline-md:
    fontFamily: Chivo
    fontSize: 22px
    fontWeight: '700'
    lineHeight: 28px
  headline-sm:
    fontFamily: Chivo
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Chivo
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Chivo
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Chivo
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 16px
  label-data-lg:
    fontFamily: JetBrains Mono
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 28px
  label-data-md:
    fontFamily: JetBrains Mono
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 20px
  label-data-sm:
    fontFamily: JetBrains Mono
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 16px
  label-badge:
    fontFamily: Chivo
    fontSize: 11px
    fontWeight: '800'
    lineHeight: 14px
    letterSpacing: 0.06em
rounded:
  sm: 0.125rem
  DEFAULT: 0.25rem
  md: 0.375rem
  lg: 0.5rem
  xl: 0.75rem
  full: 9999px
spacing:
  gutter: 1rem
  gutter-desktop: 1.5rem
  margin: 1rem
  margin-desktop: 2rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2.5rem
---

## Brand & Style

The design system is engineered for emergency operations centers, field paramedics operating inside high-vibration ambulances, and triage charge nurses managing real-time critical bed allocations. The core design ethos is **High-Stress Operational Clarity**: visual hierarchy must be instantly parsable in sub-second glances, under direct sunlight, or under harsh fluorescent hospital lighting. 

The aesthetic is functional, clinical, and unapologetically utilitarian. It draws upon modern structural utility and high-contrast system architectures, avoiding decorative fluff, micro-interactions that delay response time, and low-contrast grey-on-white text. Information density is calibrated carefully—dense where operational context is required (e.g., patient telemetry and department bed grids), but generous with touch margins and key operational triggers to eliminate mis-taps during transit or active resuscitations.

## Colors

The palette is anchored by a deep clinical slate `#0F172A` providing maximum structural contrast, combined with high-salience status hues strictly tied to medical severity states.

- **Primary (`#0F172A`)**: The authority color used for critical typography, structural headers, high-priority navigation bars, and primary interface framing.
- **Secondary (`#0D9488` - High-Availability Medical Teal)**: Designates available critical assets—open ICU/CCU beds, active incoming dispatches, confirmed handoffs, and positive operational statuses.
- **Tertiary (`#DC2626` - Critical Alert Red)**: Strictly reserved for zero-bed divert states, Code Red alerts, patient crash notifications, and time-critical diversion alerts. It is never used decoratively.
- **Warning Amber (`#F59E0B`)**: Used for bed census thresholds >90%, delayed ambulance transfer offload times (ATOT), and impending diversion statuses.
- **Neutral Surface Palette**: Pure clinical white `#FFFFFF` for primary cards, crisp cool-tinted off-white `#F8FAFC` for page backgrounds, and defined structural borders `#E2E8F0` to `#CBD5E1`.

Color is never used as the sole indicator of state; all critical status indicators pair their chromatic token with explicit text labels, high-visibility badges, and iconography.

## Typography

Typography prioritizes sub-second legibility. **Chivo** serves as the primary system typeface for all UI labels, navigation elements, clinical titles, and patient metadata due to its robust grotesque geometry, wide aperture, and immediate readability under adverse conditions.

**JetBrains Mono** is enforced across all operational metrics, countdown clocks, ETA readouts, triage acuity levels, and real-time bed count capacities. Its monospaced, tabular metrics guarantee that updating telemetry values, elapsed minute counters, and dynamic unit metrics do not cause visual layout shifts or horizontal jittering during fast-moving updates.

## Layout & Spacing

The layout employs a responsive 12-column fluid grid system on desktop dispatch workstations (1200px+), collapsing to a 6-column grid on tactical tablets (768px - 1199px) and a single-column operational stack on mobile paramedics' handsets (&lt;768px). 

The grid structure ensures that critical real-time telemetry panels, dispatch routing actions, and bed vacancy statuses remain sticky or immediately visible within the default viewport. Margins adapt from a strict `1rem` (16px) on mobile viewports to maximize usable visual surface area, scaling to `2rem` (32px) on desktop consoles. Inner element gaps are standardized around 8px and 16px increments to prevent visual noise while guaranteeing touch targets never overlap.

## Elevation & Depth

To avoid optical haze, wash-out, and visual ambiguity on anti-glare vehicle screens or budget ruggedized mobile devices, this system rejects soft decorative blur filters, pastel shadows, and multi-tier glassmorphism. Depth is achieved via **structural borders and high-contrast tonal layering**:

- **Level 0 (Canvas Base)**: Clinical off-white `#F8FAFC`.
- **Level 1 (Default Surfaces & Cards)**: Solid `#FFFFFF` bound by a crisp 1px solid `#CBD5E1` border.
- **Level 2 (Active/Selected Cards & Flyouts)**: Solid `#FFFFFF` bordered with a 2px `#0F172A` outline and backed by a dense, directional functional shadow: `0px 4px 0px 0px rgba(15, 23, 42, 0.08)`.
- **Level 3 (Modal Alerts & Emergency Overlays)**: Surface `#FFFFFF` enclosed in high-visibility alert strokes (`#DC2626` for diverts/critical crash alerts) paired with a deep backdrop scrim (`#0F172A` at 65% opacity).

## Shapes

The design system enforces a **Soft Structural** shape language (`roundedness: 1`). Interactive buttons, bed unit slots, patient telemetry badges, and operational cards feature subtle `0.25rem` (4px) radii, stepping up to `0.5rem` (8px) on main operational containers.

Sharp, defined corners preserve a crisp clinical aesthetic, convey structural rigor, and maximize interior surface area for tabular data representation. Full pill shapes are restricted strictly to micro status badges (`label-badge`) to differentiate state markers from interactive card surfaces.

## Components

### Touch Targets & Hit Areas
All interactive touch surfaces strictly adhere to a **minimum hit area of 48px × 48px**, expanding to **56px** height for all primary emergency actions (e.g., "Accept Patient", "Confirm Divert", "Dispatch Unit") to ensure reliable physical input while operating within a moving emergency vehicle or wearing medical gloves.

### Buttons
- **Primary / Action Buttons**: Solid `#0F172A` background, pure white Chivo medium/bold text, height 52px (mobile: 56px), horizontal padding `1.5rem`.
- **Critical Action Buttons**: High-visibility `#DC2626` background, white text, 2px border `#991B1B`. Used exclusively for critical diversion requests, code activations, and critical dispatch overrides.
- **Available Action Buttons**: `#0D9488` teal background, pure white text. Used for immediate bed assignments and transfer confirmations.
- **Secondary Buttons**: Crisp `#FFFFFF` surface, 2px border in `#0F172A` or `#CBD5E1`, text `#0F172A`.

### Status Badges & Counters
- High-visibility status chips with capitalized text in `label-badge` (`Chivo`, 11px, 800 weight, letter spacing `0.06em`).
- **Critical/Divert**: Background `#FEE2E2`, text `#991B1B`, border 1px solid `#DC2626`.
- **Warning/Surge**: Background `#FEF3C7`, text `#92400E`, border 1px solid `#F59E0B`.
- **Available/Open**: Background `#CCFBF1`, text `#115E59`, border 1px solid `#0D9488`.
- Bed counts and ETA indicators feature tabular monospaced numbers from `JetBrains Mono` with explicit unit suffixes (e.g., `04 MIN`, `02 BEDS`).

### Cards & Grid Containers
Bed allocation tiles feature high-contrast header bars. When capacity reaches 0 (divert status), the card switches from a standard neutral border to a persistent 3px left-accent border in `#DC2626` with a high-contrast label flag at the top right.

### Input Fields & Controls
Form controls feature 52px touch-friendly heights, bold 2px borders using `#94A3B8`, focused borders using `#0F172A`, and 16px base font size to prevent mobile browser zoom jumps. Checkboxes and radio buttons have explicit 24px × 24px bounding boxes centered inside 48px touch regions.