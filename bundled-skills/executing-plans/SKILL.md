---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** This skill is Phase 5 of the 8-phase mandatory development workflow. After all tasks complete, hand back to the orchestrator (announce "Phase 5 complete, handing back"); the orchestrator drives Phase 6/6+7 onward. Do NOT invoke other skills or describe other phases yourself (Sub-Skill Boundary rule).

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified, announce: "Phase 5 complete. Handing back to orchestrator." Then stop. The orchestrator drives Phase 6+7 (verify & finish) or Phase 6 (🔴) per Phase 0's mode — do NOT describe other phases or invoke other skills yourself (Sub-Skill Boundary rule).

**If verification fails and the orchestrator returns you here to fix:** address only the failing items (back to Step 2), re-verify, then announce Phase 5 complete again. The orchestrator re-enters Phase 6/6+7 for re-verification — you do not drive that transition.

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly — **this trips the Phase 5 execution budget** (see main SKILL.md Phase 5 Core rules). The fail→back-to-Phase-5 path has no built-in termination, so when round-trips recur on ≥2 consecutive times with no progression, stop and ask the user rather than re-looping indefinitely.

  **Progression check** (runs each time you re-enter Phase 5 after a fail→back): read current state with two cheap, objective signals — TodoWrite `TaskList` (count `completed` tasks) and `git log --oneline` (count commits since Phase 5 started). Progression = EITHER grew since the last re-entry (OR-logic). No progression = BOTH flat. Backward motion (completed count drops — a task reopened) counts as no progression. Do NOT compare failure contents — "same failure" is a semantic guess; progression is observable from tool state. No history is stored: both signals are re-read fresh each re-entry, so no hallucination on remembered values.

  **When the budget trips, present the ABCD circuit-breaker prompt** — show business context, not skill internals (no "completed=X" or "round-trip" jargon):

  ```
  [段1 业务现状] We were working on <feature>. The last change was <business action>, but <symptom> is still unresolved.
  [段2 Claude's top guess] Most likely cause: <one-line cause>.
  [段3 Choose a direction]
    A. If <cause-A> → investigate <direction-A>
    B. If <cause-B> → investigate <direction-B>
    C. Neither fits → likely complexity misjudgment, roll back to Phase 0
    D. Don't commit to a direction yet — keep exploring possible causes with me
  ```
  (2 investigation options A/B + 1 escalation C + 1 explore-more D = max 4; Claude guides the exploration, doesn't offload judgment to the user.)

  **Outcome of triage** (see Rollback section in main SKILL.md for the rollback rows):
  - a. Root cause found → clear the trip count, resume Phase 5 with the fix
  - b. Direction changed → full rollback (token-cheaper than partial), then re-enter Phase 5 fresh
  - c. Complexity misjudged → full rollback, back to Phase 0
  - d. Flaky / environment → clear the trip count, fix environment / re-run

  **D semantics**: exploring is a means, not an end — after exploration you still land on A/B/C. The trip state stays active during D (not cleared); it only clears when an a/d outcome unblocks. Triage-without-result (e) is out of scope for this version.

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Upstream skills (already ran before this one):**
- **using-git-worktrees** — ensures the isolated workspace this skill executes in (Phase 4)
- **writing-plans** — creates the plan this skill executes (Phase 3)

Downstream phases (verify, branch completion, retrospective) are owned by the orchestrator — do not describe or invoke them from here.
