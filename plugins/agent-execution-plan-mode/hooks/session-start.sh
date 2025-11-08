#!/bin/bash

# SessionStart hook for Agent Execution Plan Mode
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

# Auto-initialize AGENT_EXECUTION_PLAN_MODE if it doesn't exist
if ! jq -e '.AGENT_EXECUTION_PLAN_MODE' "$PREFS_FILE" >/dev/null 2>&1; then
  # Add the key with default value (true)
  jq '. + {"AGENT_EXECUTION_PLAN_MODE": true}' "$PREFS_FILE" > "$PREFS_FILE.tmp" 2>/dev/null
  if [ $? -eq 0 ]; then
    mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  fi
fi

# Read the AGENT_EXECUTION_PLAN_MODE value
ENABLED=$(jq -r '.AGENT_EXECUTION_PLAN_MODE // false' "$PREFS_FILE" 2>/dev/null)

# If enabled, output instructions for Claude
if [ "$ENABLED" = "true" ]; then
  cat <<'EOF'
# Agent Execution Plan Mode: ENABLED

When you enter plan mode, you should:
1. Check `.claude/preferences.json` to confirm `AGENT_EXECUTION_PLAN_MODE` is `true`
2. Determine which agents are actually available by checking enabled plugins in the environment
3. Built-in agents typically available: general-purpose, Explore, Plan
4. Additional agents are available if their plugins are enabled (e.g., sdet:* agents require the sdet plugin)
5. While creating the plan, proactively evaluate which AVAILABLE agents (if any) would be useful for each step
6. ONLY recommend agents that are currently available and enabled - do not suggest disabled or unavailable agents
7. Include mentions of available agents in the plan presentation (e.g., "Step 2: Explore codebase structure [**Explore** agent]")
8. This helps the user understand what agent capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with `/agent-plan-off`.
EOF
fi
