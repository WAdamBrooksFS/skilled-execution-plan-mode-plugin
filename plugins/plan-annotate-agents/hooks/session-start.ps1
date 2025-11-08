# SessionStart hook for Plan Annotations: Agents (PowerShell version)
# Checks .claude/preferences.json and injects context if the mode is enabled

$PrefsFile = ".claude/preferences.json"

# Create .claude directory and preferences file if they don't exist
if (!(Test-Path $PrefsFile)) {
    New-Item -ItemType Directory -Path ".claude" -Force | Out-Null
    "{}" | Out-File -FilePath $PrefsFile -Encoding UTF8 -NoNewline
}

# Read and parse preferences
try {
    $prefsContent = Get-Content $PrefsFile -Raw -ErrorAction Stop
    if ([string]::IsNullOrWhiteSpace($prefsContent)) {
        $prefsContent = "{}"
    }
    $prefs = $prefsContent | ConvertFrom-Json
} catch {
    # If file is corrupted, recreate it
    $prefs = @{}
    "{}" | Out-File -FilePath $PrefsFile -Encoding UTF8 -NoNewline
}

# Auto-initialize AGENTS_PLAN_ANNOTATIONS if it doesn't exist
if ($null -eq $prefs.AGENTS_PLAN_ANNOTATIONS) {
    # Add the property
    $prefs | Add-Member -MemberType NoteProperty -Name "AGENTS_PLAN_ANNOTATIONS" -Value $true -Force

    # Write back to file
    $prefs | ConvertTo-Json -Depth 10 | Out-File -FilePath $PrefsFile -Encoding UTF8 -NoNewline
}

# If enabled, output instructions for Claude
if ($prefs.AGENTS_PLAN_ANNOTATIONS -eq $true) {
    Write-Output @"
# Plan Annotations: Agents: ENABLED

When you enter plan mode, you should:
1. Check ``.claude/preferences.json`` to confirm ``AGENTS_PLAN_ANNOTATIONS`` is ``true``
2. Determine which agents are actually available by checking enabled plugins in the environment
3. Built-in agents typically available: general-purpose, Explore, Plan
4. Additional agents are available if their plugins are enabled (e.g., sdet:* agents require the sdet plugin)
5. While creating the plan, proactively evaluate which AVAILABLE agents (if any) would be useful for each step
6. ONLY recommend agents that are currently available and enabled - do not suggest disabled or unavailable agents
7. Include mentions of available agents in the plan presentation (e.g., "Step 2: Explore codebase structure [**Explore** agent]")
8. This helps the user understand what agent capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with ``/planning-agents-annotations-off``.
"@
}
