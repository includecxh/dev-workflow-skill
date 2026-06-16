# Conflict Resolution Rules — Full Reference

These 15 rules resolve conflicts between this workflow, sub-skills, CLAUDE.md rules, and other configuration. When in doubt, these rules win.

---

## Rule 1: This Workflow > Skill Auto-Trigger

If a sub-skill wants to fire out of order (e.g., brainstorming tries to trigger during Phase 5), the workflow's phase sequence takes precedence. Skills are invoked BY the workflow, not independently.

## Rule 2: This Workflow > Other CLAUDE.md Rules

If other rules in CLAUDE.md contradict this workflow (e.g., "always start with a prototype" vs "Phase 1 must complete before any code"), the workflow wins.

## Rule 3: Brainstorming Only Fires on New Requests

The brainstorming skill is only triggered for new projects and new features. Bug fixes, small changes, and refactoring do NOT trigger brainstorming.

## Rule 4: Grill Me / Spec Confirmation Only Fires in Phase 2

The Phase 2 specification confirmation (Grill Me) only runs after Phase 1 design approval. It does NOT run in parallel with brainstorming or skip ahead.

## Rule 5: Brainstorming Must Go Through Phase 2

After brainstorming completes, the workflow MUST go through Phase 2 (specification confirmation) before entering Phase 3 (planning). No direct jumps from design to implementation.

## Rule 6: TDD Only Inside Phase 5

The `tdd` skill is only used during Phase 5 (Execute Development). If someone asks for TDD at another phase, remind them to follow the workflow first.

## Rule 7: Diagnose Only Inside Phase 5 for Bugs

The `diagnose` skill is used when a bug is encountered during Phase 5 execution. It doesn't trigger at other phases. If a bug is discovered during Phase 6 verification, the workflow goes back to Phase 5 where diagnose can be used.

## Rule 8: Prototype Only Inside Phase 1

The `prototype` skill can be used during Phase 1 (brainstorming) if the user wants to explore an idea with a quick prototype. But the design approval gate still must be passed before moving to Phase 2.

## Rule 9: Format-Specific Skills Don't Disrupt the Flow

Skills like `claude-api` or other format-specific skills that handle specific file types don't change the 8-phase sequence. They can be used within phases as tools, but they don't alter the phase order.

## Rule 10: Auto-Memory Cannot Override This Workflow

If auto-memory records preferences like "last time we skipped Phase 2" or "the user prefers to skip worktrees", those preferences don't override mandatory workflow steps. The workflow is the authority.

## Rule 11: Frontend-Design Only for Frontend Projects

The `frontend-design` skill is only invoked when the project involves UI/frontend development. Pure backend, CLI, or database projects do NOT trigger it.

**Judging "involves frontend"**:
- Project has web pages, UI components, or a frontend framework
- User mentions pages, layouts, styles, or interactions
- Tech stack includes React/Vue/Next.js/Svelte/etc.

**When invoked**: During Phase 1 for design thinking, and during Phase 6 for final review.

## Rule 12: UI-UX-Pro-Max Only for Frontend Projects

Same conditions as Rule 11. The `ui-ux-pro-max` skill is invoked:
- During Phase 1: design system generation (after frontend-design sets the direction)
- During Phase 5: tech stack implementation guide
- During Phase 6: pre-delivery visual check

## Rule 13: Complexity Assessment Cannot Be Skipped

Phase 0 Step 2 (complexity assessment) is MANDATORY for all new projects, new features, and refactoring. It cannot be skipped, defaulted, or assumed based on past similar requests. Each request must be evaluated on its own merits.

The user has the right to override the assessment (e.g., "I know this looks 🟡 but I want to treat it as 🔴"), but the assessment itself must still happen.

## Rule 14: Merged Phases Cannot Be Split

When Phase 0 assesses 🟢 or 🟡:
- Phase 3+4 MUST run in parallel (not sequentially "for safety")
- Phase 6+7 MUST run as a combined pass (not split into separate gates)

The merging is a deliberate optimization, not a shortcut. Running them sequentially when they could be parallel wastes time without adding safety.

## Rule 15: Complex Projects Must Use All 8 Phases

When Phase 0 assesses 🔴:
- All 8 phases must run in sequence
- No phases can be merged (3+4 stay separate, 6+7 stay separate)
- No gates can be skipped

Complex projects need independent gates because the risk of cross-contamination between phases is real. The extra time is the cost of managing complexity.

---

## Conflict Resolution Priority Order

When multiple rules seem to conflict:

1. **Phase 0 classification** determines the flow path (highest priority)
2. **Phase gates** enforce the sequence within that path
3. **Skill trigger modes** control when sub-skills fire
4. **CLAUDE.md other rules** provide context but can't override the above
5. **Auto-memory preferences** are the weakest — suggestions only

## Practical Application

| Scenario | Which Rule | Resolution |
|----------|-----------|------------|
| User says "skip brainstorming, I know what I want" | Rule 5 | Phase 1 must still happen; Lite mode available for 🟢 |
| Auto-memory says "user prefers no worktrees" | Rule 10 | Worktree isolation is still required; consent can be asked |
| Brainstorming skill tries to invoke writing-plans directly | Rule 5 | Must go through Phase 2 first |
| User asks for TDD during Phase 2 | Rule 6 | Remind: TDD is for Phase 5; Phase 2 is spec confirmation |
| Bug fix turns into a feature | Bug upgrade rule | Return to Phase 0, re-classify, start fresh |
| 🟡 project but user wants all 8 phases | Rule 14 | Respect user's preference — upgrade to 🔴 handling |
