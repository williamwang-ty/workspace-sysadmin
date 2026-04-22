# 社区优秀 Skill 推荐与按需安装指南

为了避免给 Agent 塞入过多的冗余上下文导致反应变慢或“精神分裂”，我们摒弃了传统的分类法，将社区优秀的扩展 Skill 重新整理为**“开箱即用”**与**“场景驱动”**两部分。

---

## 🚀 第一步：现在立刻建议安装的（核心底座）

这些 Skill 构成了 macOS 运维副驾的“基本功”，建议您在搭建好框架后**第一时间复制进来**。

| Skill 名称 | 为什么现在就需要它？ | 来源 | 链接 |
| --- | --- | --- | --- |
| **`bash-pro`** | **抹平 macOS 的暗坑**：macOS 自带的 `sed`、`grep` 等是 BSD 版本，和主流 Linux (GNU) 参数不同。AI 经常按 Linux 习惯写命令导致报错，这个 Skill 会强制它注意这些差异。 | sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/bash-pro) |
| **`bash-defensive-patterns`** | **保命符**：教导 AI 写出带有容错、`set -e`、安全路径校验和 dry-run 模式的 Shell，避免它一个手滑把系统删崩。 | sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/bash-defensive-patterns) |
| **`linux-troubleshooting`** | **授人以渔**：赋予 AI 一套系统的、结构化的排错流程（先查 CPU、再查 IO、后看网络），而不是像无头苍蝇一样乱试命令。 | sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/linux-troubleshooting) |
| **`error-detective`** | **查日志神器**：macOS 的日志非常庞杂，这个 Skill 能让 AI 更敏锐地在报错堆栈、`Console.app` 或 `/var/log` 中提取时间线和致命错误。 | sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/error-detective) |
| **`varlock-claude-skill`** | **防泄漏**：作为运维人员，终端里经常出现密码或 Token。它能约束 AI 不把密钥写进上下文或归档的 `runbooks` 里。 | wrsmith108 | [GitHub](https://github.com/wrsmith108/varlock-claude-skill) |

---

## 🧰 第二步：遇到以下情况，再按需安装

不要提前安装！只有当您**遇到了下面这些具体的麻烦事**，再把对应的 Skill 装进来。

### 📁 场景一：想要整理硬盘、归档杂乱的文件夹
- **`file-organizer`**: 专做智能文件整理，能帮你查重、建议合理的目录结构、清理废弃的旧文件。
  - 来源: ComposioHQ | [SKILL.md](https://github.com/ComposioHQ/awesome-claude-skills/tree/master/file-organizer)

### 📈 场景二：Mac 突然疯狂发热、风扇狂转、系统假死
- **`claude-monitor`**: 教 AI 如何快速采集系统性能快照（CPU/RAM/浏览器开销），快速抓住吃资源的内鬼。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/claude-monitor)
- **`performance-profiler`**: 如果是某个你开发的程序导致假死，用它生成 CPU 火焰图和内存泄漏分析。
  - 来源: alirezarezvani | [SKILL.md](https://github.com/alirezarezvani/claude-skills/tree/main/engineering/performance-profiler)

### 🌐 场景三：离奇的网络连不上、代理报错、DNS 污染
- **`network-engineer`**: 赋予 AI 深度网络诊断能力，教它正确使用 `tcpdump`、`Wireshark` 抓包分析和路由表排查。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/network-engineer)

### 🐳 场景四：要在 Mac 上折腾复杂的 Docker 容器环境
- **`docker-expert`**: 搞定在 Mac 上的容器化水土不服，自动帮你优化 Dockerfile、处理架构兼容性（Arm vs x86）、编排 Compose。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/docker-expert)

### 📜 场景五：要把刚做过的手工运维，固化成自动脚本或交接文档
- **`linux-shell-scripting`**: 提供现成的高质量 Shell 脚本模板，直接帮你把刚才敲的零散命令包装成完整的自动化任务。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/linux-shell-scripting)
- **`runbook-generator`**: 把你脑子里关于某个服务的“启动/停止/检查”经验，一键生成标准化的 Runbook MD 文档。
  - 来源: alirezarezvani | [SKILL.md](https://github.com/alirezarezvani/claude-skills/tree/main/engineering/runbook-generator)

### 🚨 场景六：发生严重操作失误（如误删库、服务宕机），需要快速止血并复盘
- **`incident-responder`**: 带入 SRE 专家视角，强迫 AI 不许慌，执行严格的 5 分钟分诊、P0 级止血操作，并在事后输出 Blameless 复盘报告。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/incident-responder)

### 💻 场景七：写了运维脚本需要上 CI/CD 自动化流水线
- **`shellcheck-configuration`**: 为你的运维脚本添加严格的静态分析门禁。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/shellcheck-configuration)
- **`github-actions-templates`**: 一键生成 GitHub Actions 模板，帮你做 macOS 矩阵测试。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/github-actions-templates)

### 🦠 场景八：怀疑电脑中毒、被植入恶意进程
- **`memory-forensics`**: 极其高阶的能力，指导 AI 配合特定工具进行 macOS 内存转储分析和恶意软件猎杀。
  - 来源: sickn33/antigravity | [SKILL.md](https://github.com/sickn33/antigravity-awesome-skills/tree/main/skills/memory-forensics)
