#!/bin/bash

# SessionStart hook for Plan Annotations: Skills
# Checks .claude/preferences.json and injects context if annotations are enabled

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

# Auto-initialize SKILLS_PLAN_ANNOTATIONS if it doesn't exist
if ! jq -e '.SKILLS_PLAN_ANNOTATIONS' "$PREFS_FILE" >/dev/null 2>&1; then
  # Add the key with default value (true)
  jq '. + {"SKILLS_PLAN_ANNOTATIONS": true}' "$PREFS_FILE" > "$PREFS_FILE.tmp" 2>/dev/null
  if [ $? -eq 0 ]; then
    mv "$PREFS_FILE.tmp" "$PREFS_FILE"
  fi
fi

# Read the SKILLS_PLAN_ANNOTATIONS value
ENABLED=$(jq -r '.SKILLS_PLAN_ANNOTATIONS // false' "$PREFS_FILE" 2>/dev/null)

# If enabled, output instructions for Claude
if [ "$ENABLED" = "true" ]; then
  cat <<'EOF'
# Skills Plan Annotations: ENABLED

When you enter plan mode, you should:
1. Check `.claude/preferences.json` to confirm `SKILLS_PLAN_ANNOTATIONS` is `true`
2. Check which skills are actually available by looking at the available_skills list in the Skill tool
3. While creating the plan, proactively evaluate which AVAILABLE skills (if any) would be useful for each step
4. ONLY recommend skills that are currently available and enabled - do not suggest disabled or unavailable skills
5. Include mentions of available skills in the plan presentation (e.g., "Step 2: Extract PDF data [**pdf** skill]")
6. This helps the user understand what capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with `/planning-skills-annotations-off`.
EOF
fi
