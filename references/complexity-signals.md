# Complexity Signals — Detailed Reference

This document provides the full signal reference for Phase 0 Step 2 (Complexity Assessment) — i.e., signals read **before** work starts, to classify 🟢/🟡/🔴 upfront. For **post-hoc** misjudgment signals (discovered during Phase 5 that the upfront call was wrong), see the Rollback section in main SKILL.md.

## Upgrade Signals with Examples

### Signals that trigger at least 🟡 (Standard)

**1. Adding or modifying database tables**
- New table for a feature → 🟡
- Adding columns to existing table → 🟡
- Changing column types or constraints → 🟡
- Just adding an index to existing table → 🟢 (no schema change)

**2. Involves 3+ files or modules**
- Touching 1-2 files in a single module → 🟢
- Touching 3+ files across modules → 🟡
- Example: Adding a field requires changes to model, controller, service, and migration → 🟡 (4 files)

**3. Requires architectural decisions**
- Choosing between Redis vs in-memory cache → 🟡
- Selecting an auth pattern (JWT vs session) → 🟡
- Deciding between REST vs GraphQL for a new endpoint → 🟡
- Using an existing pattern already established in the project → 🟢 (no new decision)

**4. New API endpoints**
- Adding one simple CRUD endpoint following existing patterns → 🟢
- Adding endpoints with custom business logic → 🟡
- Adding a new API version or changing API contracts → 🟡

**5. State machine or workflow logic**
- Simple CRUD with no state transitions → 🟢
- Adding status fields with transition rules → 🟡
- Multi-step approval workflows → 🔴

### Signals that trigger 🔴 (Complex)

**1. New independent subsystem**
- "Add a notification system" (new module with its own models, APIs, workers) → 🔴
- "Add a field to the user profile" (existing subsystem, just extending) → 🟡

**2. Multi-module integration**
- Feature requires changes across 3+ independent services → 🔴
- Feature requires new infrastructure (message queue, scheduler) → 🔴

**3. User explicitly says "this is complex"**
- Trust the user's judgment → 🔴
- Even if it doesn't look complex to you, the user may know about hidden dependencies

**4. New project**
- Starting from scratch is always 🔴
- Even a "simple" new project has architectural decisions (framework, structure, CI/CD)

### Signals that keep it 🟢 (Simple)

**1. Pure UI adjustments**
- Changing button text or colors → 🟢
- Adjusting layout spacing → 🟢
- Adding a CSS class → 🟢

**2. Copy/text changes**
- Updating help text or labels → 🟢
- Changing error messages → 🟢

**3. Configuration changes**
- Updating a config value → 🟢
- Toggling a feature flag → 🟢
- Adding a new environment variable → 🟢

**4. Single-component, clear-scope changes**
- "Add a required field validation to the email input" → 🟢
- "Change the date format in the report" → 🟢

## Ambiguous Cases

| Scenario | Default | Rationale |
|----------|---------|-----------|
| "Refactor the user module" | 🟡 | Refactoring without clear scope = uncertain complexity |
| "Add dark mode" | 🟡 | Touches many components but no new logic |
| "Fix the login bug" (turns out to be auth redesign) | Upgrade to 🟡 | Bug path enters Phase 5, discovers architectural scope → upgrade to Phase 0 |
| "Add export to CSV" | 🟢 if simple query, 🟡 if complex transform | Depends on data complexity |
| "Integrate payment" | 🔴 | New subsystem with external dependencies, security concerns |

## Assessment Checklist

When evaluating complexity, ask yourself:

1. How many files will this touch?
2. Does this require new database tables or schema changes?
3. Are there architectural decisions to make?
4. Is there a new external dependency?
5. Does this affect multiple independent modules?
6. Are there security or compliance considerations?
7. Is the scope clearly bounded?

If unsure between two levels, **round up**. It's better to have slightly more structure than to discover mid-project that you needed it.
