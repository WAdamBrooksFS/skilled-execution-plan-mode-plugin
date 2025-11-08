#!/bin/sh

# Cross-platform wrapper for SessionStart hook
# Detects platform and routes to appropriate script (PowerShell or Bash)

HOOK_DIR="${CLAUDE_PLUGIN_ROOT}/hooks"

# Detect platform and available shells
if command -v pwsh >/dev/null 2>&1; then
    # PowerShell Core is available (cross-platform)
    pwsh -ExecutionPolicy Bypass -File "$HOOK_DIR/session-start.ps1"
elif command -v powershell >/dev/null 2>&1; then
    # Windows PowerShell is available
    powershell -ExecutionPolicy Bypass -File "$HOOK_DIR/session-start.ps1"
elif command -v bash >/dev/null 2>&1; then
    # Bash is available (Linux, macOS, WSL, Git Bash)
    bash "$HOOK_DIR/session-start.sh"
else
    # Fallback: try with POSIX sh (may not work with bash-specific features)
    echo "Warning: Neither PowerShell nor bash found. Attempting with sh..." >&2
    sh "$HOOK_DIR/session-start.sh"
fi
