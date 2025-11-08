# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Plugin Overview

**plan-annotate-agents** is a Claude Code plugin that enables proactive agent evaluation during plan mode. When enabled (default state), Claude will check which agents are available in the environment and mention them in plan presentations.

## How This Plugin Works

### SessionStart Hook Flow

1. **Hook Execution**: On each session start, `hooks/session-start-wrapper.sh` runs
2. **Platform Detection**: Wrapper detects PowerShell or Bash and routes to appropriate script
3. **Preference Initialization**: Script creates `.claude/preferences.json` if missing and auto-initializes `AGENTS_PLAN_ANNOTATIONS: true`
4. **Context Injection**: If enabled, outputs markdown instructions to Claude's context telling it to:
   - Determine which agents are available by checking enabled plugins
   - Consider built-in agents (general-purpose, Explore, Plan)
   - Check for plugin-provided agents (e.g., sdet:* agents require sdet plugin enabled)
   - Only recommend agents that are currently available and enabled
   - Mention agents in plan format: "Step X: Task description [**agent-name** agent]"

### Agent Discovery

The plugin tells Claude to dynamically discover available agents rather than using a hardcoded list:

**Built-in agents** (typically always available):
- `general-purpose` - Complex multi-step tasks, code search
- `Explore` - Fast codebase exploration, pattern matching
- `Plan` - Planning and strategy for complex tasks

**Plugin-provided agents** (availability depends on installed plugins):
- `sdet:*` - Requires sdet plugin to be enabled
- `mcp-specialist` - If available in environment
- Other custom agents from marketplace plugins

**Important:** The plugin NEVER maintains a hardcoded list of agents. It instructs Claude to check the environment dynamically.

### Command Implementations

**Three slash commands** modify `.claude/preferences.json`:

1. **/planning-agents-annotations-on** (`commands/planning-agents-annotations-on.md`)
   - Sets `AGENTS_PLAN_ANNOTATIONS: true`
   - Creates preferences file if missing
   - Confirms enablement to user

2. **/planning-agents-annotations-off** (`commands/planning-agents-annotations-off.md`)
   - Sets `AGENTS_PLAN_ANNOTATIONS: false`
   - Reverts to default planning behavior
   - Confirms disablement to user

3. **/planning-agents-annotations-cleanup** (`commands/planning-agents-annotations-cleanup.md`)
   - Removes `AGENTS_PLAN_ANNOTATIONS` key entirely
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
  "AGENTS_PLAN_ANNOTATIONS": true
}
```

**Important:** This file may be shared with other plugins. Always preserve other keys when modifying.

## Testing Changes

### Test Hook Scripts Directly

```bash
# Test Bash version
cd /path/to/plan-annotate-agents
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
/planning-agents-annotations-on
# Check .claude/preferences.json - should contain AGENTS_PLAN_ANNOTATIONS: true

/planning-agents-annotations-off
# Check .claude/preferences.json - should contain AGENTS_PLAN_ANNOTATIONS: false

/planning-agents-annotations-cleanup
# Check .claude/preferences.json - AGENTS_PLAN_ANNOTATIONS key should be removed
```

### Test Plan Mode Behavior

1. Enable plugin: `/planning-agents-annotations-on`
2. Start new session (hook runs automatically)
3. Enter plan mode and give a complex task
4. Verify Claude mentions available agents in brackets: "[**Explore** agent]"

## Making Changes

### Modifying Hook Behavior

If changing how the plugin detects or recommends agents:

1. Update both `session-start.sh` AND `session-start.ps1` (keep logic identical)
2. Modify the markdown instructions in the heredoc/here-string sections
3. **Never hardcode agent lists** - always instruct Claude to check environment dynamically
4. Test on both Bash and PowerShell platforms
5. Ensure line endings remain correct (.gitattributes enforces this)

### Why No Hardcoded Agent List

The plugin intentionally avoids maintaining a static list of agents because:
- Agent availability depends on which plugins are installed and enabled
- New agents can be added through marketplace plugins
- Built-in agents may change across Claude Code versions
- Dynamic discovery ensures recommendations are always accurate

Instead, the SessionStart hook instructions tell Claude HOW to discover agents at runtime.

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
  "name": "plan-annotate-agents",
  "commands": ["./commands/planning-agents-annotations-on.md", ...],
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
