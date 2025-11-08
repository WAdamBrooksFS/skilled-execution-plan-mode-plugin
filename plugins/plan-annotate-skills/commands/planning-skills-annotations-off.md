Disable plan annotations for skills by writing the configuration to `.claude/preferences.json`.

Steps:
1. Read the existing `.claude/preferences.json` file if it exists, or create a new one
2. Update or add the `SKILLS_PLAN_ANNOTATIONS` property to `false`
3. Write the updated configuration back to the file
4. Confirm to the user that skills plan annotations have been disabled

After completing these steps, inform the user: "✓ Skills plan annotations are now **disabled**. When you enter plan mode, I will use the default planning behavior without annotating steps with skills."
