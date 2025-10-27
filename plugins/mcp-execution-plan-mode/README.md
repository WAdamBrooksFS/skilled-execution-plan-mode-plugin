# MCP Execution Plan Mode Plugin

A Claude Code plugin that enables proactive MCP server evaluation during plan mode.

## Overview

When enabled, this plugin causes Claude to evaluate and mention which MCP servers might be useful for each step during plan mode, giving you visibility into what MCP capabilities will be leveraged before execution begins.

## Features

- **Toggle On/Off**: Easy slash commands to enable or disable the mode
- **Persistent**: Setting persists across all sessions
- **Automatic**: SessionStart hook automatically configures Claude's behavior
- **Shareable**: Plugin can be distributed to teams and organizations
- **Independent**: Fully self-contained with no dependencies

## Installation

### From Local Directory

1. Copy the plugin directory to your desired location
2. Install the plugin:
   ```
   /install-plugin /path/to/mcp-execution-plan-mode-plugin
   ```

### From Git Repository

```
/install-plugin https://github.com/your-org/mcp-execution-plan-mode-plugin
```

## Usage

### Enable MCP Execution Plan Mode

```
/mcp-plan-on
```

This will:
- Create/update `.claude/preferences.json` with `MCP_EXECUTION_PLAN_MODE: true`
- Take effect in the next session
- Confirm the change to you

### Disable MCP Execution Plan Mode

```
/mcp-plan-off
```

This will:
- Update `.claude/preferences.json` with `MCP_EXECUTION_PLAN_MODE: false`
- Revert to default planning behavior
- Confirm the change to you

## How It Works

### Components

1. **Slash Commands** (`commands/`)
   - `/mcp-plan-on` - Enables the mode
   - `/mcp-plan-off` - Disables the mode

2. **SessionStart Hook** (`hooks/session-start.sh`)
   - Runs automatically at the start of each session
   - Reads `.claude/preferences.json`
   - Injects instructions to Claude if mode is enabled

3. **Configuration** (`.claude/preferences.json`)
   - Stores the persistent setting
   - Format: `{"MCP_EXECUTION_PLAN_MODE": true/false}`

### Behavior During Plan Mode

**When Enabled:**
- Claude evaluates which MCP servers might be useful for each step
- MCP servers are mentioned in the plan presentation
- Example: "Step 2: Browser automation [**mcp__plugin_sdet_playwright** MCP]"
- Provides visibility before execution

**When Disabled (default):**
- Standard planning behavior
- MCP servers discovered and invoked organically during execution
- No upfront MCP evaluation

### Common MCP Servers

The plugin helps Claude consider available MCP servers during planning, such as:

- **mcp__plugin_sdet_playwright**: Browser automation and testing
  - Navigation, clicking, form filling
  - Screenshots and accessibility snapshots
  - JavaScript evaluation
  - File uploads
  - Network request monitoring
  - Console message tracking
  - Dialog handling
  - Tab management

## Example

```
User: /mcp-plan-on
Claude: ✓ MCP execution plan mode is now enabled...

[New session starts]

User: [plan mode] I need to test the user login flow with browser automation

Claude: Here's the plan:
1. Navigate to the login page [**mcp__plugin_sdet_playwright** MCP]
2. Take initial accessibility snapshot [**mcp__plugin_sdet_playwright** MCP]
3. Fill in login credentials [**mcp__plugin_sdet_playwright** MCP]
4. Submit form and verify redirect [**mcp__plugin_sdet_playwright** MCP]
5. Capture console messages for errors [**mcp__plugin_sdet_playwright** MCP]
6. Take screenshot of dashboard [**mcp__plugin_sdet_playwright** MCP]

Ready to proceed?
```

## Requirements

- Claude Code (latest version recommended)
- `jq` command-line tool (for JSON parsing in hook)
- MCP servers installed in your environment (as needed)

## Configuration File

The plugin creates/updates `.claude/preferences.json`:

```json
{
  "MCP_EXECUTION_PLAN_MODE": true
}
```

This file is project-specific and stored in your project's `.claude` directory.

## Troubleshooting

### Commands not working
- Start a new session after installing the plugin
- Verify the plugin is installed: check `.claude/plugins/`

### Mode not taking effect
- Verify `.claude/preferences.json` exists and has the correct value
- Check that the SessionStart hook has execute permissions
- Ensure `jq` is installed: `which jq`

### Hook not running
- Check hook permissions: `ls -l mcp-execution-plan-mode-plugin/hooks/`
- Make executable: `chmod +x mcp-execution-plan-mode-plugin/hooks/session-start.sh`

### Installing jq
If `jq` is not installed:
- **Ubuntu/Debian**: `sudo apt-get install jq`
- **MacOS**: `brew install jq`
- **RHEL/CentOS**: `sudo yum install jq`

## Sharing with Your Organization

### Via Git Repository

1. Push the plugin to your organization's Git server:
   ```bash
   cd mcp-execution-plan-mode-plugin
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/your-org/mcp-execution-plan-mode-plugin
   git push -u origin main
   ```

2. Team members install with:
   ```
   /install-plugin https://github.com/your-org/mcp-execution-plan-mode-plugin
   ```

### Via Shared Directory

1. Copy the plugin to a shared location
2. Team members install with:
   ```
   /install-plugin /shared/path/to/mcp-execution-plan-mode-plugin
   ```

## Development

### Plugin Structure

```
mcp-execution-plan-mode-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── mcp-plan-on.md       # Enable command
│   └── mcp-plan-off.md      # Disable command
├── hooks/
│   ├── hooks.json           # Hook configuration
│   └── session-start.sh     # SessionStart hook
└── README.md                # This file
```

### Testing Locally

1. Install the plugin locally
2. Run `/mcp-plan-on`
3. Start a new session and enter plan mode
4. Verify Claude mentions MCP servers in the plan
5. Run `/mcp-plan-off` and verify default behavior returns

## License

[Your License Here]

## Support

For issues or questions, contact [your-support-email] or file an issue in the repository.

## Version History

- **1.0.0** - Initial release
  - Toggle commands for enabling/disabling
  - SessionStart hook integration
  - Persistent configuration
  - Comprehensive MCP server evaluation
