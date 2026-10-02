# BedLink Project Memory

Operational memory for BedLink development.

## Current responsibility
Complete BedLink Flutter frontend (Ambulance Dispatch & Hospital Staff interfaces).

## Current development model
15 Major Phases × 8 Sub-Phases = 120 Sub-Phases.

## Phase categorization
- **Frontend-only phases:** Phases 1–10 (Mock/local functional flows, Riverpod state, repository interfaces)
- **Core backend integration:** Phases 11–12 (Supabase Auth, PostgreSQL, RLS, Realtime)
- **External API integration:** Phases 13–15 (Geolocator, Discovery API, MapLibre/MapTiler, ORS Matrix/Directions, E2E Recovery)

## Current status
- **Current Phase:** Phase 2 (BedLink Design System)
- **Current Sub-Phase:** 2.8 completed (Interactive Showcase & Component Verification)
- **Completed work:**
  - Phase 1 approved and finalized (`chore(phase-1): approve flutter foundation`).
  - Sub-phase 2.1: Semantic Color Tokens & Theme Configuration (`lib/core/theme/app_colors.dart`, `semantic_tokens.dart`, `app_theme.dart`).
  - Sub-phase 2.2: Typography System & Numeric Readouts (`lib/core/theme/app_typography.dart` with Chivo sans-serif & JetBrains Mono tabular figures).
  - Sub-phase 2.3: Action Components & CTA System (`lib/shared/widgets/buttons/bedlink_button.dart`, `bedlink_icon_button.dart`).
  - Sub-phase 2.4: Card Hierarchy & Clinical Surfaces (`lib/shared/widgets/cards/bedlink_card.dart`, `bedlink_metric_card.dart`).
  - Sub-phase 2.5: Status Badges, Indicators & Semantic Chips (`lib/shared/widgets/badges/bedlink_badge.dart`, `status_badges.dart`).
  - Sub-phase 2.6: Form Controls, Steppers & Clinical Inputs (`lib/shared/widgets/inputs/` text field, search field, segmented selector, counter control, option card, chips, validation messages).
  - Sub-phase 2.7: Application Chrome, App Bars & Persistent Badges (`lib/shared/widgets/chrome/` logo, live indicator badge, app bar).
  - Sub-phase 2.8: Interactive Design System Showcase & Validation (`lib/features/design_system/` catalog route `/design-system`, responsive layout tests).
  - `PHASE_2_REPORT.md` generated.

## Verification results
- `flutter analyze`: 0 issues found (strict mode enabled).
- `flutter test`: 46/46 tests passed across 9 test suites.
- `flutter build web`: Built cleanly to `build/web`.

## Current files
- `lib/core/theme/*`
- `lib/shared/widgets/badges/*`, `lib/shared/widgets/buttons/*`, `lib/shared/widgets/cards/*`, `lib/shared/widgets/chrome/*`, `lib/shared/widgets/inputs/*`, `lib/shared/widgets/app_scaffold.dart`
- `lib/features/design_system/*`
- `test/core/theme_test.dart`, `test/shared/buttons_test.dart`, `test/shared/cards_test.dart`, `test/shared/badges_test.dart`, `test/shared/inputs_test.dart`, `test/features/design_system/design_system_screen_test.dart`
- `PHASE_2_REPORT.md`

## Next recommended task
Await manual testing and explicit user approval (`APPROVED`) to create `chore(phase-2): approve bedlink design system`, then proceed to Phase 3 (Authentication & Navigation Shell).
