#!/bin/bash

# SessionStart hook for MCP Execution Plan Mode
# Checks .claude/preferences.json and injects context if the mode is enabled

PREFS_FILE=".claude/preferences.json"

# Check if preferences file exists
if [ ! -f "$PREFS_FILE" ]; then
  exit 0
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
