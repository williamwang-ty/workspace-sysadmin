---
name: fix-issue
description: Standardized SOP for troubleshooting and fixing technical issues. Use when the user reports a specific error, crash, or unexpected behavior.
allowed-tools: Bash, Read, Write, Grep
---

# Fix Issue (标准化排错 SOP)

## 适用场景

- 用户报告特定的报错信息或应用崩溃
- 权限错误、配置失效、依赖缺失
- 网络连接异常、服务启动失败

## 标准流程

1. **Step 1: 现象定义**
	- 复现步骤：确保能复现问题
	- 隔离范围：是个别 App 还是全局系统
2. **Step 2: 根因假设**
	- 提出至少 2 个可能的假设（如：权限问题、配置路径错误、依赖冲突）
	- 为每个假设准备验证命令
3. **Step 3: 验证假设**
	- 逐一执行验证命令（优先只读）
	- 排除不成立的假设
4. **Step 4: 制定修复方案**
	- 准备修复命令
	- **强制备份**：修改前执行 `cp path/to/config path/to/config.bak_$(date +%s)`
	- 提供回滚命令
5. **Step 5: 执行与验证**
	- 用户确认后执行修复
	- 再次验证问题是否解决
6. **Step 6: 复盘记录**
	- 将本次排错过程写入 `shared/sops/troubleshoot/`

## 强制规则

- ⚠️ 修改任何配置前必须先备份原文件。
- ⚠️ 禁止直接删除重要数据，优先使用 `mv` 到 `/tmp`。
- ⚠️ 方案必须按「临时缓解 -> 根因修复 -> 长期预防」三段式思考。

## 常用片段

```bash
# 检查权限
ls -leO <file_path>

# 追踪文件打开情况
sudo lsof -i :80
```
