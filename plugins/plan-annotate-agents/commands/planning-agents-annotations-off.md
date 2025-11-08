Disable agents plan annotations by writing the configuration to `.claude/preferences.json`.

Steps:
1. Read the existing `.claude/preferences.json` file if it exists, or create a new one
2. Update or add the `AGENTS_PLAN_ANNOTATIONS` property to `false`
3. Write the updated configuration back to the file
4. Confirm to the user that agents plan annotations has been disabled

After completing these steps, inform the user: "✓ Agent execution plan mode is now **disabled**. When you enter plan mode, I will use the default planning behavior without evaluating agents upfront."
