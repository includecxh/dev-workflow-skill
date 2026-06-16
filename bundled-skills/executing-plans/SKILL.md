---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** This skill is Phase 5 of the 8-phase mandatory development workflow. After all tasks are complete, proceed to Phase 6 (Verification & Review) as defined in CLAUDE.md. Do NOT skip directly to Phase 7 or Phase 8 — Phase 6 is an independent gate.

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

After all tasks complete and verified:

**🟢🟡 Merged Mode (Phase 6+7 combined):**
- Announce: "Phase 5 complete. Moving to Phase 6+7: Verify & Finish."
- Proceed to the merged Phase 6+7 as defined in CLAUDE.md
- Tests run ONCE (covers both verification and merge-readiness check)
- After code-review passes, branch management options are presented directly (no separate Phase 7 test run)

**🔴 Sequential Mode (Phase 6 and Phase 7 separate):**
- Announce: "Phase 5 complete. Moving to Phase 6: Verification & Review."
- Proceed to Phase 6 (Verification & Review) as defined in CLAUDE.md
- Run verify skill, code-review skill, and Puppeteer validation as specified in Phase 6
- Phase 7 (finishing-a-development-branch) will run its own test verification as a separate gate

**Loop-back:** If Phase 6 (or Phase 6+7) verification fails, CLAUDE.md mandates returning to Phase 5 to fix the issues. When this happens:
1. Identify the specific failures from the verification
2. Return to Step 2 (Execute Tasks) and address only the failing items
3. Re-verify and announce Phase 5 complete again
4. Re-enter Phase 6 (or 6+7) for re-verification

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

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

**Required workflow skills:**
- **using-git-worktrees** - Ensures isolated workspace (Phase 4, runs before this skill)
- **writing-plans** - Creates the plan this skill executes (Phase 3, runs before Phase 4)
- **Phase 6 (CLAUDE.md)** - Verification & Review (independent gate, may loop back to this skill)
- **Phase 7 (CLAUDE.md)** - Branch completion (via finishing-a-development-branch, after Phase 6 passes)
