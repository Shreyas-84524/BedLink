# AGENTS.md

This file configures AI coding agents (Antigravity, Claude Code, Cursor, Copilot, etc.) working on the **BedLink** repository.

> **Mandatory Rule:** Before starting any development task, identify which project skills are relevant and read their `SKILL.md` files (located in `.agent/skills/<skill-name>/SKILL.md`) before modifying code.

---

## 1. BedLink Project Context

**Project:** BedLink — A real-time emergency hospital coordination platform connecting ambulances, hospitals, and emergency dispatchers for rapid bed allocation and patient transit.

### Approved Tech Stack
- **Frontend / Mobile:** Flutter + Dart, `flutter_riverpod`, `geolocator`, `maplibre_gl`
- **Backend / Database:** Supabase (PostgreSQL, Supabase Auth, Supabase Realtime, Supabase Edge Functions, Supabase Cron)
- **Mapping & Routing:** MapTiler (vector tiles), OpenRouteService (Matrix & Directions via backend)
- **Version Control & CI/CD:** GitHub, GitHub Actions

### Primary Sources of Truth
Project documentation and authoritative requirements reside in `Resources/` (and root when applicable). Future agents must treat these files as primary sources of truth:

```text
Resources/rules.md
Resources/Architecture.md
Resources/PRD.md
Resources/Phases.md
Resources/design.md
Resources/memory.md
```

### Expected Order of Authority
When resolving conflicts or questions:
```text
rules.md
   ↓
Architecture.md
   ↓
PRD.md
   ↓
Phases.md
   ↓
design.md
   ↓
memory.md
```

*Note: `memory.md` contains current implementation state and progress notes but must NEVER override architectural, security, or product requirements.*

---

## 2. Agent Skill Routing

Skills reside in `.agent/skills/` with supporting reference guides in `.agent/references/`. Identify the task type and read the corresponding `SKILL.md` before taking action:

| Task / Intent | Relevant Skill | Path |
| :--- | :--- | :--- |
| Requirements & specifications | `spec-driven-development` | [.agent/skills/spec-driven-development/SKILL.md](.agent/skills/spec-driven-development/SKILL.md) |
| Breaking features into phases/tasks | `planning-and-task-breakdown` | [.agent/skills/planning-and-task-breakdown/SKILL.md](.agent/skills/planning-and-task-breakdown/SKILL.md) |
| Understanding repository context & codebase | `context-engineering` | [.agent/skills/context-engineering/SKILL.md](.agent/skills/context-engineering/SKILL.md) |
| Using Flutter/Supabase/MapLibre/ORS APIs | `source-driven-development` | [.agent/skills/source-driven-development/SKILL.md](.agent/skills/source-driven-development/SKILL.md) |
| Implementing one bounded feature / vertical slice | `incremental-implementation` | [.agent/skills/incremental-implementation/SKILL.md](.agent/skills/incremental-implementation/SKILL.md) |
| Flutter UI / widget engineering & accessibility | `frontend-ui-engineering` | [.agent/skills/frontend-ui-engineering/SKILL.md](.agent/skills/frontend-ui-engineering/SKILL.md) |
| Supabase APIs, Edge Functions & contracts | `api-and-interface-design` | [.agent/skills/api-and-interface-design/SKILL.md](.agent/skills/api-and-interface-design/SKILL.md) |
| Writing tests (unit, widget, integration) | `test-driven-development` | [.agent/skills/test-driven-development/SKILL.md](.agent/skills/test-driven-development/SKILL.md) |
| Debugging bugs, errors, and test failures | `debugging-and-error-recovery` | [.agent/skills/debugging-and-error-recovery/SKILL.md](.agent/skills/debugging-and-error-recovery/SKILL.md) |
| Reviewing completed work & quality checks | `code-review-and-quality` | [.agent/skills/code-review-and-quality/SKILL.md](.agent/skills/code-review-and-quality/SKILL.md) |
| High-risk assumptions, concurrency & edge cases | `doubt-driven-development` | [.agent/skills/doubt-driven-development/SKILL.md](.agent/skills/doubt-driven-development/SKILL.md) |
| Auth, RLS, secrets, holds & data protection | `security-and-hardening` | [.agent/skills/security-and-hardening/SKILL.md](.agent/skills/security-and-hardening/SKILL.md) |
| Git commits, branches & PR workflow | `git-workflow-and-versioning` | [.agent/skills/git-workflow-and-versioning/SKILL.md](.agent/skills/git-workflow-and-versioning/SKILL.md) |
| Architecture decisions & documentation | `documentation-and-adrs` | [.agent/skills/documentation-and-adrs/SKILL.md](.agent/skills/documentation-and-adrs/SKILL.md) |
| Logging, metrics, diagnostics & tracing | `observability-and-instrumentation` | [.agent/skills/observability-and-instrumentation/SKILL.md](.agent/skills/observability-and-instrumentation/SKILL.md) |
| Final hackathon release & deployment checklist | `shipping-and-launch` | [.agent/skills/shipping-and-launch/SKILL.md](.agent/skills/shipping-and-launch/SKILL.md) |
| Meta-skill for discovering & combining skills | `using-agent-skills` | [.agent/skills/using-agent-skills/SKILL.md](.agent/skills/using-agent-skills/SKILL.md) |

### Supporting Skills Catalog
The following supporting skills are also installed in `.agent/skills/` for specialized tasks:
- `browser-testing-with-devtools`: DevTools-assisted inspection & runtime validation
- `ci-cd-and-automation`: GitHub Actions & automated CI quality pipelines
- `code-simplification`: Behavior-preserving complexity and line-count reduction
- `constraint-driven-development`: Establishing hard project constraints and non-negotiable floor guards
- `deprecation-and-migration`: Safe system migration, schema deprecation, and cleanup
- `idea-refine`: Structured divergence/convergence for rough concepts
- `interview-me`: Clarifying underspecified requirements via proactive questioning
- `performance-optimization`: Profiling and latency/memory optimization

---

## 3. Recommended Skill Combinations

Agents should combine skills according to workflow type:

### Project Planning
```text
spec-driven-development + planning-and-task-breakdown + documentation-and-adrs
```

### Flutter Feature Development
```text
incremental-implementation + frontend-ui-engineering + source-driven-development + test-driven-development
```

### Supabase / Backend Development
```text
api-and-interface-design + source-driven-development + security-and-hardening + test-driven-development
```

### Bed Reservation & Hospital Fallback Logic
```text
incremental-implementation + test-driven-development + doubt-driven-development + security-and-hardening
```
*Critical focus:* Prevent double reservations, race conditions, incorrect timeout handling, and client-controlled reservation state.

### Debugging & Error Recovery
```text
debugging-and-error-recovery + source-driven-development + observability-and-instrumentation
```

### End-of-Phase Verification
```text
code-review-and-quality + test-driven-development + security-and-hardening
```

### Final Release & Deployment
```text
shipping-and-launch + security-and-hardening + code-review-and-quality
```

---

## 4. Mandatory Development Behavior

Every AI agent working on BedLink must strictly abide by these 20 rules:

1. **Read relevant `SKILL.md` files** before implementing any task.
2. **Read project sources of truth** (`rules.md`, `Architecture.md`, `PRD.md`, `Phases.md`, `design.md`, `memory.md`) when relevant.
3. **Do not implement multiple phases** unless explicitly requested by the user.
4. **Strict Phase Scope:** When asked to implement `Phase X.Y`, implement only that exact scope.
5. **Approved Tech Stack:** Never silently change or replace the approved technology stack (Flutter/Riverpod/Supabase/PostgreSQL/MapLibre/MapTiler/ORS).
6. **No API Hallucination:** Never invent Flutter, Supabase, MapLibre, MapTiler, or OpenRouteService APIs.
7. **Verify External APIs:** Verify uncertain external APIs and package signatures against official documentation and source definitions.
8. **Secrets Management:** Never put API keys, service role secrets, or sensitive tokens directly into source code or version control.
9. **RLS Integrity:** Never bypass Supabase Row-Level Security (RLS) merely to make something work.
10. **Server-Authoritative Workflows:** Critical BedLink workflows must remain server-authoritative in PostgreSQL / Edge Functions:
    - Hospital offer progression
    - 2-minute offer timeout
    - Automatic fallback progression
    - Reservation creation & bed hold
    - Double-booking / race-condition prevention
11. **Clean Widget Separation:** Do not place important business logic directly inside Flutter UI widgets. UI connects to Riverpod controllers/providers.
12. **Architecture Compliance:** Follow the layered architecture defined in `Resources/Architecture.md`.
13. **Root-Cause Fixes:** Prefer root-cause fixes over superficial patches or try-catch blocks that hide errors.
14. **No Fabricated Responses:** Never fabricate successful API responses or fake server state.
15. **No Fake Live Availability:** Never present mock hospital bed availability as live production data.
16. **Preserve Working Code:** Preserve all unrelated working functionality when making localized changes.
17. **Flutter Validation:** After Flutter code changes, run `flutter analyze` and relevant `flutter test` suites.
18. **Backend Validation:** After backend changes, run relevant Edge Function and database migration/RPC tests.
19. **Test-Gated Completion:** Do not claim a task or phase is complete if tests fail or static analysis produces errors.
20. **Update Memory:** Update `Resources/memory.md` after meaningful milestones with:
    - Completed work
    - Current phase & sub-phase
    - Files changed
    - Tests run & validation results
    - Known issues / blockers
    - Next recommended task
    *(Keep memory updates concise and focused).*

---

## 5. Progressive Disclosure Principle

- Do **NOT** force every skill or checklist into every prompt or task.
- Only load and read skills directly relevant to the current task.
- *Examples:*
  - A pure Flutter UI layout task requires `frontend-ui-engineering` and `incremental-implementation`, NOT `shipping-and-launch` or `ci-cd-and-automation`.
  - A database reservation or Edge Function task MUST load `security-and-hardening` and `test-driven-development` even if the user prompt is short.
