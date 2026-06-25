# dev-workflow

适用于 Claude Code 的 8 阶段强制开发流程 — 基于复杂度的智能路由。

每一个开发请求（新项目、新功能、重构、修 Bug）都会被分类，并路由到正确的阶段序列，每一步都有门控把关。不会跳过任何阶段，不会绕过任何门控。

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
- 🟢🟡 项目合并 Phase 3+4（并行执行）和 Phase 6+7（一次通过）— 省时间，不减安全
- 🔴 复杂项目保持完整 8 阶段，每个门控独立生效
- Bug 修复走 3 阶段快捷路径，但如果发现涉及架构级改动则自动升级

## 特性

- **基于复杂度的智能路由** — Phase 0 自动分类你的请求，选择正确的流程路径
- **简单改动的精简模式** — 2-3 个问题 + 内联确认，不需要写重型文档
- **Bug 升级检测** — 当"简单 Bug"实际上需要架构改动时，强制走完整设计流程
- **路径变更自动回滚** — 放弃的路径会被清理干净，不留残留文件
- **前端设计集成** — 任何涉及 UI 的项目自动调用 `frontend-design`（思想侧：设计哲学与原则）+ `ui-ux-pro-max`（实践侧：设计系统与实现），两者配合使用
- **终端状态契约** — 每个阶段以标准声明结束，确保阶段间交接不出错
- **复杂度误判回滚** — 如果 Phase 5 执行中发现复杂度被低估，已实现的代码必须全部回滚，从 Phase 0 重新开始

## 前置要求

- [Claude Code](https://claude.com/claude-code) CLI（v1.0+）
- Git
- [uv](https://docs.astral.sh/uv/)（用于 ui-ux-pro-max 的 Python 脚本，大多数系统会自动安装）

**前端设计支持已内置** — 无需额外安装。`ui-ux-pro-max` 技能包含在 `bundled-skills/` 中，`frontend-design` 设计思维内嵌在 brainstorming 技能中。

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

安装脚本会自动完成：
1. 复制 dev-workflow 主技能到 `~/.claude/skills/`
2. 复制所有 5 个内置子技能到 `~/.claude/skills/`
3. 安装前端设计技能 `ui-ux-pro-max`
4. 验证所有安装是否成功

### 手动安装

1. 将整个文件夹复制到 `~/.claude/skills/dev-workflow/`
2. 将 `bundled-skills/` 下的每个子文件夹复制到 `~/.claude/skills/`：
   ```
   bundled-skills/brainstorming/          → ~/.claude/skills/brainstorming/
   bundled-skills/writing-plans/          → ~/.claude/skills/writing-plans/
   bundled-skills/executing-plans/        → ~/.claude/skills/executing-plans/
   bundled-skills/using-git-worktrees/    → ~/.claude/skills/using-git-worktrees/
   bundled-skills/finishing-a-development-branch/ → ~/.claude/skills/finishing-a-development-branch/
   bundled-skills/ui-ux-pro-max/          → ~/.claude/skills/ui-ux-pro-max/
   ```

> ⚠️ **重要**：内置子技能是**定制版本**，支持双模式（合并/串行）。原版 Superpowers 子技能与本流程**不兼容** — 它们的终端状态声明与合并阶段路由不匹配。

## 使用方法

安装完成后，当你在 Claude Code 中发起任何开发请求时，技能会自动触发。你也可以显式调用：

```
/dev-workflow
```

### 示例流程

**Bug 修复：**
```
你："修复 iPhone SE 上的登录溢出问题"
→ Phase 0: Bug/小改动
→ Phase 5: 修复它
→ Phase 6+7: 验证 + 收尾
→ Phase 8: 复盘精读
```

**简单功能：**
```
你："在设置中添加暗色模式开关"
→ Phase 0: 新功能，🟢 简单
→ Phase 1 Lite: 2 个问题 + 内联设计
→ Phase 2 Lite: 仅确认受影响项
→ Phase 3+4: 计划 + 工作区（并行）
→ Phase 5: 执行开发
→ Phase 6+7: 验证 + 收尾
→ Phase 8: 复盘精读
```

**复杂项目：**
```
你："做一个多币种记账应用"
→ Phase 0: 新项目，🔴 复杂
→ Phase 1: 完整头脑风暴 + 设计文档
→ Phase 2: 完整规范确认（5 项）
→ Phase 3: 编写执行计划（串行）
→ Phase 4: 搭建工作区（串行）
→ Phase 5: 执行开发
→ Phase 6: 验证与审查（独立门控）
→ Phase 7: 分支收尾（独立门控）
→ Phase 8: 复盘精读
```

## 文件结构

```
dev-workflow/
├── SKILL.md                          ← 核心编排器（~310 行）
├── README.md                         ← 英文说明
├── README.zh-CN.md                   ← 中文说明（本文件）
├── ATTRIBUTION.md                    ← 第三方署名
├── LICENSE                           ← MIT 许可证
├── install.sh                        ← macOS/Linux 安装脚本
├── install.ps1                       ← Windows 安装脚本
├── references/                       ← 详细参考文档
│   ├── complexity-signals.md         ← 复杂度升级信号及示例
│   ├── lite-modes.md                 ← Phase 1 Lite + Phase 2 Lite 详情
│   ├── merged-phases.md              ← Phase 3+4 并行 + Phase 6+7 合并
│   ├── bug-path.md                   ← Bug 快捷路径 + 升级流程
│   └── conflict-rules-full.md        ← 17 条冲突解决规则
└── bundled-skills/                   ← 定制子技能（必需）
    ├── brainstorming/SKILL.md        ← 含 frontend-design 设计思维
    ├── writing-plans/SKILL.md
    ├── executing-plans/SKILL.md
    ├── using-git-worktrees/SKILL.md
    ├── finishing-a-development-branch/SKILL.md
    └── ui-ux-pro-max/               ← 前端设计系统（MIT，来自 nextlevelbuilder）
        ├── SKILL.md
        ├── data/                     ← 配色、字体、风格、UX 指南
        └── scripts/                  ← Python 搜索与设计系统生成脚本
```

## 8 阶段详解

### Phase 0：分类与评估

每个开发请求必须先经过分类，**没有例外**。

**Step 1 — 类型分类：**

| 类型 | 判断标准 | 入口 |
|------|---------|------|
| 新项目 | 从零开始，无现有代码 | Phase 1 |
| 新功能 | 在现有项目上增加模块/能力 | Phase 1 |
| 重构 | 改变结构但不改变行为 | Phase 2 |
| Bug / 小改动 | 修复已知问题，无需新设计 | Phase 5 |

**Step 2 — 复杂度评估：**

| 复杂度 | 判断标准 | 流程路径 |
|--------|---------|---------|
| 🟢 简单 | 单组件改动、需求明确、无新表/API、预估 < 1h | 快车道（6 阶段） |
| 🟡 标准 | 多组件功能、需设计讨论、有新 API/表、预估 1-4h | 标准道（6 阶段） |
| 🔴 复杂 | 新项目/大子系统、架构级决策、预估 > 4h | 完整道（8 阶段） |

### Phase 1：设计 — 调用 `brainstorming` 技能

- 🟢 精简模式：2-3 个快速问题 + 内联设计确认，无需独立设计文档
- 🟡🔴 标准模式：完整头脑风暴 → 多方案比较 → 分段展示设计 → 设计文档 → 用户审批
- **前端项目**：任何涉及 UI 的项目，无论复杂度，都必须配合调用 `frontend-design`（思想侧：设计哲学与原则，解决"为什么这样设计"）+ `ui-ux-pro-max`（实践侧：设计系统与实现，解决"怎么做出来"）。思想侧先定方向，实践侧再出方案
- **硬性门控**：设计未获批准前，绝不写代码

### Phase 2：规范确认

确认 5 项规范，锁定设计细节：
1. 数据模型（新增/修改的表、字段、约束）
2. 接口设计（API 路径、参数、响应格式）
3. 业务规则（状态流转、权限、边界条件）
4. 规范影响（是否需要更新现有规范文档）
5. 测试策略（关键路径、测试范围）

- 🟢 精简模式：仅确认受影响项，未受影响的标 N/A 跳过

### Phase 3+4：准备与计划

- 🟢🟡 **合并并行**：写计划 + 建工作区同时进行（CPU + I/O 天然互补）
- 🔴 **分开串行**：先写计划 → 审批 → 再建工作区

### Phase 5：执行开发 — 调用 `executing-plans` 技能

- TDD 红→绿→重构，每步验证后才标记完成
- 一次只做一个最小闭环
- 遇阻即停，不猜测

### Phase 6+7：验证与收尾

- 🟢🟡 **合并模式**：测试跑一次 → 代码审查 → 直接进入分支管理
- 🔴 **分开模式**：Phase 6 独立验证门控 → Phase 7 独立收尾门控

### Phase 8：复盘精读

- **代码精读**：讲清完整链路（Controller → Service → Mapper → SQL → 数据库变化）
- **知识提炼**：关键代码、知识点、关键词、常见错误、排错思路
- **无交互门控**：Claude 产出代码精读 + 知识提炼后直接宣告完成，不暂停、不要求用户复述证明理解

## 与 CLAUDE.md 的兼容性

如果你已经在 `~/.claude/CLAUDE.md` 中定义了 8 阶段流程，本技能可以与之共存。当两者冲突时，以技能的冲突解决规则为准（详见 `references/conflict-rules-full.md`）。

为避免重复，你可以从 CLAUDE.md 中移除流程定义，完全依赖本技能。

## 常见问题

| 问题 | 解决方案 |
|------|---------|
| 技能没有自动触发 | 确认技能目录为 `~/.claude/skills/dev-workflow/`，目录名必须完全匹配 |
| 阶段交接报错（如 "Phase 3+4" 未识别） | 可能安装了原版 Superpowers 子技能，替换为 `bundled-skills/` 中的定制版本 |
| `ui-ux-pro-max` 脚本执行失败 | 确认已安装 `uv` 用于 Python 运行时，使用 `uv run <脚本路径>` 而非直接 `python` |
| Worktree 创建失败 | 确认项目已初始化 git，using-git-worktrees 技能会降级为在当前目录工作 |

## 致谢

本项目基于以下开源项目构建，感谢它们的作者：

- [obra/superpowers](https://github.com/obra/superpowers) — 子技能的原始版本（MIT）
- [mattpocock/skills](https://github.com/mattpocock/skills) — 技能目录结构设计灵感（MIT）
- [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) — 前端设计系统（MIT）

完整的第三方署名和许可证文本请参阅 [ATTRIBUTION.md](ATTRIBUTION.md)。

## 许可证

[MIT](LICENSE) © 2026 Cheng xihang
