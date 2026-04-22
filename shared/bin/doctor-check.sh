#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

OK_COUNT=0
WARN_COUNT=0
FAIL_COUNT=0
FIX_COUNT=0
FIXES=()

record_fix() {
    local fix="$1"
    local existing

    for existing in "${FIXES[@]:-}"; do
        if [ "$existing" = "$fix" ]; then
            return
        fi
    done

    FIXES+=("$fix")
    FIX_COUNT=$((FIX_COUNT + 1))
}

report_ok() {
    OK_COUNT=$((OK_COUNT + 1))
    printf '[OK] %s\n' "$1"
}

report_warn() {
    WARN_COUNT=$((WARN_COUNT + 1))
    printf '[WARN] %s\n' "$1"

    if [ $# -ge 2 ] && [ -n "$2" ]; then
        record_fix "$2"
    fi
}

report_fail() {
    FAIL_COUNT=$((FAIL_COUNT + 1))
    printf '[FAIL] %s\n' "$1"

    if [ $# -ge 2 ] && [ -n "$2" ]; then
        record_fix "$2"
    fi
}

resolve_symlink_target() {
    local link_path="$1"
    local link_dir target_dir target_name target

    link_dir="$(cd "$(dirname "$link_path")" && pwd)"
    target="$(readlink "$link_path")"
    target_dir="$(cd "$link_dir/$(dirname "$target")" && pwd)"
    target_name="$(basename "$target")"
    printf '%s/%s\n' "$target_dir" "$target_name"
}

check_dir() {
    local rel_path="$1"
    local abs_path="$PROJECT_ROOT/$rel_path"

    if [ -d "$abs_path" ]; then
        report_ok "Directory exists: $rel_path"
    else
        report_fail "Missing directory: $rel_path" "mkdir -p '$abs_path'"
    fi
}

check_file() {
    local rel_path="$1"
    local abs_path="$PROJECT_ROOT/$rel_path"

    if [ -f "$abs_path" ]; then
        report_ok "File exists: $rel_path"
    else
        report_fail "Missing file: $rel_path" "touch '$abs_path'"
    fi
}

check_executable() {
    local rel_path="$1"
    local abs_path="$PROJECT_ROOT/$rel_path"

    if [ ! -f "$abs_path" ]; then
        report_fail "Executable target is missing: $rel_path" "touch '$abs_path'"
        return
    fi

    if [ -x "$abs_path" ]; then
        report_ok "Executable bit present: $rel_path"
    else
        report_fail "Executable bit missing: $rel_path" "chmod +x '$abs_path'"
    fi
}

check_command() {
    local cmd="$1"
    local fix="$2"

    if command -v "$cmd" > /dev/null 2>&1; then
        report_ok "Command available: $cmd"
    else
        report_fail "Required command missing: $cmd" "$fix"
    fi
}

check_json() {
    local rel_path="$1"
    local abs_path="$PROJECT_ROOT/$rel_path"

    if [ ! -f "$abs_path" ]; then
        report_fail "JSON file missing: $rel_path" "touch '$abs_path'"
        return
    fi

    if jq . "$abs_path" > /dev/null 2>&1; then
        report_ok "Valid JSON: $rel_path"
    else
        report_fail "Invalid JSON: $rel_path" "jq . '$abs_path'"
    fi
}

check_bash_syntax() {
    local rel_path="$1"
    local abs_path="$PROJECT_ROOT/$rel_path"

    if [ ! -f "$abs_path" ]; then
        report_fail "Script missing for syntax check: $rel_path" "touch '$abs_path'"
        return
    fi

    if bash -n "$abs_path"; then
        report_ok "Bash syntax valid: $rel_path"
    else
        report_fail "Bash syntax invalid: $rel_path" "bash -n '$abs_path'"
    fi
}

check_symlink() {
    local rel_path="$1"
    local expected_link_target="$2"
    local abs_path="$PROJECT_ROOT/$rel_path"
    local link_dir expected_abs
    local resolved_abs

    link_dir="$(cd "$(dirname "$abs_path")" && pwd)"
    expected_abs="$(cd "$link_dir/$(dirname "$expected_link_target")" && pwd)/$(basename "$expected_link_target")"

    if [ ! -L "$abs_path" ]; then
        report_fail "Missing symlink: $rel_path" "ln -s '$expected_link_target' '$abs_path'"
        return
    fi

    if [ ! -e "$abs_path" ]; then
        report_fail "Broken symlink: $rel_path" "rm '$abs_path' && ln -s '$expected_link_target' '$abs_path'"
        return
    fi

    resolved_abs="$(resolve_symlink_target "$abs_path")"

    if [ "$resolved_abs" = "$expected_abs" ]; then
        report_ok "Symlink points to expected target: $rel_path -> $expected_link_target"
    else
        report_fail "Symlink drift detected: $rel_path -> $resolved_abs (expected $expected_abs)" "rm '$abs_path' && ln -s '$expected_link_target' '$abs_path'"
    fi
}

printf 'Sysops Project Doctor\n'
printf 'Project root: %s\n\n' "$PROJECT_ROOT"

check_dir "logs"
check_dir "brewfile"
check_dir "shared/bin"
check_dir "shared/commands"
check_dir "shared/personas"
check_dir "shared/rules"
check_dir "shared/skills"
check_dir "shared/sops"

check_file "brewfile/Brewfile"
check_file "shared/rules/core-instructions.md"
check_file "shared/rules/safety-rules.md"
check_file ".claude/settings.json"
check_file "UNIVERSAL_ARCHITECTURE_PLAN.md"

check_executable "shared/bin/safe-wrapper.sh"
check_executable "shared/bin/doctor-check.sh"
check_bash_syntax "shared/bin/safe-wrapper.sh"
check_bash_syntax "shared/bin/doctor-check.sh"

check_command "jq" "brew install jq"
check_json ".claude/settings.json"

check_symlink ".claude/skills" "../shared/skills"
check_symlink ".claude/agents" "../shared/personas"
check_symlink ".pi/skills" "../shared/skills"
check_symlink ".pi/prompts" "../shared/commands"

printf '\nSummary: %s OK, %s WARN, %s FAIL\n' "$OK_COUNT" "$WARN_COUNT" "$FAIL_COUNT"

if [ "$FIX_COUNT" -gt 0 ]; then
    local_index=1
    printf 'Suggested fixes:\n'

    for fix in "${FIXES[@]}"; do
        printf '%s. %s\n' "$local_index" "$fix"
        local_index=$((local_index + 1))
    done
fi

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi

exit 0
