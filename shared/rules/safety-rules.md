# 安全与操作规则（Safety Rules）

本文件是 macOS 系统维护项目的**强制红线**，适用于所有 Skill、Hook、Subagent。

## 🚫 绝对禁止

1. 执行 `rm -rf /`、`rm -rf ~`、`rm -rf $UNSET_VAR`、`rm -rf *` 这类广域删除
2. 对 `/System`、`/private/var/db`、`/Library/Apple*` 做任何写入
3. 关闭 SIP（System Integrity Protection）、Gatekeeper、XProtect
4. 读取或导出 `~/.ssh/`、`~/.aws/credentials`、Keychain 条目内容
5. 在未确认的情况下执行 `curl … | bash`、`wget … | sh`
6. 用 `sudo` 运行 `brew`、`npm`、`pip`
7. 修改 `/etc/hosts` 且不备份

## ⚠️ 需要二次确认

以下动作在执行前必须把完整命令发给我，等我明确回复「执行」后才跑：

- 任何 `sudo` 命令
- 任何 `rm`、`mv` 目录操作
- `brew uninstall`、`brew cleanup -s`
- 修改 `~/.zshrc`、`~/.zprofile`、`/etc/paths*`
- 编辑 LaunchAgents / LaunchDaemons
- `diskutil`、`tmutil`、`pmset` 的写操作
- 任何触及网络代理 / DNS 配置的改动

## ✅ 默认允许

- 只读诊断：`top`、`ps`、`vm_stat`、`df`、`du`、`lsof`、`netstat`、`system_profiler`
- `brew search`、`brew info`、`brew list`、`brew doctor`、`brew outdated`、`brew update`
- `log show --last 1h …` 等只读日志查询
- 读取 `~/Library/Logs/`、`/var/log/` 下的日志文件

## 📝 记录要求

- 每执行一条「需要二次确认」的命令，必须同步写入 `logs/YYYY-MM-DD.md`
- 日志条目格式固定：**动作 / 原因 / 命令 / 退出码 / 回滚命令**
- 如果暂时无法确定原因或回滚命令，必须明确写 `未提供` / `待补充`，不能留空
