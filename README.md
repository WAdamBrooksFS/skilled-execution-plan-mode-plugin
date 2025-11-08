# Execution Plan Mode Marketplace

**Version:** 1.0.0
**Owner:** Adam Brooks (william.brooks@familysearch.org)

A Claude Code marketplace providing plugins for enhanced plan mode functionality.

---

## Overview

This marketplace provides plugins that enhance Claude Code's plan mode capabilities, allowing you to control how Claude presents and executes plans. Choose from three independent plugins to enable proactive evaluation of skills, agents, and MCP servers during planning.

---

## Quick Start

### Installation

Add this marketplace to Claude Code:

```bash
/plugin marketplace add WAdamBrooksFS/skilled-execution-plan-mode-plugin
```

### First Time Setup

Once the marketplace is installed, the plugins will be available for use. Start with:

```bash
/skilled-plan-on
```

This will enable skilled execution plan mode. See the plugin documentation for more details.

---

## Marketplace Structure

```
skilled-execution-plan-mode/
├── .claude-plugin/
│   └── marketplace.json                    # Marketplace manifest
├── plugins/
│   ├── skilled-execution-plan-mode/        # Skills plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   ├── skilled-plan-on.md
│   │   │   └── skilled-plan-off.md
│   │   ├── hooks/
│   │   │   ├── hooks.json
│   │   │   └── session-start.sh
│   │   └── README.md
│   ├── agent-execution-plan-mode/          # Agents plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   ├── agent-plan-on.md
│   │   │   └── agent-plan-off.md
│   │   ├── hooks/
│   │   │   ├── hooks.json
│   │   │   └── session-start.sh
│   │   └── README.md
│   └── mcp-execution-plan-mode/            # MCP plugin
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   ├── mcp-plan-on.md
│       │   └── mcp-plan-off.md
│       ├── hooks/
│       │   ├── hooks.json
│       │   └── session-start.sh
│       └── README.md
└── README.md                               # This file
```

---

## Available Plugins

### 1. Skilled Execution Plan Mode Plugin (v1.0.0)

**Category:** Productivity
**Status:** Available

Control whether Claude proactively evaluates and mentions which skills will be used during plan mode.

**Features:**
- Toggle commands (`/skilled-plan-on`, `/skilled-plan-off`)
- SessionStart hook for automatic configuration
- Persistent settings via `.claude/preferences.json`
- Complete documentation and examples

**Quick Start:**
```bash
/skilled-plan-on     # Enable the feature
/skilled-plan-off    # Disable the feature
```

**Learn More:** See `plugins/skilled-execution-plan-mode/README.md`

---

### 2. Agent Execution Plan Mode Plugin (v1.0.0)

**Category:** Productivity
**Status:** Available

Control whether Claude proactively evaluates and mentions which agents will be useful during plan mode.

**Features:**
- Toggle commands (`/agent-plan-on`, `/agent-plan-off`)
- SessionStart hook for automatic configuration
- Persistent settings via `.claude/preferences.json`
- Evaluates all available agents (general-purpose, Explore, sdet:*, mcp-specialist, etc.)
- Complete documentation and examples

**Quick Start:**
```bash
/agent-plan-on     # Enable the feature
/agent-plan-off    # Disable the feature
```

**Example Output:**
```
Step 2: Explore codebase structure [Explore agent]
Step 3: Create accessibility tests [sdet:playwright-engineer agent]
```

**Learn More:** See `plugins/agent-execution-plan-mode/README.md`

---

### 3. MCP Execution Plan Mode Plugin (v1.0.0)

**Category:** Productivity
**Status:** Available

Control whether Claude proactively evaluates and mentions which MCP servers will be useful during plan mode.

**Features:**
- Toggle commands (`/mcp-plan-on`, `/mcp-plan-off`)
- SessionStart hook for automatic configuration
- Persistent settings via `.claude/preferences.json`
- Evaluates all available MCP servers in your environment
- Complete documentation and examples

**Quick Start:**
```bash
/mcp-plan-on     # Enable the feature
/mcp-plan-off    # Disable the feature
```

**Example Output:**
```
Step 2: Navigate to login page [mcp__plugin_sdet_playwright MCP]
Step 3: Take accessibility snapshot [mcp__plugin_sdet_playwright MCP]
```

**Learn More:** See `plugins/mcp-execution-plan-mode/README.md`

---

## How It Works

### When Enabled

When skilled execution plan mode is enabled:

1. You run `/skilled-plan-on` to enable the feature
2. The setting is saved to `.claude/preferences.json`
3. On each new session, the SessionStart hook checks this setting
4. If enabled, Claude is instructed to evaluate and mention skills during planning
5. When you enter plan mode, Claude will proactively identify which skills might be useful
6. Example: "Step 2: Extract PDF data [**pdf** skill]"

### When Disabled (Default)

When the mode is disabled or not set:

1. Claude uses the default planning behavior
2. Skills are discovered and invoked organically during execution
3. No upfront skill evaluation during planning

---

## Requirements

- Claude Code (latest version recommended)
- `jq` command-line tool (for JSON parsing in hooks)

### Installing jq

If `jq` is not installed:
- **Ubuntu/Debian**: `sudo apt-get install jq`
- **MacOS**: `brew install jq`
- **RHEL/CentOS**: `sudo yum install jq`

---

## Configuration

The marketplace stores configuration in `.claude/preferences.json`. Each plugin can be enabled/disabled independently:

```json
{
  "SKILLED_EXECUTION_PLAN_MODE": true,
  "AGENT_EXECUTION_PLAN_MODE": true,
  "MCP_EXECUTION_PLAN_MODE": true
}
```

This file is project-specific and persists across all sessions. You can enable any combination of these modes based on your preferences.

---

## Troubleshooting

### Marketplace not loading

1. Verify the marketplace was added correctly:
   ```bash
   /plugin marketplace list
   ```

2. Try removing and re-adding:
   ```bash
   /plugin marketplace remove WAdamBrooksFS/skilled-execution-plan-mode-plugin
   /plugin marketplace add WAdamBrooksFS/skilled-execution-plan-mode-plugin
   ```

### Commands not working

- Verify the plugin is installed from the marketplace
- Start a new session for commands to be recognized
- Run `/help` to see if the commands appear

### Hook not running

- Check that `jq` is installed: `which jq`
- Verify hook permissions in the plugin directory
- Check Claude Code logs for any errors

---

## For Organizations

### Sharing with Your Team

This marketplace can be shared across your organization:

**Via GitHub (Recommended):**
```bash
/plugin marketplace add WAdamBrooksFS/skilled-execution-plan-mode-plugin
```

Team members can then install plugins from the marketplace using standard Claude Code plugin commands.

---

## Contributing

To add a new plugin to this marketplace:

1. Fork this repository
2. Create your plugin in `plugins/your-plugin/`
3. Register it in `.claude-plugin/marketplace.json`
4. Add documentation in `plugins/your-plugin/README.md`
5. Submit a pull request

---

## Support

**Questions or issues?**

- Check the plugin-specific README: `plugins/skilled-execution-plan-mode/README.md`
- File an issue: https://github.com/WAdamBrooksFS/skilled-execution-plan-mode-plugin/issues
- Contact: Adam Brooks (william.brooks@familysearch.org)

---

## Version History

**1.0.0** (2025-10-27)
- Initial marketplace release with three plugins
- Skilled execution plan mode plugin (v1.0.0)
  - Toggle commands for enabling/disabling skill evaluation
  - SessionStart hook integration
  - Persistent configuration
- Agent execution plan mode plugin (v1.0.0)
  - Toggle commands for enabling/disabling agent evaluation
  - Evaluates all available agents during planning
  - Independent configuration from other plugins
- MCP execution plan mode plugin (v1.0.0)
  - Toggle commands for enabling/disabling MCP server evaluation
  - Evaluates available MCP servers during planning
  - Independent configuration from other plugins

---

## License

[Your License Here]
