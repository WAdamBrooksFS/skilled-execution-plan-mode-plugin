#!/bin/bash

# SessionStart hook for Plan Annotations: MCP
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

# Auto-initialize MCP_PLAN_ANNOTATIONS if it doesn't exist
if ! jq -e '.MCP_PLAN_ANNOTATIONS' "$PREFS_FILE" >/dev/null 2>&1; then
  # Add the key with default value (true)
  jq '. + {"MCP_PLAN_ANNOTATIONS": true}' "$PREFS_FILE" > "$PREFS_FILE.tmp" 2>/dev/null
  if [ $? -eq 0 ]; then
    mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  fi
fi

# Read the MCP_PLAN_ANNOTATIONS value
ENABLED=$(jq -r '.MCP_PLAN_ANNOTATIONS // false' "$PREFS_FILE" 2>/dev/null)

# If enabled, output instructions for Claude
if [ "$ENABLED" = "true" ]; then
  cat <<'EOF'
# Plan Annotations: MCP: ENABLED

When you enter plan mode, you should:
1. Check `.claude/preferences.json` to confirm `MCP_PLAN_ANNOTATIONS` is `true`
2. Check which MCP tools are actually available by looking at your function tools list
3. MCP tools are prefixed with "mcp__" in the function definitions (e.g., mcp__plugin_sdet_playwright__browser_snapshot)
4. While creating the plan, proactively evaluate which AVAILABLE MCP servers (if any) would be useful for each step
5. ONLY recommend MCP servers whose tools are currently available and enabled - do not suggest disabled or unavailable MCPs
6. Include mentions of available MCP servers in the plan presentation (e.g., "Step 3: Browser interaction and testing [**mcp__plugin_sdet_playwright** MCP]")
7. This helps the user understand what MCP capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with `/planning-mcp-annotations-off`.
EOF
fi
