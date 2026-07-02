# dev-workflow

[中文文档](README.md)

An 8-Phase Mandatory Development Workflow for Claude Code — with complexity-based routing.

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
- 🟢🟡 merge Phase 3+4 (parallel) and Phase 6+7 (single pass) — saves time without losing safety
- 🔴 Complex projects keep all 8 phases with independent gates
- Bug fixes follow a 3-phase shortcut, with automatic upgrade if architectural scope is discovered

For the full 8-phase walkthrough, see [SKILL.md](SKILL.md); for complexity signals, Lite modes, merged phases, etc., see [references/](references/).

## Features

- **Complexity-based routing** — Phase 0 classifies your request and picks the right flow
- **Lite mode for simple changes** — 2-3 questions + inline confirmation, no heavy docs
- **Bug upgrade detection** — if a "simple bug" turns out to need architectural changes, the workflow forces a proper design process
- **Rollback on path change** — abandoned paths are cleaned up, no stale files left behind
- **Frontend design integration** — UI projects use `frontend-design` (thinking side) + `ui-ux-pro-max` (practice side) together; thinking side sets direction first, practice side materializes it
- **Execution budget (circuit breaker)** — when Phase 5's fail→back loop has no termination, ≥2 round-trips with no progression stops and asks the user instead of looping indefinitely
- **Complexity misjudgment rollback** — if Phase 5 reveals complexity was underestimated, all implemented code is rolled back and the flow restarts from Phase 0

## Prerequisites

- [Claude Code](https://claude.com/claude-code) CLI (v1.0+)
- Git
- [uv](https://docs.astral.sh/uv/) (for ui-ux-pro-max Python scripts, auto-installed by most systems)

Frontend design support is bundled — no separate installation needed.

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

### Manual Install

Copy this entire folder to `~/.claude/skills/dev-workflow/`. All sub-skills are read in place from `bundled-skills/` — you do **not** need to copy them to the global skills directory.

> ⚠️ The bundled sub-skills are customized versions with dual-mode (merged/sequential) support. The original Superpowers versions will NOT work with this workflow — their terminal state declarations don't match the merged-phase routing.

## Usage

Once installed, the skill triggers automatically when you make any development request in Claude Code. You can also explicitly invoke `/dev-workflow`.

**Example:**
```
You: "Add a dark mode toggle to settings"
→ Phase 0: New Feature, 🟢 Simple
→ Phase 1 Lite → 2 Lite → 3+4 → 5 → 6+7 → 8
```

## File Structure

```
dev-workflow/
├── SKILL.md                     ← Core orchestrator (8-phase routing + gates)
├── README.md                    ← Chinese documentation (default)
├── README.en.md                 ← English documentation (this file)
├── references/                  ← Detailed reference docs
│   ├── complexity-signals.md    ← Complexity signals (pre-work assessment)
│   ├── lite-modes.md            ← Phase 1/2 Lite streamlined flow
│   ├── merged-phases.md          ← Phase 3+4 parallel + 6+7 merged
│   ├── bug-path.md              ← Bug shortcut + upgrade flow
│   └── conflict-rules-full.md   ← Conflict resolution rules
└── bundled-skills/              ← 7 customized sub-skills (read in place)
    ├── brainstorming/SKILL.md   ← Phase 1 design
    ├── writing-plans/SKILL.md   ← Phase 3 planning
    ├── using-git-worktrees/SKILL.md ← Phase 4 workspace
    ├── executing-plans/SKILL.md ← Phase 5 execution
    ├── finishing-a-development-branch/SKILL.md ← Phase 6+7 finish
    ├── frontend-design/SKILL.md ← Frontend design thinking (thinking side)
    └── ui-ux-pro-max/           ← Frontend design system (practice side)
```

## Compatibility with CLAUDE.md

If you already have the 8-phase workflow defined in `~/.claude/CLAUDE.md`, this skill coexists with it. The skill's conflict resolution rules (see `references/conflict-rules-full.md`) take precedence on conflict. To avoid duplication, you can remove the workflow definition from CLAUDE.md and rely entirely on the skill.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Skill doesn't trigger | Make sure it's in `~/.claude/skills/dev-workflow/` and the name matches exactly |
| Phase handoff errors | You may have original Superpowers sub-skills installed. Replace with the customized versions from `bundled-skills/` |
| `ui-ux-pro-max` scripts fail | Ensure `uv` is installed; use `uv run <script>` instead of bare `python` |

## Acknowledgements

Built on these open-source projects:

- [obra/superpowers](https://github.com/obra/superpowers) — original sub-skills (MIT)
- [mattpocock/skills](https://github.com/mattpocock/skills) — directory structure inspiration (MIT)
- [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) — frontend design system (MIT)
- [anthropics/skills](https://github.com/anthropics/skills) — frontend-design thinking (Apache 2.0)

Full attributions in [ATTRIBUTION.md](ATTRIBUTION.md).

## License

[MIT](LICENSE) © 2026 Cheng xihang
