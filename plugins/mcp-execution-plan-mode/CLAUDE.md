# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Plugin Overview

**mcp-execution-plan-mode** is a Claude Code plugin that enables proactive MCP (Model Context Protocol) server evaluation during plan mode. When enabled (default state), Claude will check which MCP servers are available in the environment and mention them in plan presentations.

## How This Plugin Works

### SessionStart Hook Flow

1. **Hook Execution**: On each session start, `hooks/session-start-wrapper.sh` runs
2. **Platform Detection**: Wrapper detects PowerShell or Bash and routes to appropriate script
3. **Preference Initialization**: Script creates `.claude/preferences.json` if missing and auto-initializes `MCP_EXECUTION_PLAN_MODE: true`
4. **Context Injection**: If enabled, outputs markdown instructions to Claude's context telling it to:
   - Check which MCP tools are available by examining the function tools list
   - Look for tools prefixed with `mcp__` (e.g., `mcp__plugin_sdet_playwright__browser_snapshot`)
   - Only recommend MCP servers whose tools are currently available and enabled
   - Mention MCP servers in plan format: "Step X: Task description [**mcp__server_name** MCP]"

### MCP Server Discovery

The plugin tells Claude to discover MCP servers by checking the available function tools:

**Detection Method:**
- MCP tools are prefixed with `mcp__` in Claude Code's function definitions
- Example: `mcp__plugin_sdet_playwright__browser_navigate`, `mcp__plugin_sdet_playwright__browser_snapshot`
- The prefix indicates these tools come from MCP servers
- Claude checks the function tools list at runtime to determine availability

**Common MCP Servers** (examples only - actual availability varies by environment):
- `mcp__plugin_sdet_playwright` - Browser automation and testing
  - Navigation, clicking, form filling
  - Screenshots and accessibility snapshots
  - JavaScript evaluation
  - Network monitoring

**Important:** The plugin doesn't hardcode MCP servers. It instructs Claude to check the `mcp__` prefixed tools dynamically.

### Command Implementations

**Three slash commands** modify `.claude/preferences.json`:

1. **/mcp-plan-on** (`commands/mcp-plan-on.md`)
   - Sets `MCP_EXECUTION_PLAN_MODE: true`
   - Creates preferences file if missing
   - Confirms enablement to user

2. **/mcp-plan-off** (`commands/mcp-plan-off.md`)
   - Sets `MCP_EXECUTION_PLAN_MODE: false`
   - Reverts to default planning behavior
   - Confirms disablement to user

3. **/mcp-plan-cleanup** (`commands/mcp-plan-cleanup.md`)
   - Removes `MCP_EXECUTION_PLAN_MODE` key entirely
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
  "MCP_EXECUTION_PLAN_MODE": true
}
```

**Important:** This file may be shared with other plugins. Always preserve other keys when modifying.

## Testing Changes

### Test Hook Scripts Directly

```bash
# Test Bash version
cd /path/to/mcp-execution-plan-mode
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
/mcp-plan-on
# Check .claude/preferences.json - should contain MCP_EXECUTION_PLAN_MODE: true

/mcp-plan-off
# Check .claude/preferences.json - should contain MCP_EXECUTION_PLAN_MODE: false

/mcp-plan-cleanup
# Check .claude/preferences.json - MCP_EXECUTION_PLAN_MODE key should be removed
```

### Test Plan Mode Behavior

1. Enable plugin: `/mcp-plan-on`
2. Start new session (hook runs automatically)
3. Enter plan mode and give a task involving browser automation or other MCP capabilities
4. Verify Claude mentions available MCP servers in brackets: "[**mcp__plugin_sdet_playwright** MCP]"

**Note:** You must have MCP servers installed and enabled in your Claude Code environment to see them mentioned.

## Making Changes

### Modifying Hook Behavior

If changing how the plugin detects or recommends MCP servers:

1. Update both `session-start.sh` AND `session-start.ps1` (keep logic identical)
2. Modify the markdown instructions in the heredoc/here-string sections
3. Remember: MCP detection is based on `mcp__` prefix in function tools list
4. Test on both Bash and PowerShell platforms
5. Ensure line endings remain correct (.gitattributes enforces this)

### Understanding MCP Detection

The plugin relies on Claude Code's naming convention for MCP tools:
- All MCP-provided tools are prefixed with `mcp__`
- The prefix is followed by the server/plugin identifier
- Example: `mcp__plugin_sdet_playwright__browser_click`
  - `mcp__` = MCP tool indicator
  - `plugin_sdet_playwright` = server identifier
  - `browser_click` = specific tool function

This convention allows Claude to identify which tools come from MCP servers without requiring external configuration or hardcoded lists.

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
  "name": "mcp-execution-plan-mode",
  "commands": ["./commands/mcp-plan-on.md", ...],
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
