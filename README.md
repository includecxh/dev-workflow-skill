# dev-workflow

8-Phase Mandatory Development Workflow for Claude Code — with complexity-based routing.

Every development request (new project, new feature, refactoring, or bug fix) is classified and routed through the right sequence of phases with proper gates. No phase is skipped, no gate is bypassed.

## How It Works

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

**Key optimizations:**
- 🟢🟡 projects merge Phase 3+4 (parallel) and Phase 6+7 (single pass) — saves time without losing safety
- 🔴 Complex projects keep all 8 phases separate with independent gates
- Bug fixes follow a 3-phase shortcut, with automatic upgrade if architectural scope is discovered

## Features

- **Complexity-based routing** — Phase 0 classifies your request and picks the right flow
- **Lite mode for simple changes** — 2-3 questions + inline confirmation, no heavy docs
- **Bug upgrade detection** — if a "simple bug" turns out to need architectural changes, the workflow forces a proper design process
- **Rollback on path change** — abandoned paths are cleaned up, no stale files left behind
- **Frontend design integration** — any project involving UI automatically uses `frontend-design` + `ui-ux-pro-max` skills
- **Terminal state contracts** — every phase ends with a standard declaration, ensuring correct handoff

## Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI (v1.0+)
- Git
- [uv](https://docs.astral.sh/uv/) (for ui-ux-pro-max Python scripts, auto-installed by most systems)

**Frontend design support is bundled** — no separate installation needed. The `ui-ux-pro-max` skill is included in `bundled-skills/`, and `frontend-design` thinking is built into the brainstorming skill.

## Installation

### Quick Install (Recommended)

**macOS / Linux:**
```bash
bash install.sh
```

**Windows (PowerShell):**
```powershell
.\install.ps1
```

This will:
1. Copy the dev-workflow skill to `~/.claude/skills/`
2. Copy all 5 bundled sub-skills to `~/.claude/skills/`
3. Verify installation

### Manual Install

1. Copy this entire folder to `~/.claude/skills/dev-workflow/`
2. Copy each sub-folder from `bundled-skills/` to `~/.claude/skills/`:
   ```
   bundled-skills/brainstorming/          → ~/.claude/skills/brainstorming/
   bundled-skills/writing-plans/          → ~/.claude/skills/writing-plans/
   bundled-skills/executing-plans/        → ~/.claude/skills/executing-plans/
   bundled-skills/using-git-worktrees/    → ~/.claude/skills/using-git-worktrees/
   bundled-skills/finishing-a-development-branch/ → ~/.claude/skills/finishing-a-development-branch/
   ```

> ⚠️ **Important**: The bundled sub-skills are **customized versions** with dual-mode (merged/sequential) support. The original Superpowers versions will NOT work correctly with this workflow — their terminal state declarations don't match the merged-phase routing.

## Usage

Once installed, the skill triggers automatically when you make any development request in Claude Code. You can also explicitly invoke it:

```
/dev-workflow
```

### Example Flows

**Bug fix:**
```
You: "Fix the login overflow on iPhone SE"
→ Phase 0: Bug/Small Change
→ Phase 5: Fix it
→ Phase 6+7: Verify + finish
→ Phase 8: Retrospective
```

**Simple feature:**
```
You: "Add a dark mode toggle to settings"
→ Phase 0: New Feature, 🟢 Simple
→ Phase 1 Lite: 2 questions + inline design
→ Phase 2 Lite: Affected-items-only confirmation
→ Phase 3+4: Plan + workspace (parallel)
→ Phase 5: Execute
→ Phase 6+7: Verify + finish
→ Phase 8: Retrospective
```

**Complex project:**
```
You: "Build a multi-currency bookkeeping app"
→ Phase 0: New Project, 🔴 Complex
→ Phase 1: Full brainstorming with design doc
→ Phase 2: Full spec confirmation (5 items)
→ Phase 3: Write plan (sequential)
→ Phase 4: Set up workspace (sequential)
→ Phase 5: Execute
→ Phase 6: Verify (independent gate)
→ Phase 7: Branch completion (independent gate)
→ Phase 8: Retrospective
```

## File Structure

```
dev-workflow/
├── SKILL.md                          ← Core orchestrator (~310 lines)
├── README.md                         ← This file
├── install.sh                        ← macOS/Linux installer
├── install.ps1                       ← Windows installer
├── references/
│   ├── complexity-signals.md         ← Complexity upgrade signals with examples
│   ├── lite-modes.md                 ← Phase 1 Lite + Phase 2 Lite details
│   ├── merged-phases.md              ← Phase 3+4 parallel + Phase 6+7 combined
│   ├── bug-path.md                   ← Bug fix shortcut + upgrade flow
│   └── conflict-rules-full.md        ← 15 conflict resolution rules
└── bundled-skills/                   ← Customized sub-skills (required)
    ├── brainstorming/SKILL.md        ← Includes frontend-design thinking
    ├── writing-plans/SKILL.md
    ├── executing-plans/SKILL.md
    ├── using-git-worktrees/SKILL.md
    ├── finishing-a-development-branch/SKILL.md
    └── ui-ux-pro-max/               ← Frontend design system (MIT, from nextlevelbuilder)
        ├── SKILL.md
        ├── data/                     ← Colors, typography, styles, UX guidelines
        └── scripts/                  ← Python search & design system generation
```

## Compatibility with CLAUDE.md

If you already have the 8-phase workflow defined in your `~/.claude/CLAUDE.md`, this skill coexists with it. The skill's conflict resolution rules (see `references/conflict-rules-full.md`) take precedence when there's a conflict.

To avoid duplication, you can remove the workflow definition from CLAUDE.md and rely entirely on the skill.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Skill doesn't trigger | Make sure the skill is in `~/.claude/skills/dev-workflow/` and the directory name matches exactly |
| Phase handoff errors (e.g., "Phase 3+4" not recognized) | You may have the original Superpowers sub-skills installed. Replace them with the bundled versions from `bundled-skills/` |
| `ui-ux-pro-max` scripts fail | Ensure `uv` is installed for Python runtime. Run `uv run <script-path>` instead of bare `python` |
| Worktree creation fails | Check git is initialized in your project. The using-git-worktrees skill will fall back to working in the current directory |

## License

MIT
