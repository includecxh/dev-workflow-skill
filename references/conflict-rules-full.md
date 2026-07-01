# Conflict Resolution Rules — Full Reference

These 17 rules resolve conflicts between this workflow, sub-skills, CLAUDE.md rules, and other configuration. When in doubt, these rules win.

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

## Rule 11: Frontend Skills Are Paired (Thinking + Practice)

For ANY frontend/UI project (regardless of 🟢🟡🔴 complexity), `frontend-design` and `ui-ux-pro-max` MUST be invoked together. Pure backend, CLI, or database projects do NOT trigger them.

**Judging "involves frontend"**: project has web pages/UI components/a frontend framework; user mentions pages/layouts/styles/interactions; stack includes React/Vue/Next.js/Svelte/etc.

- **`frontend-design` = Thinking side**: design philosophy, principles, anti-patterns, UX reasoning, copywriting → "why design it this way". Invoked first to set direction (Phase 1), and at Phase 6 for final review.
- **`ui-ux-pro-max` = Practice side**: design system, colors, typography, components, tech-stack adaptation → "how to build it". Invoked after frontend-design sets direction (Phase 1 design-system gen), at Phase 5 for stack guide, at Phase 6 for visual check.
- **Order**: Thinking side first → Practice side second. Never invoke only one for a frontend project. Even a 🟢 simple UI tweak requires both.

## Rule 12: (merged into Rule 11)

Rule 12 content (ui-ux-pro-max scope) merged into Rule 11. Kept as placeholder so Rule-number references below stay valid.

## Rule 13: Complexity Assessment Cannot Be Skipped

Phase 0 Step 2 (complexity assessment) is MANDATORY for all new projects, new features, and refactoring. It cannot be skipped, defaulted, or assumed based on past similar requests. Each request must be evaluated on its own merits.

The user has the right to override the assessment (e.g., "I know this looks 🟡 but I want to treat it as 🔴"), but the assessment itself must still happen.

## Rule 14: Merged Phases Cannot Be Split

When Phase 0 assesses 🟢 or 🟡:
- Phase 3+4 MUST run in parallel (not sequentially "for safety")
- Phase 6+7 MUST run as a combined pass (not split into separate gates)

Don't split merged phases "for safety" — wastes time without adding safety.

## Rule 15: Complex Projects Must Use All 8 Phases

When Phase 0 assesses 🔴:
- All 8 phases must run in sequence
- No phases can be merged (3+4 stay separate, 6+7 stay separate)
- No gates can be skipped

Don't skip or merge phases for 🔴 — cross-contamination risk between phases is real.

## Rule 16: (merged into Rule 11)

Rule 16 content (frontend skills paired) merged into Rule 11. Kept as placeholder so Rule-number references stay valid.

## Rule 17: Complexity Misjudgment Requires Rollback

If Phase 5 (or later) reveals that Phase 0's complexity assessment was wrong, the workflow MUST:

1. **Pause immediately** — stop all work
2. **Explain the misjudgment** to the user with specific evidence
3. **Confirm the new complexity level** with the user
4. **Roll back ALL code** implemented under the wrong assessment (worktree removal, git revert, etc.)
5. **Return to Phase 0** for re-classification and re-assessment
6. **Start fresh** — no carrying over code from the abandoned path

Don't skip rollback — continuing bypasses the gates the new complexity requires (full rationale in SKILL.md Rollback section).

Post-hoc misjudgment signals (discovered in Phase 5) live in SKILL.md Rollback section — this file covers pre-work (Phase 0 upfront) signals only.

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
| 🟢 UI tweak without frontend skills | Rule 11 | Must invoke both frontend-design + ui-ux-pro-max even for 🟢 |
| Phase 5 reveals complexity was underestimated | Rule 17 | Roll back all code, return to Phase 0, re-classify |
