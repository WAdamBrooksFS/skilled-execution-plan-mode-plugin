# Agent Execution Plan Mode Plugin

A Claude Code plugin that enables proactive agent evaluation during plan mode.

## Overview

This plugin is **enabled by default** and causes Claude to evaluate and mention which available agents might be useful for each step during plan mode. The plugin automatically detects which agents are actually available and enabled in your environment, ensuring recommendations are accurate and actionable. This gives you visibility into what agent capabilities will be leveraged before execution begins.

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
   /install-plugin /path/to/agent-execution-plan-mode-plugin
   ```

### From Git Repository

```
/install-plugin https://github.com/your-org/agent-execution-plan-mode-plugin
```

## Usage

### Default Behavior

This plugin is **enabled by default** upon installation. Claude will automatically evaluate and mention available agents during plan mode without any configuration needed.

You can toggle the plugin on/off at any time using the commands below.

### Enable Agent Execution Plan Mode

```
/agent-plan-on
```

This will:
- Create/update `.claude/preferences.json` with `AGENT_EXECUTION_PLAN_MODE: true`
- Take effect in the next session
- Confirm the change to you

### Disable Agent Execution Plan Mode

```
/agent-plan-off
```

This will:
- Update `.claude/preferences.json` with `AGENT_EXECUTION_PLAN_MODE: false`
- Revert to default planning behavior
- Confirm the change to you

## How It Works

### Components

1. **Slash Commands** (`commands/`)
   - `/agent-plan-on` - Enables the mode
   - `/agent-plan-off` - Disables the mode

2. **SessionStart Hook** (`hooks/session-start.sh`)
   - Runs automatically at the start of each session
   - Reads `.claude/preferences.json`
   - Injects instructions to Claude if mode is enabled

3. **Configuration** (`.claude/preferences.json`)
   - Stores the persistent setting
   - Format: `{"AGENT_EXECUTION_PLAN_MODE": true/false}`

### Behavior During Plan Mode

**When Enabled (default):**
- Plugin automatically detects which agents are available and enabled
- Claude evaluates which AVAILABLE agents might be useful for each step
- Only available/enabled agents are considered - disabled agents are ignored
- Agents are mentioned in the plan presentation
- Example: "Step 2: Explore codebase [**Explore** agent]"
- Provides visibility before execution

**When Disabled:**
- Standard planning behavior
- Agents discovered and invoked organically during execution
- No upfront agent evaluation

### Available Agents

The plugin automatically detects which agents are available and enabled in your environment. During plan mode, only agents that are currently available will be considered and recommended.

**How Agent Discovery Works:**

The plugin checks your Claude Code configuration to discover:
- **Built-in agents** (like Explore, general-purpose, Plan) - typically always available
- **Custom agents** configured in your environment via plugins
- **Agent availability** and enabled/disabled status based on plugin configuration

**Common Built-In Agents:**
- **general-purpose**: Complex multi-step tasks, code search, autonomous execution
- **Explore**: Fast codebase exploration, pattern matching, keyword searches
- **Plan**: Planning and strategy for complex tasks

**Plugin-Provided Agents:**
Additional agents may be available if their parent plugins are installed and enabled. For example:
- **sdet:*** agents (requires sdet plugin to be enabled)
- **mcp-specialist** (if available in your environment)
- Other custom agents from marketplace plugins

**Important:** The plugin will only recommend agents that are actually installed and enabled in your Claude Code environment. This ensures recommendations are always accurate and actionable based on your actual setup.

## Example

```
User: /agent-plan-on
Claude: ✓ Agent execution plan mode is now enabled...

[New session starts]

User: [plan mode] I need to explore the test infrastructure and create accessibility tests

Claude: Here's the plan:
1. Explore the existing test infrastructure [**Explore** agent]
2. Analyze current test coverage and gaps [**sdet:risk-strategist** agent]
3. Set up Playwright for accessibility testing [**sdet:playwright-engineer** agent]
4. Create comprehensive accessibility test suite [**sdet:a11y-inspector** agent]
5. Generate documentation and CI integration [**sdet:docs-steward** agent]

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
  "AGENT_EXECUTION_PLAN_MODE": true
}
```

This file is project-specific and stored in your project's `.claude` directory.

**Note:** The `.claude/preferences.json` file may be shared by multiple plugins. This plugin only manages the `AGENT_EXECUTION_PLAN_MODE` key and will not affect other plugins' preferences.

## Uninstallation

To completely remove this plugin and clean up all its configuration:

### Step 1: Clean up configuration

```
/agent-plan-cleanup
```

This command will:
- Remove the `AGENT_EXECUTION_PLAN_MODE` key from `.claude/preferences.json`
- If no other plugin preferences exist, delete the entire preferences file
- If other plugins have preferences, preserve them and only remove this plugin's setting

### Step 2: Uninstall the plugin

```
/plugin uninstall agent-execution-plan-mode@skilled-execution-plan-mode
```

### Manual Cleanup (Alternative)

If you prefer to clean up manually, you can remove the configuration key with `jq`:

```bash
# Remove only this plugin's key
jq 'del(.AGENT_EXECUTION_PLAN_MODE)' .claude/preferences.json > .claude/preferences.json.tmp
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
- Check hook permissions: `ls -l agent-execution-plan-mode-plugin/hooks/`
- Make executable: `chmod +x agent-execution-plan-mode-plugin/hooks/session-start.sh`

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
   cd agent-execution-plan-mode-plugin
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/your-org/agent-execution-plan-mode-plugin
   git push -u origin main
   ```

2. Team members install with:
   ```
   /install-plugin https://github.com/your-org/agent-execution-plan-mode-plugin
   ```

### Via Shared Directory

1. Copy the plugin to a shared location
2. Team members install with:
   ```
   /install-plugin /shared/path/to/agent-execution-plan-mode-plugin
   ```

## Development

### Plugin Structure

```
agent-execution-plan-mode-plugin/
├── .claude-plugin/
│   └── plugin.json          # Plugin manifest
├── commands/
│   ├── agent-plan-on.md     # Enable command
│   └── agent-plan-off.md    # Disable command
├── hooks/
│   ├── hooks.json           # Hook configuration
│   └── session-start.sh     # SessionStart hook
└── README.md                # This file
```

### Testing Locally

1. Install the plugin locally
2. Run `/agent-plan-on`
3. Start a new session and enter plan mode
4. Verify Claude mentions agents in the plan
5. Run `/agent-plan-off` and verify default behavior returns

## License

[Your License Here]

## Support

For issues or questions, contact [your-support-email] or file an issue in the repository.

## Version History

- **1.0.0** - Initial release
  - Toggle commands for enabling/disabling
  - SessionStart hook integration
  - Persistent configuration
  - Comprehensive agent evaluation
