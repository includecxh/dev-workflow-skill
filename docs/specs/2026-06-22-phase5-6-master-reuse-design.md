# Phase 5/6 Standard Path — Wire ui-ux-pro-max MASTER.md Reuse

**Date**: 2026-06-22
**Audit finding**: #37b-2 (final piece of the #37 line)
**Complexity**: 🟡 standard
**Depends on**: PR #9 (37b-1, `--persist` mandate — guarantees MASTER.md exists)

## Problem

The standard (non-bug) path through Phase 5/6 has **zero connection to ui-ux-pro-max**. Phase 1 generates a full design system (~3300 tokens: colors, typography, style, anti-patterns) and — after PR #9 — persists it to `design-system/<slug>/MASTER.md`. But Phase 5 (execution) and Phase 6+7 (pre-delivery check) never read it. Either they re-run the search (wasting the Phase 1 work + tokens) or silently skip frontend-skill guidance entirely.

This violates CLAUDE.md rule 12, which expects ui-ux-pro-max to serve "Phase 5 技术栈指南 (--stack)" and "Phase 6 预交付检查".

## Design Decisions (confirmed with user)

### D1: Dual-track (Y) — read MASTER + run --stack

MASTER.md and `--stack` are **orthogonal responsibilities**, not overlapping:
- `MASTER.md` → *what it looks like* (design: colors, typography, style, anti-patterns)
- `--stack <stack>` → *how to build it in this stack* (implementation: html-tailwind / react / nextjs / ...)

Reading only MASTER (option X) would drop the stack-implementation guidance, misaligning with rule 12. So both are consumed.

### D2: --stack called once at Phase 5 entry

Calling `--stack` every TDD step accumulates tokens wastefully (most steps don't touch UI). Calling on-demand requires human judgment of timing. **Entry-once** is the balanced frequency: run once when entering Phase 5, keep the result in conversation for subsequent steps to reference.

### D3: Phase 6 checks anti-patterns via existing Puppeteer step

Phase 6+7 already has "Puppeteer frontend validation if UI exists" (step 2). **Enhance** it: after screenshot, cross-check the implementation against MASTER.md's `anti_patterns` section — does the built UI violate any anti-pattern the design system warned against?

Reuses the existing Puppeteer step (no new tooling). Anti-patterns is a natural check target because MASTER.md already generates that section, and violations are visually detectable from a screenshot.

## Spec — what changes

### Phase 5 (SKILL.md, standard path only — bug path untouched)

Add a **"Frontend skills for standard path"** block (parallel to the existing bug-path block at line 266), specifying:

1. Read `design-system/<project-slug>/MASTER.md` (exists per PR #9 mandate) — design principles, colors, typography, anti-patterns
2. Run ONE `--stack <stack>` search at entry (default `html-tailwind` if stack unspecified) — implementation guidance for the chosen stack; result stays in conversation for subsequent steps
3. Subsequent TDD steps reference both; do NOT re-run --design-system or --stack per step

Guarded by `is_frontend=true` (set in Phase 0 Step 3) AND non-bug path (Phase 5 standard entry, not bug entry). Lite 🟢 path: this block is N/A — Lite runs single `--domain` per the existing Lite exception.

### Phase 6+7 (SKILL.md, 🟢🟡 merged mode step 2; 🔴 Phase 6 step 1)

Enhance the Puppeteer frontend-validation step: after screenshot, cross-check against `design-system/<project-slug>/MASTER.md` anti-patterns section. Report any violation before declaring "all pass".

Guarded by `is_frontend=true` (so non-frontend projects skip both the screenshot and the check).

## Out of scope

- Bug path Phase 5: already handled by PR #6 (Lite-level single `--domain`)
- MASTER.md path correctness: PR #7 (docs) + PR #8 (generated content)
- `--persist` mandate: PR #9
- Actually wiring `--stack` default detection from project tech stack (future: infer stack from Phase 1 context rather than defaulting to html-tailwind)

## Self-check

- No placeholders: all three decisions (D1/D2/D3) are concrete with specific commands/sections
- No contradiction: Lite N/A stated; bug path untouched; standard path gets dual-track
- Coverage: Phase 5 entry (read + run) and Phase 6+7 check both addressed
- Dependency satisfied: relies on MASTER.md existing → guaranteed by PR #9 (merged to main)
