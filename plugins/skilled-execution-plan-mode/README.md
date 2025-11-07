# Skilled Execution Plan Mode Plugin

A Claude Code plugin that enables proactive skill evaluation during plan mode.

## Overview

When enabled, this plugin causes Claude to evaluate and mention which skills might be useful for each step during plan mode, giving you visibility into what capabilities will be leveraged before execution begins.

## Features

- **Toggle On/Off**: Easy slash commands to enable or disable the mode
- **Persistent**: Setting persists across all sessions
- **Automatic**: SessionStart hook automatically configures Claude's behavior
- **Shareable**: Plugin can be distributed to teams and organizations

## Installation

This plugin is part of the Skilled Execution Plan Mode marketplace.

### From Marketplace (Recommended)

Add the marketplace to Claude Code:

```
/plugin marketplace add WAdamBrooksFS/skilled-execution-plan-mode-plugin
```

Once installed, the plugin commands will be available in your Claude Code session.

## Usage

### Enable Skilled Execution Plan Mode

```
/skilled-plan-on
```

This will:
- Create/update `.claude/preferences.json` with `SKILLED_EXECUTION_PLAN_MODE: true`
- Take effect in the next session
- Confirm the change to you

### Disable Skilled Execution Plan Mode

```
/skilled-plan-off
```

This will:
- Update `.claude/preferences.json` with `SKILLED_EXECUTION_PLAN_MODE: false`
- Revert to default planning behavior
- Confirm the change to you

## How It Works

### Components

1. **Slash Commands** (`commands/`)
   - `/skilled-plan-on` - Enables the mode
   - `/skilled-plan-off` - Disables the mode

2. **SessionStart Hook** (`hooks/session-start.sh`)
   - Runs automatically at the start of each session
   - Reads `.claude/preferences.json`
   - Injects instructions to Claude if mode is enabled

3. **Configuration** (`.claude/preferences.json`)
   - Stores the persistent setting
   - Format: `{"SKILLED_EXECUTION_PLAN_MODE": true/false}`

### Behavior During Plan Mode

**When Enabled:**
- Claude evaluates which skills might be useful for each step
- Skills are mentioned in the plan presentation
- Example: "Step 2: Extract PDF data [**pdf** skill]"
- Provides visibility before execution

**When Disabled (default):**
- Standard planning behavior
- Skills discovered and invoked organically during execution
- No upfront skill evaluation

## Example

```
User: /skilled-plan-on
Claude: ✓ Skilled execution plan mode is now enabled...

[New session starts]

User: [plan mode] Extract text from these PDFs and create a summary spreadsheet

Claude: Here's the plan:
1. Extract text from PDF files [**pdf** skill]
2. Analyze and summarize the extracted content
3. Create spreadsheet with summaries [**xlsx** skill]
4. Format and validate the output

Ready to proceed?
```

## Requirements

### All Platforms
- Claude Code (latest version recommended)

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
  "SKILLED_EXECUTION_PLAN_MODE": true
}
```

This file is project-specific and stored in your project's `.claude` directory.

**Note:** The `.claude/preferences.json` file may be shared by multiple plugins. This plugin only manages the `SKILLED_EXECUTION_PLAN_MODE` key and will not affect other plugins' preferences.

## Uninstallation

To completely remove this plugin and clean up all its configuration:

### Step 1: Clean up configuration

```
/skilled-plan-cleanup
```

This command will:
- Remove the `SKILLED_EXECUTION_PLAN_MODE` key from `.claude/preferences.json`
- If no other plugin preferences exist, delete the entire preferences file
- If other plugins have preferences, preserve them and only remove this plugin's setting

### Step 2: Uninstall the plugin

```
/plugin uninstall skilled-execution-plan-mode@skilled-execution-plan-mode
```

### Manual Cleanup (Alternative)

If you prefer to clean up manually, you can remove the configuration key with `jq`:

```bash
# Remove only this plugin's key
jq 'del(.SKILLED_EXECUTION_PLAN_MODE)' .claude/preferences.json > .claude/preferences.json.tmp
mv .claude/preferences.json.tmp .claude/preferences.json

# Or, if this is the only preference, delete the entire file
rm .claude/preferences.json
```

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
- Check hook permissions: `ls -l skilled-execution-plan-mode/hooks/`
- Make executable: `chmod +x skilled-execution-plan-mode/hooks/session-start.sh`

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

This plugin is distributed as part of a marketplace. Team members can install it by adding the marketplace:

```bash
/plugin marketplace add WAdamBrooksFS/skilled-execution-plan-mode-plugin
```

Once the marketplace is added, all plugins in the marketplace (including this one) will be available for use.

For more information about the marketplace structure and available plugins, see the marketplace README at the repository root.

## Development

### Plugin Structure

```
plugins/skilled-execution-plan-mode/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── skilled-plan-on.md   # Enable command
│   └── skilled-plan-off.md  # Disable command
├── hooks/
│   └── session-start.sh     # SessionStart hook
└── README.md                # This file
```

This plugin is part of a larger marketplace. See the repository root for the marketplace structure.

### Testing Locally

1. Install the plugin locally
2. Run `/skilled-plan-on`
3. Start a new session and enter plan mode
4. Verify Claude mentions skills in the plan
5. Run `/skilled-plan-off` and verify default behavior returns

## License

[Your License Here]

## Support

For issues or questions, contact [your-support-email] or file an issue in the repository.

## Version History

- **1.0.0** - Initial release
  - Toggle commands for enabling/disabling
  - SessionStart hook integration
  - Persistent configuration
