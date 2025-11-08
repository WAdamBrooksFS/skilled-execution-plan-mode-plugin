Enable plan annotations for skills by writing the configuration to `.claude/preferences.json`.

Steps:
1. Read the existing `.claude/preferences.json` file if it exists, or create a new one
2. Update or add the `SKILLS_PLAN_ANNOTATIONS` property to `true`
3. Write the updated configuration back to the file
4. Confirm to the user that skills plan annotations have been enabled

After completing these steps, inform the user: "✓ Skills plan annotations are now **enabled**. When you enter plan mode, I will annotate each step with which skills will be used."
