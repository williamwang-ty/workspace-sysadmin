---
name: homebrew-expert
description: Use when user asks to install, upgrade, uninstall, search, or troubleshoot macOS software via Homebrew, brew, brew cask, mas, or Brewfile. Also triggered on "brew" error messages.
allowed-tools: Bash(brew:*), Bash(mas:*), Read, Write
---

# Homebrew Expert（macOS 包管理专家）

## 适用场景

- 用户说「装 XXX」「升级 XXX」「卸 XXX」且目标是 macOS 第三方软件
- 用户提到 `brew` 相关报错（404、permission denied、SHA256 mismatch 等）
- 需要导入/导出 Brewfile

## 标准流程

1. **预检查**
	- `brew --version` 确认 Homebrew 可用
	- `brew search <pkg>` 确认包存在
	- `brew info <pkg>` 查看依赖、caveats、冲突
2. **给出计划**
	- 列出将执行的命令
	- 列出副作用（新增依赖、PATH 变动、需要重启 shell 等）
	- 列出回滚命令（`brew uninstall`、`brew pin` 等）
3. **执行**
	- 等待用户确认后，按顺序执行
	- 每条命令结束后报告退出码与关键输出
4. **验证**
	- 运行 `<cmd> --version` 或启动一次
	- 如果是 GUI 应用（cask），提示在 Launchpad 中检查
5. **记录**
	- 追加到 `logs/YYYY-MM-DD.md`
	- 如变更 Brewfile，运行 `brew bundle dump --force --file=brewfile/Brewfile`

## 强制规则

- ⚠️ 禁止 `sudo brew ...`（会破坏 Homebrew 权限）
- ⚠️ 遇到 "Permission denied" 时优先排查 `/opt/homebrew` 或 `/usr/local` 的 owner，不直接 chmod -R 777
- 遇到 SHA256 mismatch 先 `brew update && brew cleanup`，再重试
- 安装前若检测到同名旧版，先列出差异再征询意见

## 常用片段


# 健康检查

brew doctor

brew update

brew outdated

# 清理

brew cleanup -s

brew autoremove

# 备份/恢复

brew bundle dump --force --describe --file=brewfile/Brewfile

brew bundle --file=brewfile/Brewfile
