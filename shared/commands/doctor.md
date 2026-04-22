对当前项目环境进行自检。请优先运行 `bash shared/bin/doctor-check.sh` 并按输出汇报结果。

检查项至少包括：
1. hooks 脚本的存在性、执行权限与 Bash 语法
2. `jq` 是否安装，以及 `.claude/settings.json` 是否为合法 JSON
3. `logs/`、`brewfile/`、`shared/` 下关键目录和文件是否存在
4. `shared/skills/`、`shared/personas/`、`shared/commands/` 的软链接桥接是否正常

如果发现缺失或异常，请直接给出修复命令；如果全部通过，请汇总成一份简短的健康报告。
