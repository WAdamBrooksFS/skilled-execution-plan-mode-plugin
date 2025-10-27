#!/bin/bash

# SessionStart hook for Skilled Execution Plan Mode
# Checks .claude/preferences.json and injects context if the mode is enabled

PREFS_FILE=".claude/preferences.json"

# Create .claude directory and preferences file if they don't exist
if [ ! -f "$PREFS_FILE" ]; then
  mkdir -p ".claude"
  echo "{}" > "$PREFS_FILE"
fi

# Auto-initialize SKILLED_EXECUTION_PLAN_MODE if it doesn't exist
if ! jq -e '.SKILLED_EXECUTION_PLAN_MODE' "$PREFS_FILE" >/dev/null 2>&1; then
  # Add the key with default value (false)
  jq '. + {"SKILLED_EXECUTION_PLAN_MODE": false}' "$PREFS_FILE" > "$PREFS_FILE.tmp" 2>/dev/null
  if [ $? -eq 0 ]; then
    mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  fi
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
