# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Claude Code **marketplace** repository containing three independent plugins that enhance plan mode functionality:

1. **plan-annotate-skills** - Evaluates and mentions available skills during plan mode
2. **plan-annotate-agents** - Evaluates and mentions available agents during plan mode
3. **plan-annotate-mcp** - Evaluates and mentions available MCP servers during plan mode

All plugins share a common architecture and are **enabled by default** upon installation. Each plugin only recommends capabilities that are actually available and enabled in the user's environment.

## Repository Structure

```
plan-annotate-skills/
├── .claude-plugin/
│   └── marketplace.json           # Marketplace manifest registering all plugins
├── plugins/
│   ├── plan-annotate-skills/
│   ├── plan-annotate-agents/
│   └── plan-annotate-mcp/
└── README.md
```

Each plugin follows an identical structure:
```
plugin-name/
├── .claude-plugin/
│   └── plugin.json                # Plugin manifest with commands and inline hooks
├── .gitattributes                 # Line ending enforcement (CRITICAL for cross-platform)
├── commands/
│   ├── {name}-plan-on.md          # Enable command
│   ├── {name}-plan-off.md         # Disable command
│   └── {name}-plan-cleanup.md     # Uninstallation cleanup command
├── hooks/
│   ├── session-start-wrapper.sh   # Platform detection (POSIX sh)
│   ├── session-start.sh           # Bash implementation (requires jq)
│   └── session-start.ps1          # PowerShell implementation (no external deps)
└── README.md                      # Plugin-specific documentation
```

## Key Architectural Patterns

### Cross-Platform Hook Architecture

All plugins use a **two-layer hook system** to support all Claude Code platforms:

1. **plugin.json inline hooks** - Registers the SessionStart hook directly in the plugin manifest:
   ```json
   {
     "hooks": {
       "SessionStart": [
         {
           "matcher": "*",
           "hooks": [
             {
               "type": "command",
               "command": "sh ${CLAUDE_PLUGIN_ROOT}/hooks/session-start-wrapper.sh"
             }
           ]
         }
       ]
     }
   }
   ```
   Note: Always use `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths.

2. **session-start-wrapper.sh** - POSIX sh script that detects platform:
   - Checks for `pwsh` (PowerShell Core) → runs .ps1
   - Checks for `powershell` (Windows PowerShell) → runs .ps1
   - Checks for `bash` → runs .sh
   - Fallback to `sh` → runs .sh

3. **Platform-specific scripts**:
   - **session-start.sh** - Bash version requiring `jq` for JSON parsing
   - **session-start.ps1** - PowerShell version with native JSON support (no dependencies)

### Shared Configuration File

All plugins use `.claude/preferences.json` to store their enabled/disabled state:

```json
{
  "SKILLS_PLAN_ANNOTATIONS": true,
  "AGENTS_PLAN_ANNOTATIONS": true,
  "MCP_PLAN_ANNOTATIONS": true
}
```

**Important:** This file is shared across multiple plugins. When implementing cleanup:
- Remove only the plugin's specific key
- If no other keys remain, delete the entire file
- If other keys exist, preserve them

### Line Ending Requirements

Each plugin contains a `.gitattributes` file that **MUST** enforce correct line endings:

```
*.sh text eol=lf       # Bash scripts require Unix line endings
*.ps1 text eol=crlf    # PowerShell scripts require Windows line endings
*.json text eol=lf
*.md text eol=lf
```

**Critical:** Incorrect line endings will cause hook execution failures on the target platform.

### SessionStart Hook Pattern

Each plugin's SessionStart hook follows this pattern:

1. Check if `.claude/preferences.json` exists, create if missing
2. Auto-initialize the plugin's preference key to `true` (enabled by default)
3. Read the preference value
4. If enabled, output markdown instructions to Claude's context
5. Instructions tell Claude to:
   - Check which capabilities are **available** in the environment
   - Only recommend available/enabled capabilities
   - Mention capabilities in plan presentation format

### Command Pattern

Each plugin provides three slash commands:

1. **{name}-plan-on.md** - Sets preference to `true`
2. **{name}-plan-off.md** - Sets preference to `false`
3. **{name}-plan-cleanup.md** - Removes preference key (used before uninstallation)

Commands are registered in `.claude-plugin/plugin.json` with relative paths using `./` prefix.

## Testing Plugin Changes

To test a plugin locally after making changes:

1. **Test the hook scripts directly:**
   ```bash
   # For Bash version:
   cd plugins/plan-annotate-skills
   bash hooks/session-start.sh

   # For PowerShell version:
   pwsh -ExecutionPolicy Bypass -File hooks/session-start.ps1
   ```

2. **Test the wrapper:**
   ```bash
   export CLAUDE_PLUGIN_ROOT="$(pwd)/plugins/plan-annotate-skills"
   sh plugins/plan-annotate-skills/hooks/session-start-wrapper.sh
   ```

3. **Test in Claude Code:**
   - Start a new Claude Code session
   - The SessionStart hook runs automatically
   - Run `/{name}-plan-on` or `/{name}-plan-off` to toggle
   - Check `.claude/preferences.json` for correct updates

## Making Changes Across All Plugins

When modifying plugin functionality, changes typically need to be applied to all three plugins. The plugins are independent but share identical architecture.

**Common change scenarios:**
- Hook script updates → Update all 6 scripts (3 bash + 3 PowerShell)
- Command pattern changes → Update all 9 command files (3 per plugin)
- Architecture improvements → Apply to all three plugin directories

**Plugin-specific differences:**
- **plan-annotate-skills**: Checks available_skills list in Skill tool
- **plan-annotate-agents**: Checks enabled plugins and built-in agents (general-purpose, Explore, Plan)
- **plan-annotate-mcp**: Checks function tools list for `mcp__` prefixed tools

## Git Workflow

This repository uses a standard branch-and-merge workflow:

```bash
# Create feature branch
git checkout -b feature-name

# Make changes, commit
git add .
git commit -m "Description of changes"

# Push to remote
git push origin feature-name

# Merge to main
git checkout main
git merge feature-name
git push origin main
```

## Marketplace Distribution

The marketplace is distributed via GitHub and installed with:
```
/plugin marketplace add WAdamBrooksFS/plan-annotate-skills-plugin
```

When users install the marketplace, all three plugins become available. The marketplace.json file at `.claude-plugin/marketplace.json` registers all plugins with their metadata.
