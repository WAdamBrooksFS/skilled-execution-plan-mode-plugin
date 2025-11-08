# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Plugin Overview

**skilled-execution-plan-mode** is a Claude Code plugin that enables proactive skill evaluation during plan mode. When enabled (default state), Claude will check which skills are available in the environment and mention them in plan presentations.

## How This Plugin Works

### SessionStart Hook Flow

1. **Hook Execution**: On each session start, `hooks/session-start-wrapper.sh` runs
2. **Platform Detection**: Wrapper detects PowerShell or Bash and routes to appropriate script
3. **Preference Initialization**: Script creates `.claude/preferences.json` if missing and auto-initializes `SKILLED_EXECUTION_PLAN_MODE: true`
4. **Context Injection**: If enabled, outputs markdown instructions to Claude's context telling it to:
   - Check the `available_skills` list in the Skill tool
   - Only recommend skills that are currently available and enabled
   - Mention skills in plan format: "Step X: Task description [**skill-name** skill]"

### Command Implementations

**Three slash commands** modify `.claude/preferences.json`:

1. **/skilled-plan-on** (`commands/skilled-plan-on.md`)
   - Sets `SKILLED_EXECUTION_PLAN_MODE: true`
   - Creates preferences file if missing
   - Confirms enablement to user

2. **/skilled-plan-off** (`commands/skilled-plan-off.md`)
   - Sets `SKILLED_EXECUTION_PLAN_MODE: false`
   - Reverts to default planning behavior
   - Confirms disablement to user

3. **/skilled-plan-cleanup** (`commands/skilled-plan-cleanup.md`)
   - Removes `SKILLED_EXECUTION_PLAN_MODE` key entirely
   - If no other plugin preferences exist, deletes entire file
   - If other preferences exist, preserves them
   - Used before plugin uninstallation

### Cross-Platform Implementation

The plugin supports all Claude Code platforms through dual implementations:

**Bash Version** (`hooks/session-start.sh`):
- Requires `jq` for JSON parsing
- Uses LF line endings (enforced by .gitattributes)
- Checks `command -v jq` and provides helpful error if missing

**PowerShell Version** (`hooks/session-start.ps1`):
- No external dependencies (native JSON cmdlets)
- Uses CRLF line endings (enforced by .gitattributes)
- Uses `ConvertFrom-Json` and `ConvertTo-Json`

**Platform Wrapper** (`hooks/session-start-wrapper.sh`):
- POSIX sh script for maximum compatibility
- Checks for pwsh → powershell → bash in order
- Uses `${CLAUDE_PLUGIN_ROOT}` environment variable

### Configuration File

Stores state in `.claude/preferences.json` at project root:

```json
{
  "SKILLED_EXECUTION_PLAN_MODE": true
}
```

**Important:** This file may be shared with other plugins. Always preserve other keys when modifying.

## Testing Changes

### Test Hook Scripts Directly

```bash
# Test Bash version
cd /path/to/skilled-execution-plan-mode
bash hooks/session-start.sh

# Test PowerShell version
pwsh -ExecutionPolicy Bypass -File hooks/session-start.ps1

# Test wrapper (requires CLAUDE_PLUGIN_ROOT set)
export CLAUDE_PLUGIN_ROOT="$(pwd)"
sh hooks/session-start-wrapper.sh
```

### Test Commands

```bash
# In Claude Code session:
/skilled-plan-on
# Check .claude/preferences.json - should contain SKILLED_EXECUTION_PLAN_MODE: true

/skilled-plan-off
# Check .claude/preferences.json - should contain SKILLED_EXECUTION_PLAN_MODE: false

/skilled-plan-cleanup
# Check .claude/preferences.json - SKILLED_EXECUTION_PLAN_MODE key should be removed
```

### Test Plan Mode Behavior

1. Enable plugin: `/skilled-plan-on`
2. Start new session (hook runs automatically)
3. Enter plan mode and give a task
4. Verify Claude mentions available skills in brackets: "[**pdf** skill]"

## Making Changes

### Modifying Hook Behavior

If changing how the plugin detects or recommends skills:

1. Update both `session-start.sh` AND `session-start.ps1` (keep logic identical)
2. Modify the markdown instructions in the heredoc/here-string sections
3. Test on both Bash and PowerShell platforms
4. Ensure line endings remain correct (.gitattributes enforces this)

### Modifying Commands

If changing command behavior:

1. Update the relevant .md file in `commands/`
2. Commands are just markdown files with instructions for Claude
3. Test by running the slash command in a Claude Code session

### Cross-Platform Considerations

**Critical:** The `.gitattributes` file MUST enforce correct line endings:
- `*.sh text eol=lf` - Bash scripts need Unix endings
- `*.ps1 text eol=crlf` - PowerShell scripts need Windows endings

Breaking this will cause "command not found" or parsing errors on target platforms.

## Plugin Registration

This plugin is registered in `.claude-plugin/plugin.json`:

```json
{
  "name": "skilled-execution-plan-mode",
  "commands": ["./commands/skilled-plan-on.md", ...],
  "hooks": "./hooks/hooks.json"
}
```

The hooks.json file registers the SessionStart hook:

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "sh ${CLAUDE_PLUGIN_ROOT}/hooks/session-start-wrapper.sh"
      }]
    }]
  }
}
```

**Important:** Always use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths in hook commands.
