# Plan Annotations: MCP Plugin

A Claude Code plugin that enables proactive MCP server evaluation during plan mode.

## Overview

This plugin is **enabled by default** and causes Claude to evaluate and mention which available MCP servers might be useful for each step during plan mode. The plugin automatically detects which MCP servers are actually installed, available, and enabled in your environment, ensuring recommendations are accurate and actionable. This gives you visibility into what MCP capabilities will be leveraged before execution begins.

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
   /install-plugin /path/to/plan-annotate-mcp-plugin
   ```

### From Git Repository

```
/install-plugin https://github.com/your-org/plan-annotate-mcp-plugin
```

## Usage

### Default Behavior

This plugin is **enabled by default** upon installation. Claude will automatically evaluate and mention available MCP servers during plan mode without any configuration needed.

You can toggle the plugin on/off at any time using the commands below.

### Verify Installation (Bash Users Only)

Before enabling the plugin, Bash users should verify that `jq` is installed:

```bash
which jq
```

If the command returns a path (e.g., `/usr/bin/jq`), you're all set. If not found, see the "Installing jq" section in Requirements below.

**PowerShell users can skip this step** - no external dependencies are required.

### Enable Plan Annotations: MCP

```
/planning-mcp-annotations-on
```

This will:
- Create/update `.claude/preferences.json` with `MCP_PLAN_ANNOTATIONS: true`
- Take effect in the next session
- Confirm the change to you

### Disable Plan Annotations: MCP

```
/planning-mcp-annotations-off
```

This will:
- Update `.claude/preferences.json` with `MCP_PLAN_ANNOTATIONS: false`
- Revert to default planning behavior
- Confirm the change to you

## How It Works

### Components

1. **Slash Commands** (`commands/`)
   - `/planning-mcp-annotations-on` - Enables the mode
   - `/planning-mcp-annotations-off` - Disables the mode

2. **SessionStart Hook** (`hooks/session-start.sh`)
   - Runs automatically at the start of each session
   - Reads `.claude/preferences.json`
   - Injects instructions to Claude if mode is enabled

3. **Configuration** (`.claude/preferences.json`)
   - Stores the persistent setting
   - Format: `{"MCP_PLAN_ANNOTATIONS": true/false}`

### Behavior During Plan Mode

**When Enabled (default):**
- Plugin automatically detects which MCP servers are installed, available, and enabled
- Claude evaluates which AVAILABLE MCP servers might be useful for each step
- Only available/enabled MCP servers are considered - disabled MCPs are ignored
- MCP servers are mentioned in the plan presentation
- Example: "Step 2: Browser automation [**mcp__plugin_sdet_playwright** MCP]"
- Provides visibility before execution

**When Disabled:**
- Standard planning behavior
- MCP servers discovered and invoked organically during execution
- No upfront MCP evaluation

### Common MCP Servers

The plugin automatically detects which MCP servers are installed and enabled in your environment. It checks the available MCP tools (prefixed with `mcp__` in the function list) to determine what's actually available.

During plan mode, the plugin helps Claude consider available MCP servers. Common examples include:

- **mcp__plugin_sdet_playwright**: Browser automation and testing
  - Navigation, clicking, form filling
  - Screenshots and accessibility snapshots
  - JavaScript evaluation
  - File uploads
  - Network request monitoring
  - Console message tracking
  - Dialog handling
  - Tab management

**Important:** Only MCP servers that are installed and enabled in your environment will be considered during planning. The list above shows common examples, but actual availability depends on your Claude Code configuration and installed plugins.

## Example

```
User: /planning-mcp-annotations-on
Claude: ✓ MCP plan annotations is now enabled...

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

### All Platforms
- Claude Code (latest version recommended)
- MCP servers installed in your environment (as needed)

### Platform-Specific Requirements

**Windows:**
- No additional dependencies required
- Uses native PowerShell for hook execution

**Linux / macOS / WSL / Git Bash:**
- `jq` command-line tool (for JSON parsing in hook)

### Cross-Platform Support

This plugin automatically detects your platform and uses the appropriate script:
- **PowerShell** (Windows, or pwsh on any platform) - no external dependencies
- **Bash** (Linux, macOS, WSL, Git Bash) - requires jq

The plugin includes:
- `hooks/session-start.ps1` - PowerShell version (Windows-native)
- `hooks/session-start.sh` - Bash version (Unix-native)
- `hooks/session-start-wrapper.sh` - Platform detection wrapper

The wrapper automatically chooses the correct script based on available shells, ensuring seamless operation across all platforms.

### Runtime Dependency Checking

The plugin automatically checks for `jq` at the start of each Claude Code session (SessionStart hook). If `jq` is missing on Bash-based systems, you'll see a helpful error message with installation instructions in Claude's context at the beginning of your session.

**What happens if jq is missing:**
- The SessionStart hook detects the missing dependency
- An error message displays in Claude's session context
- The message includes platform-specific installation instructions
- You can install `jq` and start a new session to resolve the issue

**Example error message you might see:**
```
ERROR: jq is required but not installed.

Please install jq:
  Ubuntu/Debian: sudo apt-get install jq
  macOS:         brew install jq
  RHEL/CentOS:   sudo yum install jq
  Arch Linux:    sudo pacman -S jq
```

**Important notes:**
- PowerShell users will never see this error (no external dependencies needed)
- The error appears at session start, not during plugin installation
- The dependency check runs automatically every time a new session begins
- Once `jq` is installed, the error will not appear in future sessions

### Supported Environments

| Environment | Shell Used | External Dependencies | Status |
|------------|------------|----------------------|--------|
| Windows (native) | PowerShell | None | ✅ Fully Supported |
| Windows + WSL | Bash | jq | ✅ Fully Supported |
| Windows + Git Bash | Bash | jq | ✅ Fully Supported |
| Linux | Bash | jq | ✅ Fully Supported |
| macOS | Bash | jq | ✅ Fully Supported |
| PowerShell Core (any OS) | PowerShell | None | ✅ Fully Supported |

## Configuration File

The plugin creates/updates `.claude/preferences.json`:

```json
{
  "MCP_PLAN_ANNOTATIONS": true
}
```

This file is project-specific and stored in your project's `.claude` directory.

**Note:** The `.claude/preferences.json` file may be shared by multiple plugins. This plugin only manages the `MCP_PLAN_ANNOTATIONS` key and will not affect other plugins' preferences.

## Uninstallation

To completely remove this plugin and clean up all its configuration:

### Step 1: Clean up configuration

```
/planning-mcp-annotations-cleanup
```

This command will:
- Remove the `MCP_PLAN_ANNOTATIONS` key from `.claude/preferences.json`
- If no other plugin preferences exist, delete the entire preferences file
- If other plugins have preferences, preserve them and only remove this plugin's setting

### Step 2: Uninstall the plugin

```
/plugin uninstall plan-annotate-mcp@skilled-execution-plan-mode
```

### Manual Cleanup (Alternative)

If you prefer to clean up manually instead of using the `/planning-mcp-annotations-cleanup` command, you have several options:

**Option 1: Using jq (Bash users with jq installed):**
```bash
# Remove only this plugin's key, preserving other plugins' preferences
jq 'del(.MCP_PLAN_ANNOTATIONS)' .claude/preferences.json > .claude/preferences.json.tmp
mv .claude/preferences.json.tmp .claude/preferences.json

# Or, if this is the only preference, delete the entire file
rm .claude/preferences.json
```

**Option 2: Manual file editing (all users):**
1. Open `.claude/preferences.json` in your text editor
2. Remove the `"MCP_PLAN_ANNOTATIONS": true` line
3. If no other plugin preferences remain, you can delete the entire file
4. Save the file

**Option 3: Delete the preferences file (if no other plugins use it):**
```bash
rm .claude/preferences.json
```

**Note:** The `/planning-mcp-annotations-cleanup` slash command does NOT require `jq` - it's a Claude Code command that handles cleanup automatically. The jq-based commands above are only needed if you want to bypass the plugin's cleanup command.

Then uninstall the plugin as shown above.

## Troubleshooting

### Commands not working
- Start a new session after installing the plugin
- Verify the plugin is installed: check `.claude/plugins/`

### Mode not taking effect
- Verify `.claude/preferences.json` exists and has the correct value
- Check that the SessionStart hook has execute permissions
- Ensure `jq` is installed: `which jq`

### Hook not running
- Check hook permissions: `ls -l plan-annotate-mcp-plugin/hooks/`
- Make executable: `chmod +x plan-annotate-mcp-plugin/hooks/session-start.sh`

### Installing jq (Linux/macOS only)

If you're using bash (Linux, macOS, WSL, Git Bash) and `jq` is not installed:

- **Ubuntu/Debian**: `sudo apt-get install jq`
- **macOS**: `brew install jq`
- **RHEL/CentOS**: `sudo yum install jq`
- **Arch Linux**: `sudo pacman -S jq`
- **Alpine Linux**: `apk add jq`
- **Manual Download**: https://stedolan.github.io/jq/download/

**Windows PowerShell users**: No jq installation needed - PowerShell has native JSON support

## Sharing with Your Organization

### Via Git Repository

1. Push the plugin to your organization's Git server:
   ```bash
   cd plan-annotate-mcp-plugin
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/your-org/plan-annotate-mcp-plugin
   git push -u origin main
   ```

2. Team members install with:
   ```
   /install-plugin https://github.com/your-org/plan-annotate-mcp-plugin
   ```

### Via Shared Directory

1. Copy the plugin to a shared location
2. Team members install with:
   ```
   /install-plugin /shared/path/to/plan-annotate-mcp-plugin
   ```

## Development

### Plugin Structure

```
plan-annotate-mcp-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest with inline hooks
├── commands/
│   ├── mcp-plan-on.md       # Enable command
│   └── mcp-plan-off.md      # Disable command
├── hooks/
│   ├── session-start-wrapper.sh # Platform detection wrapper
│   ├── session-start.sh         # Bash SessionStart hook
│   └── session-start.ps1        # PowerShell SessionStart hook
└── README.md                # This file
```

### Testing Locally

1. Install the plugin locally
2. Run `/planning-mcp-annotations-on`
3. Start a new session and enter plan mode
4. Verify Claude mentions MCP servers in the plan
5. Run `/planning-mcp-annotations-off` and verify default behavior returns

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
