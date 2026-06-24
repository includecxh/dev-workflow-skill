# Merged Phases — Phase 3+4 Parallel & Phase 6+7 Combined

This document explains the two phase-merging optimizations used in 🟢 Simple and 🟡 Standard flows.

---

## Phase 3+4: Write Plan + Set Up Workspace (Parallel)

### Why They Can Run in Parallel

| Task | Type | What It Does | Dependencies |
|------|------|-------------|-------------|
| **Task A: writing-plans** | CPU-intensive (thinking + writing) | Reads design doc + spec confirmation → produces step-by-step execution plan | Only needs Phase 1+2 output |
| **Task B: using-git-worktrees** | I/O-intensive (filesystem + network) | Creates isolated workspace, installs deps, runs baseline tests | Only needs git repo access |

Neither task depends on the other's output. They can start simultaneously.

### How to Coordinate

**Start both tasks at the same time.** Don't wait for one to finish before starting the other.

Each task has its own completion announcement:
- Task A finishes: "Phase 3 (Plan) complete. [Waiting for Phase 4 / Phase 4 also complete.]"
- Task B finishes: "Phase 4 (Worktree) complete. [Waiting for Phase 3 / Phase 3 also complete.]"

When BOTH are done: "Phase 3+4 complete. Moving to Phase 5: Execute Development."

Then invoke `executing-plans` skill.

### Edge Cases

**Plan needs worktree path**: The plan may reference file paths. Since the worktree is a copy of the repo, file paths are relative and work the same. No coordination needed.

**Worktree setup fails**: If the worktree can't be created (permission issues, no git repo), fall back to working in the current directory. Don't block the plan on workspace setup.

**Plan reveals need for special workspace config**: This is rare for 🟢🟡. If it happens, the executing-plans skill can adjust the workspace during Phase 5.

---

## Phase 6+7: Verify + Finish (Combined)

### Why They Can Be Merged

In the original 8-phase flow, Phase 5 ends with tests, and Phase 7 starts with tests again. Running the same test suite twice in one development cycle is pure waste.

The merged mode runs tests **once** — that single run covers both verification (did we build it right?) and merge-readiness (is it safe to integrate?).

### The Combined Flow

```
1. Run test suite (ONCE — serves both purposes)
2. Puppeteer frontend validation (if UI exists)
   - Screenshot key pages
   - Test interactions
   - Verify end-to-end flow
3. Code review
   - Correctness: does the code do what was designed?
   - Reuse: does it leverage existing patterns/utilities?
   - Efficiency: any obvious performance issues?
4. Spec document sync check
   - Did this change affect any spec documents?
   - If yes → update them now
5. Gate check
   ❌ Tests/review fail → back to Phase 5 to fix (round-trips with no progression on ≥2 consecutive times trips the Phase 5 execution budget — stop and ask the user; see main SKILL.md Phase 5 Core rules)
   ✅ All pass → proceed to branch management
6. Invoke finishing-a-development-branch skill
   - The skill detects merged mode
   - It SKIPS its own test verification (already done)
   - It goes straight to: detect environment → present 4 options → execute choice → cleanup
7. Announce: "Phase 6+7 complete. Moving to Phase 8: Retrospective."
```

### What the finishing-a-development-branch Skill Does in Merged Mode

When invoked as part of Phase 6+7 (merged), the skill:
1. **Skips test verification** — tests were already run in step 1
2. **Detects environment** — normal repo, worktree, or detached HEAD
3. **Presents 4 options** (or 3 for detached HEAD):
   - Merge to base branch locally
   - Push and create Pull Request
   - Keep branch as-is
   - Discard work (with typed confirmation)
4. **Executes the chosen option**
5. **Cleans up workspace** (only for merge and discard options)

### 🔴 Sequential Mode (For Reference)

Complex projects do NOT merge these phases:

**Phase 6 — Verification & Review** (independent gate):
- Run verification + code review
- Gate: fail → back to Phase 5 (round-trips with no progression on ≥2 consecutive times trips the Phase 5 execution budget — stop and ask the user)
- Terminal: "Phase 6 complete. Moving to Phase 7: Branch Completion."

**Phase 7 — Branch Completion**:
- Invoke finishing-a-development-branch skill
- The skill runs its OWN test verification as a separate gate
- If tests fail → back to Phase 5 (fix → re-verify through Phase 6 → re-enter Phase 7; round-trips with no progression on ≥2 consecutive times trips the Phase 5 execution budget — stop and ask the user)
- Terminal: "Phase 7 complete. Moving to Phase 8: Retrospective."

### Why 🔴 Doesn't Merge

Complex projects have more moving parts. Verification might reveal issues that need careful consideration before rushing to branch management. The independent gate ensures:
- Verification isn't compressed by the urgency to finish
- Fix-verify-reverify loops have a clear structure
- Each gate can be independently audited

---

## Loop-Back Rules

When verification fails and work returns to Phase 5:

| Mode | Loop Path | Re-entry |
|------|-----------|----------|
| 🟢🟡 Merged | Phase 6+7 → Phase 5 → fix → Phase 6+7 | Run tests again (once), code review again |
| 🔴 Sequential | Phase 6 → Phase 5 → fix → Phase 6 → (pass) → Phase 7 | Must pass Phase 6 again before reaching Phase 7 |
| 🔴 Sequential | Phase 7 → Phase 5 → fix → Phase 6 → Phase 7 | Must re-verify through Phase 6 before Phase 7 |

**Key rule for 🔴**: If Phase 7's test verification fails, you go back to Phase 5, but you must pass through Phase 6 again before re-entering Phase 7. You don't get to skip Phase 6 just because you were already there.
