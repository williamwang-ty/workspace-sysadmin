# SOP: macOS 系统响应迟缓/性能排查

## 背景
用于诊断 CPU 占用高、彩球、内存溢出等通用性能问题。

## 诊断步骤

### 1. 资源分诊
- **CPU**: `top -u -n 5` 找出前五名耗电大户。
- **Memory**: `memory_pressure` 观察颜色（绿色正常，黄色压力，红色崩溃边缘）。
- **Disk**: `df -h` 确认剩余空间 > 10GB。

### 2. 进程透视
- 检查僵尸进程：`ps -axo pid,stat,comm | grep -E 'Z|T'`
- 检查高 IO 进程：`sudo iotop` (如果已安装) 或 `iostat`

### 3. 系统日志
- 观察最近一分钟的错误输出：
  `log show --last 1m --level error`

### 4. 外部因素
- 检查正在运行的系统维护任务：`tmutil status` (Time Machine 备份中？)
- 检查 Spotlight 索引状态：`mdutil -s /`

## 常见对策
- 重启高负载进程。
- `brew cleanup` 释放磁盘。
- 重启 `WindowServer` (慎重，会导致所有 GUI 重启)。
