# dev-workflow

[English](README.en.md)

适用于 Claude Code 的 8 阶段强制开发流程 — 基于复杂度的智能路由。

每一个开发请求（新项目、新功能、重构、修 Bug）都会被分类，并路由到正确的阶段序列，每一步都有门控把关。不跳过阶段，不绕过门控。

## 工作原理

```
请求到达
       │
  Phase 0: 分类 + 评估复杂度
       │
       ├─ Bug/小改动 ──────→ 5 → 6+7 → 8        (3 阶段)
       ├─ 🟢 简单 ──→ 1Lite → 2Lite → 3+4 → 5 → 6+7 → 8  (6 阶段)
       ├─ 🟡 标准 ──→ 1    → 2    → 3+4 → 5 → 6+7 → 8     (6 阶段)
       └─ 🔴 复杂 ──→ 1    → 2    → 3  → 4 → 5 → 6 → 7 → 8  (8 阶段)
```

**核心优化：**
- 🟢🟡 合并 Phase 3+4（并行）和 Phase 6+7（一次通过）— 省时不减安全
- 🔴 复杂项目保持完整 8 阶段，每个门控独立生效
- Bug 修复走 3 阶段快捷路径，发现架构级改动则自动升级

8 阶段详解见 [SKILL.md](SKILL.md)，复杂度信号、Lite 模式、合并阶段等细则见 [references/](references/)。

## 特性

- **复杂度智能路由** — Phase 0 自动分类，选择正确流程路径
- **简单改动精简模式** — 2-3 问题 + 内联确认，不写重型文档
- **Bug 升级检测** — "简单 Bug" 实需架构改动时，强制走完整设计流程
- **路径变更自动回滚** — 放弃的路径清理干净，不留残留
- **前端设计集成** — UI 项目自动调用 `frontend-design`（思想侧）+ `ui-ux-pro-max`（实践侧），思想先定方向、实践再出方案
- **执行预算熔断** — Phase 5 失败路径无终止时，≥2 次无推进即停下问用户，不无限循环
- **复杂度误判回滚** — Phase 5 发现复杂度被低估，已实现代码全部回滚，从 Phase 0 重新开始

## 前置要求

- [Claude Code](https://claude.com/claude-code) CLI（v1.0+）
- Git
- [uv](https://docs.astral.sh/uv/)（用于 ui-ux-pro-max 的 Python 脚本，多数系统自动安装）

前端设计支持已内置，无需额外安装。

## 安装

### 快速安装（推荐）

**macOS / Linux：**
```bash
bash install.sh
```

**Windows（PowerShell）：**
```powershell
.\install.ps1
```

### 手动安装

将整个文件夹复制到 `~/.claude/skills/dev-workflow/` 即可。所有子技能在 `bundled-skills/` 下就地读取，**不需要**复制到全局 skills 目录。

> ⚠️ 内置子技能是定制版本，支持双模式（合并/串行）。原版 Superpowers 子技能与本流程不兼容 — 终端状态声明与合并阶段路由不匹配。

## 使用方法

安装后，在 Claude Code 中发起任何开发请求时技能会自动触发。也可显式调用 `/dev-workflow`。

**示例：**
```
你："在设置中添加暗色模式开关"
→ Phase 0: 新功能，🟢 简单
→ Phase 1 Lite → 2 Lite → 3+4 → 5 → 6+7 → 8
```

## 文件结构

```
dev-workflow/
├── SKILL.md                     ← 核心编排器（8 阶段路由 + 门控）
├── README.md                    ← 中文说明（本文件）
├── README.en.md                 ← 英文说明
├── references/                  ← 详细参考文档
│   ├── complexity-signals.md    ← 复杂度信号（事前评估）
│   ├── lite-modes.md            ← Phase 1/2 Lite 精简流程
│   ├── merged-phases.md         ← Phase 3+4 并行 + 6+7 合并
│   ├── bug-path.md              ← Bug 快捷路径 + 升级
│   └── conflict-rules-full.md   ← 冲突解决规则
└── bundled-skills/              ← 7 个定制子技能（就地读取）
    ├── brainstorming/SKILL.md   ← Phase 1 设计
    ├── writing-plans/SKILL.md   ← Phase 3 计划
    ├── using-git-worktrees/SKILL.md ← Phase 4 工作区
    ├── executing-plans/SKILL.md ← Phase 5 执行
    ├── finishing-a-development-branch/SKILL.md ← Phase 6+7 收尾
    ├── frontend-design/SKILL.md ← 前端设计思维（思想侧）
    └── ui-ux-pro-max/           ← 前端设计系统（实践侧）
```

## 与 CLAUDE.md 兼容

若 `~/.claude/CLAUDE.md` 已定义 8 阶段流程，本技能可与之共存。冲突时以技能的冲突解决规则为准（见 `references/conflict-rules-full.md`）。为避免重复，可从 CLAUDE.md 移除流程定义，完全依赖本技能。

## 常见问题

| 问题 | 解决方案 |
|------|---------|
| 技能没自动触发 | 确认目录为 `~/.claude/skills/dev-workflow/`，名称完全匹配 |
| 阶段交接报错 | 可能装了原版 Superpowers 子技能，替换为 `bundled-skills/` 定制版 |
| `ui-ux-pro-max` 脚本失败 | 确认已装 `uv`，用 `uv run <脚本>` 而非直接 `python` |

## 致谢

本项目基于以下开源项目构建：

- [obra/superpowers](https://github.com/obra/superpowers) — 子技能原始版本（MIT）
- [mattpocock/skills](https://github.com/mattpocock/skills) — 目录结构灵感（MIT）
- [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) — 前端设计系统（MIT）
- [anthropics/skills](https://github.com/anthropics/skills) — frontend-design 设计思维（Apache 2.0）

完整署名见 [ATTRIBUTION.md](ATTRIBUTION.md)。

## 许可证

[MIT](LICENSE) © 2026 Cheng xihang
