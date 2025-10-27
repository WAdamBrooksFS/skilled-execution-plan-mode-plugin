# Agent Execution Plan Mode Plugin

A Claude Code plugin that enables proactive agent evaluation during plan mode.

## Overview

When enabled, this plugin causes Claude to evaluate and mention which agents might be useful for each step during plan mode, giving you visibility into what agent capabilities will be leveraged before execution begins.

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

**When Enabled:**
- Claude evaluates which agents might be useful for each step
- Agents are mentioned in the plan presentation
- Example: "Step 2: Explore codebase [**Explore** agent]"
- Provides visibility before execution

**When Disabled (default):**
- Standard planning behavior
- Agents discovered and invoked organically during execution
- No upfront agent evaluation

### Available Agents

The plugin helps Claude consider these agents during planning:

- **general-purpose**: Complex multi-step tasks, code search, autonomous execution
- **Explore**: Fast codebase exploration, pattern matching, keyword searches
- **sdet:playwright-engineer**: Playwright setup, smoke/a11y tests, CI guidance
- **sdet:orchestration-agent**: Test planning, triaging, delegation
- **sdet:a11y-inspector**: Comprehensive accessibility testing with reports
- **sdet:qa-shared-librarian**: Org-shared test utilities and snippets
- **sdet:github-ops**: Repository/PR workflow for test assets
- **sdet:spring-boot-api-tester**: RestAssured smoke tests for Spring Boot
- **sdet:wdio-engineer**: WebdriverIO setup and maintenance
- **sdet:figma-bridge**: Figma specs to Playwright assertions
- **sdet:intl-auditor**: Internationalization checks and locale tests
- **sdet:risk-strategist**: Risk quantification and test prioritization
- **sdet:machine-provisioner**: Local environment readiness checks
- **sdet:docs-steward**: README and test plan generation
- **sdet:jira-analyst**: JIRA to BDD scenarios and Playwright tests
- **sdet:test-case-generator**: AC/specs to BDD and Playwright stubs
- **mcp-specialist**: MCP server installation, configuration, troubleshooting

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

- Claude Code (latest version recommended)
- `jq` command-line tool (for JSON parsing in hook)

## Configuration File

The plugin creates/updates `.claude/preferences.json`:

```json
{
  "AGENT_EXECUTION_PLAN_MODE": true
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
- Check hook permissions: `ls -l agent-execution-plan-mode-plugin/hooks/`
- Make executable: `chmod +x agent-execution-plan-mode-plugin/hooks/session-start.sh`

### Installing jq
If `jq` is not installed:
- **Ubuntu/Debian**: `sudo apt-get install jq`
- **MacOS**: `brew install jq`
- **RHEL/CentOS**: `sudo yum install jq`

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
