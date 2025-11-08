Enable MCP execution plan mode by writing the configuration to `.claude/preferences.json`.

Steps:
1. Read the existing `.claude/preferences.json` file if it exists, or create a new one
2. Update or add the `MCP_EXECUTION_PLAN_MODE` property to `true`
3. Write the updated configuration back to the file
4. Confirm to the user that MCP execution plan mode has been enabled

After completing these steps, inform the user: "✓ MCP execution plan mode is now **enabled**. When you enter plan mode, I will evaluate and mention which MCP servers might be useful for each step of the plan."
