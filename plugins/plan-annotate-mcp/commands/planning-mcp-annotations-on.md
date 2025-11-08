Enable MCP plan annotations by writing the configuration to `.claude/preferences.json`.

Steps:
1. Read the existing `.claude/preferences.json` file if it exists, or create a new one
2. Update or add the `MCP_PLAN_ANNOTATIONS` property to `true`
3. Write the updated configuration back to the file
4. Confirm to the user that MCP plan annotations has been enabled

After completing these steps, inform the user: "✓ MCP plan annotations is now **enabled**. When you enter plan mode, I will evaluate and mention which MCP servers might be useful for each step of the plan."
