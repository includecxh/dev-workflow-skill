---
name: dev-workflow
description: "8-phase mandatory development workflow with complexity-based routing. Use this skill for ANY development request — new projects, new features, refactoring, or bug fixes. It classifies the request, assesses complexity (simple/standard/complex), and routes through the correct phase sequence with proper gates. Always invoke this skill when the user asks to build something, fix something, add a feature, or start a project — even if the request seems trivial. This skill ensures no phase is skipped and no gate is bypassed."
---

# Dev Workflow — 8-Phase Mandatory Development Process

This skill is the **orchestrator** for a structured development workflow. It doesn't replace the individual phase skills — it coordinates them, ensuring the right phases run in the right order with the right gates.

Think of it as a project manager who knows exactly which specialist to call at each stage, and won't let anyone skip ahead.

## Startup Dependency Check

Before processing any request, verify that the required sub-skills are available. Check for these files under `~/.claude/skills/`:

| Sub-Skill | Required File | Used In |
|-----------|--------------|---------|
| `brainstorming` | `brainstorming/SKILL.md` | Phase 1 |
| `writing-plans` | `writing-plans/SKILL.md` | Phase 3 |
| `using-git-worktrees` | `using-git-worktrees/SKILL.md` | Phase 4 |
| `executing-plans` | `executing-plans/SKILL.md` | Phase 5 |
| `finishing-a-development-branch` | `finishing-a-development-branch/SKILL.md` | Phase 6+7/7 |
| `ui-ux-pro-max` | `ui-ux-pro-max/SKILL.md` | Phase 1 (frontend projects) |

**If all sub-skills are present**: Proceed normally.

**If some sub-skills are missing**: Report which ones are missing and suggest the fix:

> "⚠️ dev-workflow requires these sub-skills but they are not installed: [list]. Install them by running the install script from the dev-workflow directory, or copy the bundled-skills/ sub-folders to ~/.claude/skills/."

**If sub-skills exist but lack dual-mode support** (no "Merged" or "Sequential" mentions in their SKILL.md): Warn the user:

> "⚠️ The installed [skill-name] appears to be the original Superpowers version. The dev-workflow requires the customized version with merged/sequential dual-mode support. Phase handoffs may not work correctly. Replace it with the version from bundled-skills/."

**Phases 0, 2, and 8 are self-contained** — they work without any sub-skills. A partial installation is functional but incomplete.

## Why This Exists

Development without structure leads to: skipped designs, untested code, unclear specs, and features that grow beyond their scope. This workflow enforces a minimum rigor at each stage — just enough to catch problems early, not so much that it becomes bureaucratic.

## The Big Picture

```
Request arrives
       │
  Phase 0: Classify + Assess Complexity
       │
       ├─ Bug/Small ────────→ 5 → 6+7 → 8        (3 phases)
       ├─ 🟢 Simple ──→ 1Lite → 2Lite → 3+4 → 5 → 6+7 → 8  (6 phases)
       ├─ 🟡 Standard ─→ 1 → 2 → 3+4 → 5 → 6+7 → 8         (6 phases)
       └─ 🔴 Complex ──→ 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8     (8 phases)
```

**Key optimization**: Simple and standard projects merge phases 3+4 (parallel) and 6+7 (single pass) to reduce overhead. Complex projects keep all 8 phases separate with independent gates.

---

## Phase 0: Classify & Assess

**This phase is ALWAYS executed first. No exceptions.** Every development request must be classified before any work begins.

### Step 1: Type Classification

| Type | Criteria | Entry |
|------|----------|-------|
| **New Project** | Starting from scratch, no existing code | Phase 1 |
| **New Feature** | Adding new module/capability to existing project | Phase 1 |
| **Refactoring** | Changing structure without changing behavior | Phase 2 |
| **Bug / Small Change** | Fixing known issue, no new design needed | Phase 5 |

**You must confirm the classification with the user** before proceeding. Example: "This is a new feature request. I'll follow the standard flow. Confirm?"

### Step 2: Complexity Assessment

Only required for new project, new feature, and refactoring. Bug/small changes skip this.

| Complexity | Criteria | Flow Path |
|------------|----------|-----------|
| 🟢 **Simple** | Single component, clear requirements, no new tables/APIs, estimated < 1h | Fast lane (6 phases) |
| 🟡 **Standard** | Multi-component, needs discussion, new APIs/tables, estimated 1-4h | Standard lane (6 phases) |
| 🔴 **Complex** | New project/large subsystem, architectural decisions, estimated > 4h | Full lane (8 phases) |

**Upgrade signals** (any one hit triggers upgrade):
- Adding or modifying database tables → at least 🟡
- Involves 3+ files/modules → at least 🟡
- Requires architectural decisions (tech choice, patterns, protocols) → at least 🟡
- New independent subsystem → 🔴
- User explicitly says "this is complex" → 🔴
- Pure UI tweak / copy change / config update → 🟢

For the full signal reference with examples, read `references/complexity-signals.md`.

**Confirm complexity with the user.** Example: "I assess this as 🟡 standard, following the standard lane. Agree?"

### Step 2 Output

After both steps, announce the classification result:

> "Phase 0 complete. Classification: **[type]**, Complexity: **[level]**, Flow: **[path]**. Moving to [next phase]."

---

## Phase 1: Design — Invoke `brainstorming` Skill

Invoke the `brainstorming` skill. The mode depends on complexity:

**🟢 Lite mode**: The brainstorming skill has a built-in Lite process for simple complexity. It does 2-3 quick questions + inline design confirmation. No separate design document needed.

**🟡🔴 Standard mode**: Full brainstorming process — explore context, ask questions one at a time, propose 2-3 approaches, present design in sections, write design doc to `docs/specs/YYYY-MM-DD-<topic>-design.md`, spec self-review, user review.

**Frontend projects**: If the project involves ANY frontend or UI development — regardless of complexity level (🟢🟡🔴) — you MUST invoke both `frontend-design` and `ui-ux-pro-max` together. They serve complementary roles:

> **`frontend-design` = Thinking side (思想侧)**: Design philosophy, principles, anti-patterns, self-criticism loop, UX reasoning. Answers "why design it this way."
>
> **`ui-ux-pro-max` = Practice side (实践侧)**: Design system generation, color palettes, typography, component libraries, tech-stack adaptation. Answers "how to build it."
>
> **Cooperation logic**: Thinking side sets direction first → Practice side materializes it. Think before you build — avoids "fast but ugly."

This applies to Lite mode too — a 🟢 simple frontend change still goes through both skills (though the design system output can be lighter). The brainstorming skill handles this invocation automatically within its process — you don't need to manage it separately.

**Hard gate**: Design must be approved by the user before proceeding. No code, no implementation, no scaffolding until design approval.

**Terminal state**: "Phase 1 complete. Design approved. Moving to Phase 2: Specification Confirmation."

---

## Phase 2: Specification Confirmation

**This phase is executed directly by this skill** — it's not delegated to a sub-skill.

The goal is to lock down the specifications before writing any plan or code. All 5 items must be confirmed.

### 🟢 Lite Mode (Simple Complexity)

Only confirm items that are actually affected by the change. Mark unaffected items as N/A and skip them.

Example: Pure frontend UI adjustment → Data Model = N/A, API Design = N/A. Only confirm Business Rules + Testing Strategy.

### 🟡🔴 Standard Mode

All 5 items must be explicitly confirmed:

1. **Data Model**: What tables are added/modified? Field names, types, constraints? Any base class inheritance?
2. **API Design**: API paths, request parameters, response format? Following existing naming conventions?
3. **Business Rules**: State transitions, permission requirements, boundary conditions?
4. **Spec Impact**: Does this change affect any project spec documents? If yes, must update them synchronously.
5. **Testing Strategy**: What behaviors to test? Which are critical paths?

For Lite mode details and examples, read `references/lite-modes.md`.

**Terminal state**: "Phase 2 complete. Moving to Phase 3+4: Prepare & Plan."

> Note: The terminal state declaration always says "Phase 3+4", but actual execution branches by complexity — 🟢🟡 enters Phase 3+4 in parallel, 🔴 enters Phase 3 sequentially.

---

## Phase 3+4: Prepare & Plan

### 🟢🟡 Merged Parallel Mode

**Write plan and set up workspace simultaneously** — they're independent tasks, so running them in parallel saves time.

**Task A — Write Plan**: Invoke the `writing-plans` skill. It reads the approved design + spec confirmation and produces a micro-step execution plan (2-5 min per step, TDD format). Plan saved to `docs/plans/YYYY-MM-DD-<feature-name>.md`.

**Task B — Set Up Workspace**: Invoke the `using-git-worktrees` skill. It creates an isolated workspace, installs dependencies, and runs baseline tests.

When both tasks complete, announce: "Phase 3+4 complete. Moving to Phase 5: Execute Development."

For the full merged-phase details including coordination logic, read `references/merged-phases.md`.

### 🔴 Sequential Mode

**Phase 3 first**: Invoke `writing-plans` skill. Wait for plan to be approved.

Announce: "Phase 3 complete. Moving to Phase 4: Worktree Isolation."

**Phase 4 next**: Invoke `using-git-worktrees` skill. Wait for workspace to be ready.

Announce: "Phase 4 complete. Moving to Phase 5: Execute Development."

---

## Phase 5: Execute Development — Invoke `executing-plans` Skill

Invoke the `executing-plans` skill. It loads the plan, executes each task step by step with TDD (red → green → refactor), and verifies each step before marking it complete.

**Core rules during execution**:
- One minimum viable loop at a time
- Verify immediately after each step
- Commit with standard prefixes (feat/fix/refactor) describing business motivation and scope
- Stop and ask for help when blocked — don't guess
- Never develop on main/master without explicit user consent

**Terminal state** (depends on mode):

🟢🟡: "Phase 5 complete. Moving to Phase 6+7: Verify & Finish."

🔴: "Phase 5 complete. Moving to Phase 6: Verification & Review."

---

## Phase 6+7: Verify & Finish

### 🟢🟡 Merged Mode — Single Pass

Tests run once (covering both verification and merge-readiness). After code-review passes, branch management options are presented directly.

1. Run test suite (once, serves both verification and merge-check)
2. Puppeteer frontend validation if UI exists (screenshot + interaction + end-to-end)
3. Code review (correctness + reuse + efficiency)
4. Check if spec documents need updating
5. If tests/review fail → back to Phase 5 to fix
6. If all pass → invoke `finishing-a-development-branch` skill for branch management

The `finishing-a-development-branch` skill detects the merged mode and skips its own test verification (already done).

**Terminal state**: "Phase 6+7 complete. Moving to Phase 8: Retrospective (复盘精读)."

### 🔴 Sequential Mode

**Phase 6 — Verification & Review** (independent gate):
1. Puppeteer frontend validation if UI exists
2. Run verify skill + code-review skill
3. Check spec document updates
4. Gate: review not passed → back to Phase 5

**Terminal state**: "Phase 6 complete. Moving to Phase 7: Branch Completion."

**Phase 7 — Branch Completion**: Invoke `finishing-a-development-branch` skill. It runs its own test verification as a separate gate, then presents branch options.

**Terminal state**: "Phase 7 complete. Moving to Phase 8: Retrospective (复盘精读)."

For full merged-phase details, read `references/merged-phases.md`.

---

## Phase 8: Retrospective (复盘精读)

**This phase is executed directly by this skill** — it's the learning-oriented conclusion.

### 1. Code Walkthrough (代码精读)

Trace the complete chain for every feature implemented:
- **Backend**: Controller → Service → Mapper → SQL → Database changes
- **Frontend**: Component → State → API call → Response handling → UI update
- For each layer: what it does, why it's designed this way, how data flows through

### 2. Knowledge Extraction (知识提炼)

| Category | What to Cover |
|----------|--------------|
| **Key Code** | Which code is core logic and why |
| **Concepts** | Technical concepts and principles involved |
| **Keywords** | Professional terms and their meanings |
| **Common Pitfalls** | What mistakes are typical for this type of feature |
| **Debugging Strategy** | Where to start investigating when things go wrong |

### 3. Gate — Understanding Check

**The user must demonstrate understanding of the main chain and key code responsibilities before moving on to the next feature.** This is not a test — it's a learning conversation. If the user can't explain it yet, walk through it again with different angles.

**Terminal state**: "Phase 8 complete. Feature fully understood. Ready for next request."

---

## Bug / Small Change Path

Bug fixes and small changes skip Phases 1-4 entirely, entering at Phase 5.

1. **Phase 5**: Fix the bug directly. No writing-plans plan file needed — use a simplified in-memory fix plan.
2. **Phase 6+7**: Merged verification + branch management (one test run).
3. **Phase 8**: Retrospective — even small bugs are worth extracting debugging insights from.

**Important upgrade rule**: If a bug requires architectural changes, upgrade to at least 🟡 new feature. Return to **Phase 0** to re-classify and re-assess complexity. Discard any Phase 5 fixes already made — the new feature flow starts fresh from Phase 1.

For full bug-path details including the upgrade flow, read `references/bug-path.md`.

---

## Rollback on Path Change

When the workflow path changes mid-stream, you MUST roll back file changes made during the current or just-completed phase. Leaving stale files from an abandoned path creates confusion and can mislead future work.

**Triggers that require rollback:**

| Scenario | What to Roll Back |
|----------|-------------------|
| Bug upgraded to 🟡+ feature | All Phase 5 bug fixes (code, tests, commits in worktree) |
| **Complexity misjudged** (e.g., 🟢→🟡, 🟡→🔴) | All code implemented in current phase, related commits, plan files |
| Design rejected in Phase 1, restarting | Design doc file, any prototype code generated |
| Spec changes in Phase 2 requiring redesign | Phase 1 design doc if it conflicts with new specs |
| User cancels current direction | All uncommitted work in current phase |

**Complexity misjudgment detection** (pause and re-assess when these signals appear in Phase 5):

- Need to add database tables not considered in Phase 0 → upgrade to at least 🟡
- Need cross-module coordination assumed to be single-component → upgrade to at least 🟡
- Need tech-stack decisions assumed to be inherited → upgrade to at least 🟡
- Feature scope turns out much larger than estimated → re-assess complexity
- User says "this is more complex than I thought" → pause immediately

**When misjudgment is confirmed:**

1. Pause all work immediately
2. Explain the misjudgment to the user with specific evidence
3. Confirm the new complexity level
4. Roll back ALL code implemented under the wrong assessment
5. Return to **Phase 0** to re-classify and re-assess
6. The new flow starts from Phase 1 — no shortcuts, no carrying over code from the abandoned path

> **Why rollback is mandatory**: Different complexity levels have different gate strictness. 🟢 fast lane skips many safeguards (simplified design, parallel planning). If the real complexity is 🟡, code produced under relaxed gates may lack proper spec confirmation and test coverage. Continuing without rollback = bypassing gates.

**How to roll back:**

1. **If working in a worktree**: Remove the worktree entirely — it was isolated, so no contamination.
   ```bash
   cd <main-repo-root>
   git worktree remove <worktree-path>
   ```

2. **If working in main repo**: Use `git checkout` or `git stash` to revert uncommitted changes.
   ```bash
   git checkout -- .                    # revert all unstaged changes
   git clean -fd                        # remove untracked files
   ```

3. **If changes were already committed**: Create a revert commit rather than force-pushing.
   ```bash
   git revert <commit-hash>
   ```

**What NOT to roll back**: Independently valid fixes that were committed to main/master before the path change. For example, if a typo was fixed while diagnosing a bug that later got upgraded, the typo fix can stay — it's unrelated to the abandoned path.

---

## Terminal State Chain Reference

Every phase ends with a standard declaration. These declarations are the handoff contract between phases — they must match exactly.

| Flow | Phase 0 → | Phase 1 → | Phase 2 → | Phase 3+4/3 → | Phase 4 → | Phase 5 → | Phase 6+7/6 → | Phase 7 → |
|------|-----------|-----------|-----------|----------------|-----------|-----------|----------------|-----------|
| Bug | - | - | - | - | - | 6+7 | 8 | - |
| 🟢 | 1Lite | 2Lite | 3+4 | 5 | 6+7 | 8 | - | - |
| 🟡 | 1 | 2 | 3+4 | 5 | 6+7 | 8 | - | - |
| 🔴 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |

**Declaration format**: "Phase [N] complete. Moving to Phase [N+1]: [Name]."

---

## Conflict Resolution Rules (Summary)

The full 15 rules with rationale are in `references/conflict-rules-full.md`. The essential ones:

1. **This workflow > skill auto-trigger** — if a skill wants to fire out of order, the workflow wins
2. **This workflow > other CLAUDE.md rules** — on conflict, follow the workflow
3. **brainstorming only fires on new requests** — not on bug fixes or small changes
4. **Phase 2 must follow Phase 1** — no skipping from brainstorming directly to planning
5. **tdd is only used inside Phase 5** — not at other phases
6. **Complexity assessment is mandatory** — Phase 0 Step 2 cannot be skipped
7. **Merged phases cannot be split** — 🟢🟡 must use parallel/merged mode
8. **Complex projects must use all 8 phases** — 🔴 cannot skip or merge phases
9. **frontend-design + ui-ux-pro-max are paired for frontend projects** — `frontend-design` is the **thinking side** (design philosophy, principles, anti-patterns); `ui-ux-pro-max` is the **practice side** (design system, colors, typography, components). Always invoke both together for any UI project, regardless of complexity. Thinking side first → Practice side second
10. **Complexity misjudgment requires rollback** — if Phase 5 reveals the complexity was underestimated, roll back ALL implemented code and return to Phase 0 for re-classification. No carrying over code from the abandoned path

---

## Sub-Skill Dependency Map

This skill orchestrates these sub-skills. They must be installed for full functionality:

| Skill | Phase | Trigger Mode | Purpose |
|-------|-------|-------------|---------|
| `brainstorming` | Phase 1 | Invoked by this skill | Design clarification |
| `writing-plans` | Phase 3 | Invoked by this skill | Create execution plan |
| `using-git-worktrees` | Phase 4 | Invoked by this skill | Isolated workspace |
| `executing-plans` | Phase 5 | Invoked by this skill | Execute plan with TDD |
| `finishing-a-development-branch` | Phase 6+7/7 | Invoked by this skill | Branch completion |

**If a sub-skill is not installed**: The phase that depends on it will need to be executed manually. Phases 0, 2, and 8 are self-contained and always work.

---

## Quick Decision Flowchart

When a request comes in, follow this exact sequence:

```
1. Is this a development request?
   No → Don't invoke this skill
   Yes → Continue

2. Phase 0 Step 1: What type?
   Bug/Small → Skip to Phase 5 (bug path)
   Refactoring → Skip to Phase 2
   New Project/New Feature → Continue to Step 3

3. Phase 0 Step 2: What complexity?
   Count the upgrade signals → 🟢/🟡/🔴
   Confirm with user

4. Route to the correct flow path
   Announce classification result
   Proceed to Phase 1 (or Phase 2 for refactoring)
```
