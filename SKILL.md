---
name: dev-workflow
description: "INVOKE when the user wants to: build a new project, add a feature, fix a bug, refactor code, or make any change to code — regardless of size or complexity. Phase 0 classifies the request type (new project / new feature / refactoring / bug fix) and complexity (🟢 simple / 🟡 standard / 🔴 complex), then routes through the correct gated phase sequence. DO NOT invoke when the user is: asking questions, exploring code without intent to change it, reading documentation, requesting explanations, or having a conversation with no code modification intended. When in doubt, invoke — Phase 0 will determine if the workflow is needed."
---

# Dev Workflow — 8-Phase Mandatory Development Process

This skill is the **orchestrator** for a structured development workflow. It doesn't replace the individual phase skills — it coordinates them, ensuring the right phases run in the right order with the right gates.

Think of it as a project manager who knows exactly which specialist to call at each stage, and won't let anyone skip ahead.

## Sub-Skill Resolution

All sub-skills are **bundled within this skill's directory** — they are NOT installed as separate global skills. This means:

1. **Zero pollution**: Installing dev-workflow does not overwrite any existing skills the user may have (e.g., a standalone Superpowers brainstorming).
2. **Self-contained**: Everything lives under `~/.claude/skills/dev-workflow/bundled-skills/`.

When this skill or any bundled sub-skill references another skill by name (e.g., "invoke brainstorming", "use frontend-design"), **resolve it by reading the bundled file**:

```
Read ~/.claude/skills/dev-workflow/bundled-skills/<skill-name>/SKILL.md and follow its instructions.
```

**Do NOT** use the Skill tool to invoke bundled sub-skills — they are not installed in the global skills directory.

### Sub-Skill Boundary

Sub-skills execute their own phase's content only. After completing, announce "Phase N complete, handing back to orchestrator" and stop — do not invoke other skills or describe other phases. The orchestrator owns all phase transitions (what runs next, in what mode, with what gates).

| Skill Name | Bundled Path |
|------------|-------------|
| brainstorming | `bundled-skills/brainstorming/SKILL.md` |
| writing-plans | `bundled-skills/writing-plans/SKILL.md` |
| using-git-worktrees | `bundled-skills/using-git-worktrees/SKILL.md` |
| executing-plans | `bundled-skills/executing-plans/SKILL.md` |
| finishing-a-development-branch | `bundled-skills/finishing-a-development-branch/SKILL.md` |
| frontend-design | `bundled-skills/frontend-design/SKILL.md` |
| ui-ux-pro-max | `bundled-skills/ui-ux-pro-max/SKILL.md` |

**Python runtime for ui-ux-pro-max**: The ui-ux-pro-max skill requires Python to run its search scripts (`scripts/search.py`). Before invoking it, check `.runtime-config` in this skill's directory for the detected Python runtime. If the file doesn't exist, detect the runtime at invocation time by checking: (1) `uv` available → use `uv run`, (2) `python3` available and real (not a Windows Store stub) → use `python3`, (3) neither → prompt the user to install uv.

---

## Startup Dependency Check

Before processing any request, verify that the required sub-skill files are available within this skill's `bundled-skills/` directory. Check for these files under `~/.claude/skills/dev-workflow/`:

| Sub-Skill | Required File | Used In |
|-----------|--------------|---------|
| `brainstorming` | `bundled-skills/brainstorming/SKILL.md` | Phase 1 |
| `writing-plans` | `bundled-skills/writing-plans/SKILL.md` | Phase 3 |
| `using-git-worktrees` | `bundled-skills/using-git-worktrees/SKILL.md` | Phase 4 |
| `executing-plans` | `bundled-skills/executing-plans/SKILL.md` | Phase 5 |
| `finishing-a-development-branch` | `bundled-skills/finishing-a-development-branch/SKILL.md` | Phase 6+7/7 |
| `frontend-design` | `bundled-skills/frontend-design/SKILL.md` | Phase 1 (frontend projects) |
| `ui-ux-pro-max` | `bundled-skills/ui-ux-pro-max/SKILL.md` | Phase 1 (frontend projects) |

**If all sub-skill files are present**: Proceed normally.

**If some sub-skill files are missing**: Report which ones are missing and suggest the fix:

> "⚠️ dev-workflow requires these bundled sub-skills but they are missing: [list]. Re-run the install script or verify the installation at ~/.claude/skills/dev-workflow/bundled-skills/."

**Python runtime check for ui-ux-pro-max**: If `.runtime-config` exists in this skill's directory, it records the detected Python runtime (`python_runtime=uv` or `python_runtime=python3`). If not, runtime detection will be performed before invoking ui-ux-pro-max (see Sub-Skill Resolution section above).

**Phases 0, 2, and 8 are self-contained** — they work without any sub-skills. A partial installation is functional but incomplete.

## Why This Exists

Development without structure leads to: skipped designs, untested code, unclear specs, and features that grow beyond their scope. This workflow enforces a minimum rigor at each stage — just enough to catch problems early, not so much that it becomes bureaucratic.

## Continuous Execution Principle

**All phases execute within a single prompt turn.** When a development request comes in, the workflow runs through every applicable phase from Phase 0 to Phase 8 without stopping between phases to wait for the user to submit a new prompt.

**How this works in practice:**

- **Phase transitions are automatic**: After completing a phase, immediately proceed to the next phase within the same response. Do NOT stop and wait for the user to type another prompt.
- **Gates use inline confirmation**: Where a gate requires user approval (e.g., design approval in Phase 1, spec confirmation in Phase 2, complexity assessment in Phase 0), use AskUserQuestion or direct conversation to get confirmation within the same turn — do not defer it to the next prompt.
- **Terminal state declarations are announcements, not stop points**: Statements like "Phase 0 complete. Moving to Phase 1" are log markers that signal phase completion to the user. They do NOT mean "stop here and wait." Immediately continue to the next phase after announcing.
- **Long-running work uses background tasks**: When Phase 3+4 parallel tasks or Phase 5 execution steps take time, use background agents/parallel tool calls. The orchestrator (this skill) keeps running and coordinates results.
- **The user can interrupt at any time**: If the user sends a new message while the workflow is running, treat it as an interruption. Address their input, then resume the workflow from where it was paused.

**What NOT to do:**
- ❌ Stop after Phase 0 and wait for the user to say "continue"
- ❌ Announce "Phase 1 complete" and then stop, expecting the user to trigger Phase 2
- ❌ Ask "Should I proceed to the next phase?" — just proceed, unless there's an actual gate that needs user input

**Exceptions where pausing IS appropriate:**
- Phase 1 design approval gate — the user must explicitly approve the design before coding begins
- Phase 8 understanding check — the user must demonstrate understanding before the workflow ends
- User explicitly asks to pause or take a break
- An unexpected error or blocker is encountered that requires user guidance

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

**Use inline confirmation** (AskUserQuestion or direct ask) to confirm the classification with the user within the same turn. Example: "This is a new feature request. I'll follow the standard flow. Confirm?"

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

**Confirm complexity with the user using inline confirmation** within the same turn. Example: "I assess this as 🟡 standard, following the standard lane. Agree?"

### Step 3: Frontend Assessment

**Applies to ALL types — including Bug/small changes.** Unlike Step 2 (which bugs skip), Step 3 runs for every request. This is mandatory: frontend bugs still need frontend skills (rule 9), but the bug path skips Phase 1 — so Phase 0 is the only place that can set the flag Phase 5 will read.

Use the "ANY frontend or UI development" standard (strict, same as rule 9). Ask the user one inline yes/no question. When in doubt about edge cases, default to **yes** — it's safer to trigger frontend skills than to miss them (a silent miss breaks rule 9; a false trigger only costs an extra read).

Ask exactly:

> **Does this request involve ANY frontend or UI development?** (yes/no)
> - **yes** — e.g., changing a button's color/layout, building a React/Vue page, a mobile app screen, a TUI dashboard
> - **yes** — e.g., an API + a small admin panel, SSR with templates rendered to the browser, React Native
> - **no** — e.g., a CLI flag change, a pure REST/GraphQL backend service, a database migration script
>
> Edge cases (SSR, hybrid API+UI, mobile, TUI) count as **yes**.

**Output**: `is_frontend` (bool). Consumers:
- **Phase 1** (brainstorming): when `true`, reads `bundled-skills/frontend-design/SKILL.md` + `bundled-skills/ui-ux-pro-max/SKILL.md` (Lite level in 🟢)
- **Phase 5** (bug path): when `true`, reads both frontend skills at entry before fixing (Lite level)

### Phase 0 Output

After all three steps, announce the classification result:

> "Phase 0 complete. Classification: **[type]**, Complexity: **[level]**, Frontend: **[yes/no]**, Flow: **[path]**. Moving to [next phase]."

---

## Phase 1: Design — Read `bundled-skills/brainstorming/SKILL.md`

Read `bundled-skills/brainstorming/SKILL.md` and follow its instructions. The mode depends on complexity:

**🟢 Lite mode**: The brainstorming skill has a built-in Lite process for simple complexity. It does 2-3 quick questions + inline design confirmation. No separate design document needed.

**🟡🔴 Standard mode**: Full brainstorming process — explore context, ask questions one at a time, propose 2-3 approaches, present design in sections, write design doc to `docs/specs/YYYY-MM-DD-<topic>-design.md`, spec self-review, user review.

**Frontend projects**: If the project involves ANY frontend or UI development — regardless of complexity level (🟢🟡🔴) — you MUST read and follow both `bundled-skills/frontend-design/SKILL.md` and `bundled-skills/ui-ux-pro-max/SKILL.md`. They serve complementary roles:

> **`frontend-design` = Thinking side (思想侧)**: Design philosophy, principles, anti-patterns, self-criticism loop, UX reasoning. Answers "why design it this way."
>
> **`ui-ux-pro-max` = Practice side (实践侧)**: Design system generation, color palettes, typography, component libraries, tech-stack adaptation. Answers "how to build it."
>
> **Cooperation logic**: Thinking side sets direction first → Practice side materializes it. Think before you build — avoids "fast but ugly."

This applies to Lite mode too — a 🟢 simple frontend change still goes through both skills (though the design system output can be lighter). **Trigger source**: Phase 0's Step 3 sets `is_frontend`. When `is_frontend=true`, the brainstorming sub-skill reads both frontend skills (Lite level: single `--domain` + full frontend-design read) — you don't need to manage it separately. When calling ui-ux-pro-max scripts, use the runtime detected in `.runtime-config` (see Sub-Skill Resolution section).

**Persist requirement (🟡🔴 only)**: In Standard/Complex frontend projects, the ui-ux-pro-max `--design-system` call MUST include `--persist`, so the design system lands at `design-system/<project-slug>/MASTER.md` for Phase 5/6 to read. (Lite mode is N/A — it runs a single `--domain` search, which produces no MASTER.md to persist.) Persisting lets Phase 5 (execution) and Phase 6+7 (pre-delivery check) read this file instead of re-running the search — skipping `--persist` wastes the Phase 1 design-system work and forces a downstream re-query (~3300 tokens).

**Hard gate**: Design must be approved by the user (via inline confirmation within the same turn) before proceeding. No code, no implementation, no scaffolding until design approval. After approval, immediately continue to Phase 2 — do not stop and wait for a new prompt.

**Terminal state**: "Phase 1 complete. Design approved. Moving to Phase 2: Specification Confirmation." — This is an announcement, not a stop point. Immediately proceed to Phase 2.

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

**Terminal state**: "Phase 2 complete. Moving to Phase 3+4: Prepare & Plan." — This is an announcement, not a stop point. Immediately proceed to Phase 3+4 (or Phase 3 for 🔴).

> Note: The terminal state declaration always says "Phase 3+4", but actual execution branches by complexity — 🟢🟡 enters Phase 3+4 in parallel, 🔴 enters Phase 3 sequentially.

---

## Phase 3+4: Prepare & Plan

### 🟢🟡 Merged Parallel Mode

**Write plan and set up workspace simultaneously** — they're independent tasks, so running them in parallel saves time.

**Task A — Write Plan**: Read `bundled-skills/writing-plans/SKILL.md` and follow its instructions. It reads the approved design + spec confirmation and produces a micro-step execution plan (2-5 min per step, TDD format). Plan saved to `docs/plans/YYYY-MM-DD-<feature-name>.md`.

**Task B — Set Up Workspace**: Read `bundled-skills/using-git-worktrees/SKILL.md` and follow its instructions. It creates an isolated workspace, installs dependencies, and runs baseline tests.

When both tasks complete, announce: "Phase 3+4 complete. Moving to Phase 5: Execute Development." — Then immediately proceed to Phase 5.

For the full merged-phase details including coordination logic, read `references/merged-phases.md`.

### 🔴 Sequential Mode

**Phase 3 first**: Read `bundled-skills/writing-plans/SKILL.md` and follow its instructions. Wait for plan to be approved (inline confirmation within same turn).

Announce: "Phase 3 complete. Moving to Phase 4: Worktree Isolation." — Then immediately proceed to Phase 4.

**Phase 4 next**: Read `bundled-skills/using-git-worktrees/SKILL.md` and follow its instructions. Wait for workspace to be ready.

Announce: "Phase 4 complete. Moving to Phase 5: Execute Development." — Then immediately proceed to Phase 5.

---

## Phase 5: Execute Development — Read `bundled-skills/executing-plans/SKILL.md`

Read `bundled-skills/executing-plans/SKILL.md` and follow its instructions. It loads the plan, executes each task step by step with TDD (red → green → refactor), and verifies each step before marking it complete.

**Core rules during execution**:
- One minimum viable loop at a time
- Verify immediately after each step
- Commit with standard prefixes (feat/fix/refactor) describing business motivation and scope
- Stop and ask for help when blocked — don't guess
- Never develop on main/master without explicit user consent

**Frontend skills for bug path**: If Phase 0 set `is_frontend=true` (the bug path skips Phase 1, so this flag is the only trigger), read `bundled-skills/frontend-design/SKILL.md` + `bundled-skills/ui-ux-pro-max/SKILL.md` at entry before fixing — at **Lite level** (full frontend-design read + single `--domain` search, not full `--design-system`), matching the Lite exception in brainstorming.

**Frontend skills for standard path** (🟡🔴, not bug, not Lite): When `is_frontend=true` and entering Phase 5 via the standard path (i.e., Phase 1 already ran `--design-system --persist` per PR #9), consume the persisted design system instead of re-generating:
1. **Read** `design-system/<project-slug>/MASTER.md` — design principles, colors, typography, anti-patterns (the file exists per the Phase 1 `--persist` mandate)
2. **Run ONE** `--stack <stack>` search at entry (default `html-tailwind` if the project stack is unspecified; adjust to react/nextjs/vue/etc. per the actual project) — implementation guidance for the chosen stack; keep the result in conversation for subsequent steps to reference
3. Subsequent TDD steps reference both; do **NOT** re-run `--design-system` or `--stack` per step (avoids token accumulation)

This dual-track exists because MASTER.md (design) and `--stack` (implementation) are orthogonal — reading only MASTER would drop stack-specific guidance (misaligning rule 12).

**Terminal state** (depends on mode) — Announce then immediately proceed:

🟢🟡: "Phase 5 complete. Moving to Phase 6+7: Verify & Finish."

🔴: "Phase 5 complete. Moving to Phase 6: Verification & Review."

---

## Phase 6+7: Verify & Finish

### 🟢🟡 Merged Mode — Single Pass

Tests run once (covering both verification and merge-readiness). After code-review passes, branch management options are presented directly.

1. Run test suite (once, serves both verification and merge-check). **If you returned here after a Phase 5 fix** (i.e., step 3 code-review failed and you went back to fix), re-run the full suite here — the previous run tested pre-fix code, the fix changed code, so it must be re-verified.
2. Puppeteer frontend validation if UI exists (screenshot + interaction + end-to-end). If `is_frontend=true`, also cross-check the screenshot against `design-system/<project-slug>/MASTER.md` anti-patterns section — report any violation before "all pass"
3. Code review (correctness + reuse + efficiency)
4. Check if spec documents need updating
5. If tests/review fail → back to Phase 5 to fix → **on return, re-run step 1 (full suite) before continuing** — do NOT carry forward the pre-fix test result. Only when step 3 review passes on the first pass (no Phase 5 round-trip) is the step-1 test result still valid.
6. If all pass → read `bundled-skills/finishing-a-development-branch/SKILL.md` and follow its instructions for branch management

The `finishing-a-development-branch` skill skips its own test verification **only when Phase 6+7 had no Phase 5 round-trip** (tests still valid). If there WAS a round-trip (code changed post-test), finishing must NOT skip — re-run is mandatory.

**Terminal state**: "Phase 6+7 complete. Moving to Phase 8: Retrospective (复盘精读)." — Then immediately proceed to Phase 8.

### 🔴 Sequential Mode

**Phase 6 — Verification & Review** (independent gate):
1. Puppeteer frontend validation if UI exists. If `is_frontend=true`, also cross-check the screenshot against `design-system/<project-slug>/MASTER.md` anti-patterns section — report any violation before proceeding
2. Run verify skill + code-review skill
3. Check spec document updates
4. Gate: review not passed → back to Phase 5

**Terminal state**: "Phase 6 complete. Moving to Phase 7: Branch Completion." — Then immediately proceed to Phase 7.

**Phase 7 — Branch Completion**: Read `bundled-skills/finishing-a-development-branch/SKILL.md` and follow its instructions. It runs its own test verification as a separate gate, then presents branch options.

**Terminal state**: "Phase 7 complete. Moving to Phase 8: Retrospective (复盘精读)." — Then immediately proceed to Phase 8.

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

### 3. Gate — Understanding Check (Graduated by Complexity)

**The user must concretely cover the checkpoint questions for this feature's Phase 0 complexity before moving on.** This is not a test — it's a learning conversation. Concreteness is the bar, not correctness-on-first-try: if any answer is vague ("差不多" / "就是那个"), walk through that part again with different angles. This is coverage, not a quiz.

Gate strictness scales with complexity — the same principle that governs every other gate in this workflow (🟢 fast lane runs lighter gates; see Rollback → "Different complexity levels have different gate strictness"):

| Complexity | Checkpoints (cumulative — each level is a superset of the one above) | All must be concrete |
|------------|-------------------------------------------------------------------|---------------------|
| 🟢 | **Q1 主链 (Main chain)**: trace the main chain this change touches — backend (Controller→Service→Mapper→SQL→Database) or frontend (Component→State→API→Response→UI) — one sentence of responsibility per layer | Q1 |
| 🟡 | 🟢 + **Q2 关键代码 (Key code)**: which code is core logic, and *why* designed this way (not just "what it does") + **Q3 数据流 (Data flow)**: follow one piece of data end-to-end, entry → persist/render | Q1 + Q2 + Q3 |
| 🔴 | 🟡 + **Q4 排错 (Debugging)**: if this feature breaks, which layer do you investigate first and why | Q1 + Q2 + Q3 + Q4 |

**"Concrete" means**: the answer names a specific layer/file/function and states its responsibility or rationale — not a hand-wave. A vague answer on any required checkpoint → re-walk that part (keep the learning-conversation spirit). Only when every required checkpoint is concretely covered is the gate passed.

**Terminal state**: "Phase 8 complete. Feature fully understood at <🟢/🟡/🔴> level. Ready for next request." — This is the true end of the workflow for this request.

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

Every phase ends with a standard declaration. These declarations are **log announcements, not stop points** — after announcing, immediately proceed to the next phase within the same turn. The only gates that pause for user input are: Phase 0 classification confirmation, Phase 1 design approval, and Phase 8 understanding check.

| Flow | Phase 0 → | Phase 1 → | Phase 2 → | Phase 3+4/3 → | Phase 4 → | Phase 5 → | Phase 6+7/6 → | Phase 7 → |
|------|-----------|-----------|-----------|----------------|-----------|-----------|----------------|-----------|
| Bug | - | - | - | - | - | 6+7 | 8 | - |
| 🟢 | 1Lite | 2Lite | 3+4 | 5 | 6+7 | 8 | - | - |
| 🟡 | 1 | 2 | 3+4 | 5 | 6+7 | 8 | - | - |
| 🔴 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |

**Declaration format**: "Phase [N] complete. Moving to Phase [N+1]: [Name]." — Then immediately execute Phase [N+1].

---

## Conflict Resolution Rules (Summary)

The full 17 rules with rationale are in `references/conflict-rules-full.md`. The essential ones:

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

All sub-skills are bundled within this skill's `bundled-skills/` directory. They are NOT installed globally — they are resolved by reading their SKILL.md files at invocation time (see Sub-Skill Resolution section).

| Skill | Phase | Resolution Path | Purpose |
|-------|-------|----------------|---------|
| `brainstorming` | Phase 1 | `bundled-skills/brainstorming/SKILL.md` | Design clarification |
| `writing-plans` | Phase 3 | `bundled-skills/writing-plans/SKILL.md` | Create execution plan |
| `using-git-worktrees` | Phase 4 | `bundled-skills/using-git-worktrees/SKILL.md` | Isolated workspace |
| `executing-plans` | Phase 5 | `bundled-skills/executing-plans/SKILL.md` | Execute plan with TDD |
| `finishing-a-development-branch` | Phase 6+7/7 | `bundled-skills/finishing-a-development-branch/SKILL.md` | Branch completion |
| `frontend-design` | Phase 1 | `bundled-skills/frontend-design/SKILL.md` | Design thinking & anti-default direction |
| `ui-ux-pro-max` | Phase 1 | `bundled-skills/ui-ux-pro-max/SKILL.md` | Design system generation (requires Python runtime) |

**If a bundled sub-skill file is missing**: The installation may be corrupt. Re-run the install script to restore the bundled-skills/ directory.

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
