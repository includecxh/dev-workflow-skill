# Bug / Small Change Path

This document details the simplified 3-phase flow for bug fixes and small changes.

---

## When to Use This Path

Phase 0 classifies a request as "Bug / Small Change" when:
- It's fixing a known issue (bug, error, incorrect behavior)
- It's a small modification with no new design needed
- The scope is clear and bounded — no architectural decisions required

## The Flow

```
Phase 5: Fix the bug
    ↓
Phase 6+7: Verify + Finish (merged)
    ↓
Phase 8: Retrospective
```

Only 3 phases instead of 6-8. Phases 1-4 are skipped entirely.

---

## Phase 5: Fix the Bug

Unlike the standard Phase 5 (which executes a formal plan from writing-plans), bug fixes use a **simplified in-memory fix plan**:

> **Frontend bug?** The bug path still runs Phase 0 Step 3 (only Step 2 is skipped), so it has `is_frontend`. If `is_frontend=true`, read `bundled-skills/frontend-design/SKILL.md` + `bundled-skills/ui-ux-pro-max/SKILL.md` at **Lite level** (full frontend-design read + single `--domain` search) before fixing — this is the only frontend-skill anchor on the bug path, since Phase 1 is skipped.

1. **Reproduce the bug** — confirm you can see the problem
2. **Identify the root cause** — trace from symptom to source
3. **Plan the fix** — what code to change and why (brief, in conversation)
4. **Implement the fix** — make the minimal change
5. **Verify the fix** — confirm the bug is resolved and no regressions

No formal plan file in `docs/plans/`. The plan lives in the conversation.

**Use the `diagnose` skill** if the root cause isn't obvious. It helps systematically narrow down the problem.

**Commit format**: Use `fix` prefix with a description of what was wrong and what changed.
```
fix(auth): resolve null pointer on expired session check
```

---

## Phase 6+7: Verify + Finish (Merged)

Same as the 🟢🟡 merged mode described in `merged-phases.md`:

1. Run tests (once)
2. Code review (correctness + no side effects)
3. Spec sync check
4. Gate: fail → back to Phase 5 (≥2 no-progression round-trips trips the budget → stop and ask the user; see Phase 5 Core rules)
5. Pass → branch management via `finishing-a-development-branch` skill

---

## Phase 8: Retrospective

Even small bugs deserve a brief retrospective. Focus on:

1. **Root cause analysis**: What caused the bug? Was it a logic error, missing validation, race condition, incorrect assumption?
2. **Debugging strategy**: How did you find it? What would you check first next time?
3. **Prevention**: Could a test, lint rule, or code pattern have caught this earlier?

Keep it concise — 5 minutes, not 30.

---

## Bug Upgrade Rule — CRITICAL

**If a bug fix reveals that the real problem requires architectural changes, the bug must be upgraded.**

### When to Upgrade

- The fix requires adding new tables or modifying the schema
- The fix requires new API endpoints
- The fix changes how multiple modules interact
- The fix requires choosing between architectural approaches

### How to Upgrade

1. **Stop** the current Phase 5 work
2. **Roll back** all Phase 5 file changes (see Rollback section in main SKILL.md)
3. **Announce**: "This bug requires architectural changes. Upgrading from bug path to 🟡+ new feature."
4. **Return to Phase 0** to re-classify and re-assess complexity
5. **Do not carry forward** any fixes made in Phase 5 — the new feature flow starts fresh from Phase 1
6. The re-classification may result in 🟡 or 🔴 depending on scope

### Why Discard Phase 5 Fixes

When a bug turns out to be a feature in disguise, the fixes made during bug-mode Phase 5 were done without design review, spec confirmation, or a proper plan. They might be correct, but they might also be partial solutions that create technical debt. Starting fresh ensures the full design process considers the right scope.

**Exception**: If the Phase 5 fixes are clearly correct and independent (e.g., fixing a typo that was found while diagnosing a larger issue), those can be committed separately as a pure bug fix before starting the new feature flow.

---

## Examples

### Bug That Stays Bug (No Upgrade)

**Issue**: Login fails with "invalid credentials" even when password is correct.

**Diagnosis**: Password comparison uses `==` instead of constant-time comparison.

**Fix**: Change to `crypto.timingSafeEqual()`.

**Complexity**: 🟢 — single line change, no architecture involved.

→ Stays on bug path: 5 → 6+7 → 8

### Bug That Gets Upgraded

**Issue**: Users occasionally see other users' data.

**Diagnosis**: Session handling is fundamentally broken — shared mutable state in a singleton service.

**Fix needed**: Redesign session management — new data structure, new middleware, possibly new table.

**Complexity**: 🟡 — architectural change affecting auth module.

→ Upgraded to 🟡 new feature: Phase 0 → 1 → 2 → 3+4 → 5 → 6+7 → 8
