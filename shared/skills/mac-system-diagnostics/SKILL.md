---
name: mac-system-diagnostics
description: Use when the user asks for a system health check, reports that the Mac is "slow", or requests a "weekly checkup". Performs non-destructive diagnostic commands.
allowed-tools: Bash, Read
---

# macOS System Diagnostics (系统健康检查)

## 适用场景

- 用户说「我的 Mac 很慢」「做个检查」「周度体检」
- 系统出现卡顿、彩球、内存压力大
- 检查磁盘空间、网络配置、内核日志

## 标准流程

1. **资源快照**
	- CPU 负载：`top -l 1 -n 10 -stats pid,command,cpu,mem,user`
	- 内存状态：`vm_stat` (转换为 GB 易读格式), `sysctl hw.memsize`
	- 磁盘空间：`df -h`
2. **硬件/系统自检**
	- 系统版本：`sw_vers`
	- 电池/电源：`pmset -g batt`, `pmset -g assertions`
	- 磁盘健康：`diskutil list`, `diskutil info /`
3. **日志扫描**
	- 最近 10 分钟错误日志：`log show --last 10m --predicate 'eventType == logEvent AND eventMessage CONTAINS "error"' --style syslog`
4. **网络基线**
	- 延迟测试：`ping -c 3 8.8.8.8`
	- DNS 检查：`scutil --dns`
5. **生成报告**
	- 汇总 CPU/MEM/Disk 状态
	- 标识出异常进程（高 CPU 或高 Memory）
	- 给出优化建议（如：`brew cleanup`，清理缓存，重启某服务）

## 强制规则

- ⚠️ 仅使用只读诊断命令。
- ⚠️ 报告中应包含时间戳。
- ⚠️ 如果发现高负载进程，需明确指出其 PID 和路径。

## 常用片段

```bash
# 查看内存压力
memory_pressure

# 查看 IO 状态
iostat -w 1 -c 5

# 检查系统休眠阻止因素
pmset -g assertions
```
