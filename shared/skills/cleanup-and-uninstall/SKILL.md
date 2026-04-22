---
name: cleanup-and-uninstall
description: Use when the user asks to "cleanup", "uninstall", or "free up disk space". Specialized in finding residual files, caches, and system junk.
allowed-tools: Bash, Read, Grep
---

# Cleanup & Uninstall (清理与深度卸载)

## 适用场景

- 用户说「清理一下」「卸载 XXX 并清干净」「没空间了」
- 需要查找软件卸载后的残留 `.plist`、`Application Support` 目录
- 需要清理系统日志和各种包管理器的缓存

## 标准流程

1. **识别目标**
	- 确认是特定软件卸载还是通用系统清理
2. **扫描残留 (只读)**
	- 扫描路径：
		- `~/Library/Application Support/`
		- `~/Library/Caches/`
		- `~/Library/Preferences/`
		- `~/Library/LaunchAgents/`
		- `/Library/LaunchDaemons/`
	- 查找关键词匹配的文件/文件夹
3. **空间审计**
	- 列出占用空间最大的前 10 个目录/文件
4. **提出计划**
	- 列出建议删除的清单（路径、大小、用途）
	- 区分「安全可删」和「风险操作」
5. **执行清理**
	- **必须等待用户逐项确认**
	- 使用 `rm` (或 `sudo rm` 如果必要并解释原因)
6. **结果统计**
	- 报告共释放了多少空间

## 强制规则

- ⚠️ 禁止清理系统核心目录（如 `/System`）。
- ⚠️ 严禁清理 `~/Library/Keychains`、`~/Library/Mail` 等敏感目录。
- ⚠️ 对不确定的残留文件，建议用户先移动到垃圾桶而不是直接 `rm`。

## 常用片段

```bash
# 查找特定 App 的残留
find ~/Library -iname "*AppKeywords*"

# 清理 Homebrew 缓存
brew cleanup -s

# 列出大文件
du -sh ~/* | sort -rh | head -n 10
```
