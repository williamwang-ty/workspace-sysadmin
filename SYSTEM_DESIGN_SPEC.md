# 泛用型 macOS 运维数字员工 · 系统设计与架构规范
(Universal Sysops System Design & Implementation Spec)

> **版本归档**: 2.1 (2026-04-24) - 新增 Codex 适配层（默认 wrapper 模式）
> **目的**: 本文档作为 `sysops-universal` 项目的“架构总则”与“实现蓝图”，详细规范了如何在 Claude Code, Goose, Pi, Codex 等多个大模型 Agent 端无缝复用核心运维资产，防范“配置漂移”与架构降级。
> **参考蓝图**: [UNIVERSAL_ARCHITECTURE_PLAN.md](./UNIVERSAL_ARCHITECTURE_PLAN.md)

---

## 1. 核心设计理念 (Architecture Overview)

**“数据与机制解耦，一份核心资产，多端降级适配。”**

本项目将 AI 终端改造为一个**领域特定（Domain-Specific）、带安全硬限制、支持多端复用**的本地 macOS 运维数字员工。
整个系统遵循严格的“渐进式展开（Progressive Disclosure）”与“最小权限原则（PoLP）”。

### 1.1 核心目录结构与多端适配

```text
sysops-universal/
├── CLAUDE.md                   # [入口] Claude 专属主控系统提示词
├── .goosehints                 # [入口] Goose 专属系统提示词
├── AGENTS.md                   # [入口] Pi / Codex 共用主控系统提示词（agent 中立）
├── UNIVERSAL_ARCHITECTURE_PLAN.md # [蓝图] 架构目标与落地计划
│
├── 🔌 .goose/                     # [适配层] Goose 专属配置
│   └── recipes/                   # Goose 原生 YAML 工作流 (桥接 shared/ 资产)
├── 🔌 .claude/                    # [适配层] Claude 专属
│   ├── settings.json              # 物理 Hook 绑定 & 原生 / 命令桥接
│   ├── skills/                    # 🔗 软链接 -> ../shared/skills/
│   └── agents/                    # 🔗 软链接 -> ../shared/personas/
├── 🔌 .pi/                        # [适配层] Pi 专属配置
│   ├── skills/                    # 🔗 软链接 -> ../shared/skills/
│   └── prompts/                   # 🔗 软链接 -> ../shared/commands/
├── 🔌 .agents/                    # [适配层] Codex Skills 扫描目录
│   └── skills/                    # 🔗 软链接 -> ../shared/skills/
├── brewfile/
│   └── Brewfile                  # Homebrew 环境快照
│
└── 🧱 shared/                       # [核心资产层] (唯一真实数据源 SSOT)
    ├── rules/
    │   ├── core-instructions.md   # 核心工作流与角色准则
    │   └── safety-rules.md        # 全局不可逾越的安全红线
    ├── commands/                  # 各快捷指令的独立文件 (如 health.md)
    ├── sops/                      # 具体的纯文本处理流程 (原 runbooks)
    ├── skills/                    # 带有标准 Frontmatter 的技能文件 (真身)
    │   ├── SKILLS_INDEX.md        # 技能索引路由表 (专供 Goose 软路由使用)
    │   └── RECOMMEND_SKILLS_LIST.md # 社区优秀扩展能力推荐清单
    ├── personas/                  # 各类专员的设定文件 (真身)
    └── bin/
        ├── safe-wrapper.sh        # 全局统一的命令执行与拦截记录器
        └── doctor-check.sh        # 项目结构与桥接配置自检脚本
```

---

## 2. 五大核心组件复用规范 (The 5 Core Components)

所有的业务逻辑、SOP、安全红线都必须且只能在 `shared/` 目录下存在一份。各平台客户端通过不同的底层机制适配。

### 2.1 系统提示词 (System Prompts) 适配机制
作为每个 Agent 启动时获取上下文和行为边界的“第一入口”：
- **核心逻辑**: 所有平台入口文件的首要任务是**强制引导 Agent 去读取 `shared/rules/core-instructions.md` 与 `safety-rules.md`**，以此拉齐各端的行为基准。
- **Claude**: 原生识别并读取根目录 `CLAUDE.md`。
- **Goose**: 官方机制自动读取隐藏文件 `.goosehints`。
- **Pi**: 上下文工程机制自动识别根目录 `AGENTS.md`。
- **Codex**: 自动读取适用范围内的 `AGENTS.md` 指令；本项目以根目录 `AGENTS.md` 作为 Codex 主入口。

### 2.2 技能 (Skills) 共享机制
模块化的标准操作程序（SOP）。
- **真身存放**: `shared/skills/` 目录下维护标准的 `SKILL.md`。
- **Claude / Pi**: 利用软链接，执行 `ln -s ../shared/skills .claude/skills`。两端都会走底层物理扫描机制，完美享受大模型“自动理解前置 Frontmatter”的原生红利。
- **Codex**: 通过 `.agents/skills/` 软链接复用共享技能：`ln -s ../shared/skills .agents/skills`。每个 skill 需包含 `SKILL.md`（YAML frontmatter + description 字段），由 Codex 按技能描述进行发现与使用。
- **Goose**: 拒绝高成本的 MCP，采用“懒加载”策略。在 `.goosehints` 中埋点，要求 Goose 执行复杂操作前先查询 `shared/skills/SKILLS_INDEX.md`，自行完成能力的二次软路由。

### 2.3 拦截器 (Hooks) 与双重安全防线
- **软防线**: 提示词级别的 `shared/rules/safety-rules.md`，定义绝对禁区（如禁止改写 `/System`）。
- **硬防线与自动化 (真身存放)**: `shared/bin/safe-wrapper.sh`。该脚本负责 Bash ERE 正则阻断（防止 `rm -rf /`、拦截二次 shell / interpreter trampoline 等），并在执行后将日志追加入 `logs/YYYY-MM-DD.md`，在触发 `brew install/uninstall/tap` 时同步更新 `brewfile/Brewfile`；若导出失败，必须显式告警，不能静默吞掉。
- **Claude 适配**: 在 `.claude/settings.json` 中配置 `PreToolUse` 和 `PostToolUse` 物理钩子，拦截 stdin 传来的 JSON。
- **Codex 适配**: 默认不启用 lifecycle hooks，避免在 schema、matcher 与 feature flag 未充分验证前产生“假硬拦截”。Codex 通过 `AGENTS.md` 明确要求所有 shell 操作显式调用 `shared/bin/safe-wrapper.sh "<命令>"`。Hooks 若未来启用，必须先完成 feature flag、matcher 与 stdin JSON 兼容性验证。
- **Goose / Pi 适配**: 在全局提示词中确立铁律，所有 Shell 交互必须通过 `bash shared/bin/safe-wrapper.sh "命令"` 的 CLI 参数形式运行，实现无底层 Hook 的防飘移。

### 2.4 快捷指令 (Commands) 共享机制
将预设命令（如 `/health`, `/clean` 等）抽出为独立文件。
- **真身存放**: `shared/commands/` 下对应的 `.md` 文件。
- **Claude**: 原生 `settings.json` 中的 `customCommands` 配置为短指令，并提示 Claude 去读取对应 Markdown 文件。
- **Pi**: 利用软链接 `ln -s ../shared/commands .pi/prompts`，Pi 会原生地把 `/` 指令指向文件内容。
- **Codex**: 无原生自定义 slash command 机制。在 `AGENTS.md` 中约定：遇到 `/health`、`/clean` 等预设指令时，主动读取 `shared/commands/` 下对应的 Markdown 文件执行。
- **Goose**: 在 `.goose/recipes/` 下建立 `.yaml` 工作流桥接文件，在 `instructions` 字段中指向目标 Markdown。

### 2.5 角色专员 (Personas / Subagents) 共享机制
通过独立 Context 隔离，避免大模型“精神分裂”。
- **真身存放**: 存放在 `shared/personas/` 目录下（如 `installer.md`, `troubleshooter.md`, `cleanup-auditor.md`）。
- **Claude**: 通过软链接暴露给 `.claude/agents/`，继续享受物理隔离的真·子进程纯净体验。
- **Codex**: 通过 `AGENTS.md` 约定“原地角色扮演”——遇到排错、清理或专业安装请求时，主动读取 `shared/personas/` 下对应文件并带入角色视角。
- **Goose**: 通过指令让其主动启动隔离的 Subagent 并阅读 Persona。
- **Pi**: 在提示词中规定“原地角色扮演 (Role-Playing)”，遇到专业问题主动读取文件并带入角色红线。

---

## 3. 标准工作流协议 (Workflow Protocols)

未来如果通过提示词引导或增加新能力，必须遵循以下状态机流转：

### 3.1 问题修复流 (Fix Flow)
`接收报错` -> `执行系统资源快照 (Diagnostics)` -> `锁定日志上下文` -> `提出至少两个原因假设` -> `只读验证 (Read/Grep)` -> **`强制记录备份与回滚方案`** -> `修改配置 (通过 safe-wrapper)` -> `重启验证` -> `将修复过程提炼归档至 shared/sops/`

### 3.2 软件迭代流 (Lifecycle Flow)
`解析意图` -> `brew info 预检依赖与冲突` -> `请求安装授权` -> `通过 safe-wrapper 执行安装` -> `输出验证结果 (--version)` -> `(safe-wrapper 同步更新 Brewfile 与日志；失败必须显式告警)`

---

## 4. 防漂移管理原则 (Anti-Drift Principles)

1. **不可绕过安全出口**: 所有平台的大模型严禁直接使用底层 shell 进程，任何外部交互最终必须收束于 `shared/bin/safe-wrapper.sh` 以确保安全审计和状态落地。Claude 可通过物理 Hook 增强；Codex、Goose 和 Pi 默认通过提示词强约束执行。
2. **知识沉淀优先 (SOP First)**: 若同一类系统报错出现超过 2 次，AI 必须主动在 `shared/sops/` 中建立新的规程文件，而不是每次都靠大模型的泛化能力临时推理。
3. **架构变动约束**: 禁止在特定的 `.claude` / `.pi` / `.goose` / `.agents` 文件夹下存放真实的业务逻辑，必须沉淀至 `shared/` 并以链接/桥接形式挂载。
