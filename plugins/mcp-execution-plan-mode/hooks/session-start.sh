#!/bin/bash

# SessionStart hook for MCP Execution Plan Mode
# Checks .claude/preferences.json and injects context if the mode is enabled

# Check if jq is installed (required for JSON parsing)
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq is required but not installed." >&2
  echo "" >&2
  echo "Please install jq:" >&2
  echo "  Ubuntu/Debian: sudo apt-get install jq" >&2
  echo "  macOS:         brew install jq" >&2
  echo "  RHEL/CentOS:   sudo yum install jq" >&2
  echo "  Arch Linux:    sudo pacman -S jq" >&2
  echo "  Alpine:        apk add jq" >&2
  echo "" >&2
  echo "Or download from: https://stedolan.github.io/jq/download/" >&2
  exit 1
fi

PREFS_FILE=".claude/preferences.json"

# Create .claude directory and preferences file if they don't exist
if [ ! -f "$PREFS_FILE" ]; then
  mkdir -p ".claude"
  echo "{}" > "$PREFS_FILE"
fi

# Auto-initialize MCP_EXECUTION_PLAN_MODE if it doesn't exist
if ! jq -e '.MCP_EXECUTION_PLAN_MODE' "$PREFS_FILE" >/dev/null 2>&1; then
  # Add the key with default value (false)
  jq '. + {"MCP_EXECUTION_PLAN_MODE": false}' "$PREFS_FILE" > "$PREFS_FILE.tmp" 2>/dev/null
  if [ $? -eq 0 ]; then
    mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  fi
fi

# Read the MCP_EXECUTION_PLAN_MODE value
ENABLED=$(jq -r '.MCP_EXECUTION_PLAN_MODE // false' "$PREFS_FILE" 2>/dev/null)

# If enabled, output instructions for Claude
if [ "$ENABLED" = "true" ]; then
  cat <<'EOF'
# MCP Execution Plan Mode: ENABLED

When you enter plan mode, you should:
1. Check `.claude/preferences.json` to confirm `MCP_EXECUTION_PLAN_MODE` is `true`
2. While creating the plan, proactively evaluate which MCP servers (if any) would be useful for each step
3. Consider available MCP servers and their capabilities, such as:
   - **mcp__plugin_sdet_playwright__***: Browser automation tools (navigate, click, snapshot, screenshot, evaluate, form filling, file upload, network monitoring, etc.)
   - Any other MCP servers that are currently installed and available in the environment
4. Include mentions of applicable MCP servers in the plan presentation (e.g., "Step 3: Browser interaction and testing [**mcp__plugin_sdet_playwright** MCP]")
5. This helps the user understand what MCP capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with `/mcp-plan-off`.
EOF
fi
