# [FEATURE] Plugin Lifecycle Hooks: Install and Uninstall

## Summary

Request support for plugin lifecycle hooks to enable automatic setup during installation and cleanup during uninstallation. Currently, Claude Code only supports `SessionStart` hooks, requiring manual multi-step processes for plugin installation and uninstallation.

## Current Limitation

**What exists today:**
- `SessionStart` hook - Runs at the start of each session
- Manual plugin installation with `/install-plugin`
- Manual plugin uninstallation with `/plugin uninstall`

**The problem:**
1. **No automatic setup during installation** - Plugins cannot initialize configuration, validate dependencies, or perform first-time setup automatically
2. **No automatic cleanup during uninstallation** - Plugins leave behind configuration files, preference keys, and other artifacts that must be manually cleaned up
3. **Poor user experience** - Users must remember to run cleanup commands before uninstalling, and may not know what needs to be cleaned up

## Proposed Solution

Add lifecycle hooks for plugin installation and uninstallation:

### Installation Hooks
- **`PreInstall`** - Runs before plugin files are installed
  - Use case: Validate dependencies, check system requirements, confirm prerequisites
- **`PostInstall`** - Runs after plugin files are installed
  - Use case: Initialize configuration, create default settings, display setup instructions
- **`Install`** - Generic installation hook (if only one is needed)

### Uninstallation Hooks
- **`PreUninstall`** - Runs before plugin files are removed
  - Use case: Clean up configuration files, remove preference keys, revert system changes
- **`PostUninstall`** - Runs after plugin files are removed
  - Use case: Final cleanup, display uninstallation confirmation, remove orphaned files
- **`Uninstall`** - Generic uninstallation hook (if only one is needed)

## Use Cases

### Real-World Example: plan-annotations Marketplace

I maintain a Claude Code marketplace with three plugins that enhance plan mode functionality:
- `plan-annotate-skills` - Annotates plans with skills
- `plan-annotate-agents` - Annotates plans with agents
- `plan-annotate-mcp` - Annotates plans with MCP servers

**Current Process (Manual):**

Installation:
1. User runs `/plugin marketplace add WAdamBrooksFS/plan-annotations`
2. Plugins install
3. On first session, `SessionStart` hook auto-initializes `.claude/preferences.json` with defaults
4. This works, but initialization happens on first session, not during installation

Uninstallation:
1. User must manually run `/planning-skills-annotations-cleanup`
2. User must manually run `/planning-agents-annotations-cleanup`
3. User must manually run `/planning-mcp-annotations-cleanup`
4. Each cleanup command removes preference keys from `.claude/preferences.json`
5. Finally, user runs `/plugin uninstall plan-annotate-skills@plan-annotations`
6. Repeat for all three plugins

**Problems:**
- Users must remember cleanup commands exist
- Users must run three separate cleanup commands
- If users forget, orphaned config remains in `.claude/preferences.json`
- Poor uninstallation experience

**With Lifecycle Hooks:**

Installation with `PostInstall`:
1. User runs `/plugin marketplace add WAdamBrooksFS/plan-annotations`
2. Plugins install
3. `PostInstall` hook runs automatically
4. Hook initializes `.claude/preferences.json` immediately
5. Hook displays "Setup complete!" message
6. User can start using plugins right away

Uninstallation with `PreUninstall`:
1. User runs `/plugin uninstall plan-annotate-skills@plan-annotations`
2. `PreUninstall` hook runs automatically
3. Hook removes `SKILLS_PLAN_ANNOTATIONS` key from `.claude/preferences.json`
4. Hook cleans up plugin-specific configuration
5. Plugin files are removed
6. Environment is completely clean

### Additional Use Cases

**PreInstall - Dependency Validation:**
```bash
# Check if jq is installed (required for bash hooks)
if ! command -v jq &> /dev/null; then
    echo "Error: This plugin requires 'jq' for JSON parsing"
    echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi
```

**PostInstall - Interactive Setup:**
```bash
# Prompt user for initial configuration
echo "Would you like to enable skill annotations by default? (y/n)"
# Create initial preferences based on user input
```

**PreUninstall - Safe Cleanup:**
```bash
# Remove only this plugin's keys from shared config file
# Preserve other plugins' settings
# Delete entire file only if no other plugins exist
```

**PostUninstall - Confirmation:**
```bash
echo "Plugin successfully uninstalled and all configuration removed"
echo "Your environment is clean"
```

## Proposed Implementation

### Hook Registration in `plugin.json`

Hooks would be registered inline in the plugin manifest (`.claude-plugin/plugin.json`):

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "hooks": {
    "PreInstall": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "sh ${CLAUDE_PLUGIN_ROOT}/hooks/pre-install.sh"
      }]
    }],
    "PostInstall": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "sh ${CLAUDE_PLUGIN_ROOT}/hooks/post-install.sh"
      }]
    }],
    "PreUninstall": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "sh ${CLAUDE_PLUGIN_ROOT}/hooks/pre-uninstall.sh"
      }]
    }],
    "PostUninstall": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "sh ${CLAUDE_PLUGIN_ROOT}/hooks/post-uninstall.sh"
      }]
    }],
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

### Example PreUninstall Hook (Bash)

```bash
#!/bin/bash
# hooks/pre-uninstall.sh

PREFS_FILE=".claude/preferences.json"
PLUGIN_KEY="SKILLS_PLAN_ANNOTATIONS"

# Check if preferences file exists
if [ ! -f "$PREFS_FILE" ]; then
    exit 0
fi

# Remove this plugin's key
jq "del(.$PLUGIN_KEY)" "$PREFS_FILE" > "$PREFS_FILE.tmp"
mv "$PREFS_FILE.tmp" "$PREFS_FILE"

# If preferences file is now empty, remove it
if [ "$(jq 'length' "$PREFS_FILE")" -eq 0 ]; then
    rm "$PREFS_FILE"
fi

echo "✓ Plugin configuration cleaned up"
```

### Example PreUninstall Hook (PowerShell)

```powershell
# hooks/pre-uninstall.ps1

$PREFS_FILE = ".claude/preferences.json"
$PLUGIN_KEY = "SKILLS_PLAN_ANNOTATIONS"

# Check if preferences file exists
if (Test-Path $PREFS_FILE) {
    $prefs = Get-Content $PREFS_FILE -Raw | ConvertFrom-Json

    # Remove this plugin's key
    $prefs.PSObject.Properties.Remove($PLUGIN_KEY)

    # If empty, delete file; otherwise save
    if ($prefs.PSObject.Properties.Count -eq 0) {
        Remove-Item $PREFS_FILE
    } else {
        $prefs | ConvertTo-Json | Set-Content $PREFS_FILE
    }

    Write-Output "✓ Plugin configuration cleaned up"
}
```

## Benefits

### For Plugin Authors
1. **Complete lifecycle control** - Handle setup and cleanup automatically
2. **Better user experience** - No manual multi-step processes
3. **Cleaner environments** - Automatic cleanup prevents orphaned config
4. **Professional polish** - Plugins feel more integrated and complete
5. **Reduced support burden** - Users don't need to remember cleanup commands

### For Users
1. **Simple installation** - Just install and go
2. **Simple uninstallation** - Just uninstall, cleanup is automatic
3. **Clean environments** - No leftover configuration to track down
4. **Better trust** - Confidence that uninstalling removes everything

### For the Ecosystem
1. **Standardization** - Common pattern for plugin lifecycle management
2. **Quality bar** - Encourages plugins to handle cleanup properly
3. **Best practices** - Clear patterns for plugin authors to follow
4. **Reduced fragmentation** - Consistent behavior across all plugins

## Technical Considerations

### Execution Order
- `PreInstall` → Install files → `PostInstall` → `SessionStart` (first session)
- `PreUninstall` → Remove files → `PostUninstall`

### Error Handling
- If `PreInstall` fails (non-zero exit code), abort installation
- If `PostInstall` fails, warn user but complete installation
- If `PreUninstall` fails, warn user but proceed with uninstallation
- If `PostUninstall` fails, log warning (files already removed)

### Environment Variables
- Continue using `${CLAUDE_PLUGIN_ROOT}` for plugin-relative paths
- Provide additional context like `${CLAUDE_PLUGIN_NAME}`, `${CLAUDE_VERSION}`

### Cross-Platform Support
- Hooks should support same patterns as `SessionStart`:
  - Shell scripts for Linux/macOS/WSL
  - PowerShell scripts for Windows
  - Platform detection wrappers

### Backward Compatibility
- Existing plugins continue working without these hooks
- New hooks are optional
- No breaking changes to existing hook system

## Related Issues

- Issue #11226 discusses hook security concerns, showing active interest in hook functionality
- Various feature requests mention plugin extensibility

## Alternatives Considered

### 1. Manual Cleanup Commands (Current Approach)
**Pros:** Works with current system
**Cons:** Poor UX, easy to forget, leaves orphaned config

### 2. SessionStart Detection of Orphaned Config
**Pros:** Can detect and offer to clean up old config
**Cons:** Doesn't help during actual uninstallation, creates confusing warnings

### 3. Bundled Cleanup Scripts
**Pros:** Users can run standalone cleanup script
**Cons:** Still manual, users must find and run script

### 4. Documentation Only
**Pros:** No code changes needed
**Cons:** Doesn't solve the problem, users still forget

## Conclusion

Plugin lifecycle hooks would significantly improve the Claude Code plugin ecosystem by enabling automatic setup and cleanup. This feature would benefit plugin authors, users, and the overall quality of the plugin marketplace.

The implementation builds on the existing `SessionStart` hook pattern, making it a natural extension of the current system. The use cases are real (demonstrated by my plan-annotations marketplace), and the benefits are clear.

I hope the Claude Code team will consider adding these lifecycle hooks to provide a more complete and professional plugin experience.

## About This Request

**Author:** Adam Brooks (william.brooks@familysearch.org)
**Repository:** https://github.com/WAdamBrooksFS/plan-annotations
**Real-world usage:** Three production plugins currently requiring manual cleanup

Happy to provide more details, examples, or help with implementation if this feature is considered!
