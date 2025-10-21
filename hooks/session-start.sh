#!/bin/bash

# SessionStart hook for Skilled Execution Plan Mode
# Checks .claude/preferences.json and injects context if the mode is enabled

PREFS_FILE=".claude/preferences.json"

# Check if preferences file exists
if [ ! -f "$PREFS_FILE" ]; then
  exit 0
fi

# Read the SKILLED_EXECUTION_PLAN_MODE value
ENABLED=$(jq -r '.SKILLED_EXECUTION_PLAN_MODE // false' "$PREFS_FILE" 2>/dev/null)

# If enabled, output instructions for Claude
if [ "$ENABLED" = "true" ]; then
  cat <<'EOF'
# Skilled Execution Plan Mode: ENABLED

When you enter plan mode, you should:
1. Check `.claude/preferences.json` to confirm `SKILLED_EXECUTION_PLAN_MODE` is `true`
2. While creating the plan, proactively evaluate which skills (if any) would be useful for each step
3. Include mentions of skills in the plan presentation (e.g., "Step 2: Extract PDF data [**pdf** skill]")
4. This helps the user understand what capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with `/skilled-plan-off`.
EOF
fi
