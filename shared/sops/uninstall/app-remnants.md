# SOP: 应用深度清理与残留审计

## 背景
普通拖入垃圾桶无法彻底清除 macOS 应用。本 Runbook 用于彻底清除应用痕迹。

## 检查清单

### 1. 基础卸载
- 优先检查是否有自带的 Uninstaller 脚本。
- 如果是 Brew 安装：`brew uninstall --cask <app_name>`

### 2. 残留扫描路径 (检查以下目录)
- `~/Library/Application Support/<AppName>`
- `~/Library/Caches/<BundleID>`
- `~/Library/Preferences/<BundleID>.plist`
- `~/Library/Saved Application State/<BundleID>.savedState`
- `~/Library/Logs/<AppName>`

### 3. 服务启动项
- `~/Library/LaunchAgents/`
- `/Library/LaunchAgents/`
- `/Library/LaunchDaemons/`
- 检查这些目录下是否有相关的 `.plist` 文件。

## 风险提示
- 修改 `/Library` (系统级) 目录需要 `sudo`。
- 在删除 `LaunchAgents` 之前，建议先运行 `launchctl unload <path>`。
