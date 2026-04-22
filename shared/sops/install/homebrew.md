# SOP: 软件安装标准化流程 (Homebrew)

## 背景
通过 Homebrew 安装软件是 macOS 运维的核心。本 Runbook 确保安装过程安全、可控。

## 操作步骤

### 1. 软件检索
```bash
brew search <pkg_name>
brew info <pkg_name>
```
- 确认是 `formula` (CLI) 还是 `cask` (GUI)。
- 检查 `Caveats`（注意事项），如是否需要修改 PATH。

### 2. 环境预检查
- 检查是否已有旧版：`brew list --versions <pkg_name>`
- 检查冲突：是否有同名命令已在 PATH 中

### 3. 执行安装
```bash
brew install <pkg_name>  # 或 brew install --cask <pkg_name>
```

### 4. 后置配置
- 如果有 PATH 变更需求，备份并修改 `~/.zshrc`。
- 运行验证命令：`<cmd> --version`

### 5. 记录与备份
- 记录到 `logs/`
- 更新 Brewfile：`brew bundle dump --force --file=brewfile/Brewfile`

## 回滚方案
```bash
brew uninstall <pkg_name>
# 如果改了 .zshrc，还原备份
```
