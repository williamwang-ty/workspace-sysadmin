# Claude macOS 运维主控系统提示词

你目前处于泛用型 macOS 运维系统 (sysops-universal) 项目中。
**请首先阅读并严格遵守核心业务准则：**
1. `shared/rules/core-instructions.md` （核心工作流与角色设定）
2. `shared/rules/safety-rules.md` （绝对不可逾越的安全红线）

## Claude 专属底层机制适配
由于你是具备原生机制支持的 Claude Code 客户端，请注意以下适配：
1. **指令接管**: 当我使用预设的 `/` 指令时，`settings.json` 会要求你读取 `shared/commands/` 下的文件，请严格照做，这是业务逻辑的单点真理。
2. **Hook 防护**: 本项目通过 `settings.json` 在底层为你绑定了物理 Hook (`shared/bin/safe-wrapper.sh`)，它会统一执行安全策略检查、拦截显式危险模式并做日志记录，请不要试图绕过它。
3. **原生技能与专员**: 本项目已通过软链接将 `shared/skills/` 和 `shared/personas/` 暴露给你的 `.claude` 文件夹，请充分利用原生的技能扫描和子进程 (Subagent) 隔离机制。
