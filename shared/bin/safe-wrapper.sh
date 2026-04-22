#!/usr/bin/env bash
# 全局统一的命令执行、策略拦截与审计记录器
# 支持两种调用模式：
# 1. Claude Code Hook 模式: 通过 stdin 传入 JSON。
# 2. Goose/Pi 软路由模式: 通过命令行参数直接传入要执行的命令。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).md"
BREWFILE_DIR="$PROJECT_ROOT/brewfile"
BREWFILE_PATH="$BREWFILE_DIR/Brewfile"

MODE="CLI"
CMD=""
INPUT=""
IS_POST=false
EXIT_CODE="n/a"
ACTION="${SAFE_WRAPPER_ACTION:-CLI command}"
REASON="${SAFE_WRAPPER_REASON:-未提供}"
ROLLBACK="${SAFE_WRAPPER_ROLLBACK:-待补充}"

mkdir -p "$LOG_DIR" "$BREWFILE_DIR"

append_log_entry() {
    local action="$1"
    local reason="$2"
    local command="$3"
    local exit_code="$4"
    local rollback="$5"

    {
        printf '\n'
        printf -- '- 时间: [%s]\n' "$(date +%H:%M:%S)"
        printf '  动作: %s\n' "$action"
        printf '  原因: %s\n' "$reason"
        printf '  命令: %s\n' "$command"
        printf '  退出码: %s\n' "$exit_code"
        printf '  回滚命令: %s\n' "$rollback"
    } >> "$LOG_FILE"
}

dump_brewfile_if_needed() {
    local trigger_cmd="$1"

    if [[ "$trigger_cmd" =~ (^|[[:space:];&|])(brew[[:space:]]+(install|uninstall|tap))([[:space:]]|$) ]]; then
        if ! command -v brew > /dev/null 2>&1; then
            echo "⚠️  Brewfile backup skipped: brew is not installed." >&2
            return 0
        fi

        if ! brew bundle dump --force --describe --file="$BREWFILE_PATH" > /dev/null 2>&1; then
            echo "⚠️  Brewfile backup failed: brew bundle dump --force --describe --file=\"$BREWFILE_PATH\"" >&2
            return 1
        fi
    fi
}

block_command() {
    local pattern="$1"

    echo "🚫 Hook blocked command: $CMD" >&2
    echo "Matched pattern: $pattern" >&2
    append_log_entry "${ACTION} (blocked)" "$REASON; policy matched: $pattern" "$CMD" "2" "$ROLLBACK"
    exit 2
}

# 检查 stdin 是否有输入，并且判断是否为 Claude Code 传来的 JSON。
# 只有在没有 CLI 参数时才进入 Hook 解析，避免吞掉普通管道输入。
if [ $# -eq 0 ] && [ -p /dev/stdin ]; then
    INPUT=$(cat)

    if ! command -v jq > /dev/null 2>&1; then
        echo "safe-wrapper hook mode requires jq." >&2
        exit 1
    fi

    if printf '%s' "$INPUT" | jq -e '.tool_input' > /dev/null 2>&1; then
        MODE="HOOK"
        CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // empty')

        if printf '%s' "$INPUT" | jq -e '.tool_response' > /dev/null 2>&1; then
            IS_POST=true
            EXIT_CODE=$(printf '%s' "$INPUT" | jq -r '.tool_response.exit_code // "n/a"')
            ACTION="${SAFE_WRAPPER_ACTION:-Claude Bash hook}"
            REASON="${SAFE_WRAPPER_REASON:-Claude Bash tool completed}"
            ROLLBACK="${SAFE_WRAPPER_ROLLBACK:-n/a}"
        else
            ACTION="${SAFE_WRAPPER_ACTION:-Claude Bash preflight}"
            REASON="${SAFE_WRAPPER_REASON:-Claude Bash tool preflight check}"
            ROLLBACK="${SAFE_WRAPPER_ROLLBACK:-n/a}"
        fi
    fi
fi

if [ "$MODE" = "CLI" ]; then
    if [ $# -gt 0 ]; then
        CMD="$1"
    else
        echo "Usage: $0 \"<command>\"" >&2
        exit 1
    fi
fi

[ -z "$CMD" ] && exit 0

if [ "$IS_POST" = true ]; then
    append_log_entry "$ACTION" "$REASON" "$CMD" "$EXIT_CODE" "$ROLLBACK"
    dump_brewfile_if_needed "$CMD" || true
    exit 0
fi

# PreToolUse Hook or CLI pre-check
DENY_PATTERNS=(
    'rm[[:space:]]+-rf?[[:space:]]+/([[:space:]]|$)'
    'rm[[:space:]]+-rf?[[:space:]]+~([[:space:]]|$)'
    'rm[[:space:]]+-rf?[[:space:]]+\*'
    'rm[[:space:]]+-r[[:space:]]*-f[[:space:]]+/([[:space:]]|$)'
    'rm[[:space:]]+-rf?[[:space:]]+\.\*([[:space:]]|$)'
    ':\(\)\{.*\};:'
    'dd[[:space:]]+if=.*of=/dev/'
    'mkfs\.'
    'diskutil[[:space:]]+erase'
    'csrutil[[:space:]]+disable'
    'spctl[[:space:]]+--master-disable'
    'sudo[[:space:]]+brew'
    'curl[[:space:]]+[^|]+\|[[:space:]]*(bash|sh|zsh)'
    'chown[[:space:]]+-R[[:space:]]+[^[:space:]]+[[:space:]]+/([[:space:]]|$)'
    'chmod[[:space:]]+-R[[:space:]]+777'
    '>[[:space:]]*/etc/'
    '(^|[;&|()[:space:]])(bash|sh|zsh|ksh|dash)[[:space:]]+-c([[:space:]]|$)'
    '[|][[:space:]]*(bash|sh|zsh|ksh|dash)([[:space:]]|$)'
    '(^|[;&|()[:space:]])env[[:space:]].*(bash|sh|zsh|ksh|dash)[[:space:]]+-c([[:space:]]|$)'
    '(^|[;&|()[:space:]])(python([0-9.]*)?|perl|ruby|node|php|lua)[[:space:]]+(-c|-e)([[:space:]]|$)'
    'osascript.*do shell script'
)

for pat in "${DENY_PATTERNS[@]}"; do
    if [[ "$CMD" =~ $pat ]]; then
        block_command "$pat"
    fi
done

if [ "$MODE" = "CLI" ]; then
    # 在隔离子 shell 中执行命令，避免在当前 shell 中 eval。
    set +e
    bash -lc "$CMD"
    EXIT_CODE=$?
    set -e

    append_log_entry "$ACTION" "$REASON" "$CMD" "$EXIT_CODE" "$ROLLBACK"
    dump_brewfile_if_needed "$CMD" || true
    exit "$EXIT_CODE"
fi

# PreToolUse hook allowed
exit 0
