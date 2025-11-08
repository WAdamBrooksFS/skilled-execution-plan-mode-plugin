# SessionStart hook for Skilled Execution Plan Mode (PowerShell version)
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

# Auto-initialize SKILLED_EXECUTION_PLAN_MODE if it doesn't exist
if ($null -eq $prefs.SKILLED_EXECUTION_PLAN_MODE) {
    # Add the property
    $prefs | Add-Member -MemberType NoteProperty -Name "SKILLED_EXECUTION_PLAN_MODE" -Value $true -Force

    # Write back to file
    $prefs | ConvertTo-Json -Depth 10 | Out-File -FilePath $PrefsFile -Encoding UTF8 -NoNewline
}

# If enabled, output instructions for Claude
if ($prefs.SKILLED_EXECUTION_PLAN_MODE -eq $true) {
    Write-Output @"
# Skilled Execution Plan Mode: ENABLED

When you enter plan mode, you should:
1. Check ``.claude/preferences.json`` to confirm ``SKILLED_EXECUTION_PLAN_MODE`` is ``true``
2. Check which skills are actually available by looking at the available_skills list in the Skill tool
3. While creating the plan, proactively evaluate which AVAILABLE skills (if any) would be useful for each step
4. ONLY recommend skills that are currently available and enabled - do not suggest disabled or unavailable skills
5. Include mentions of available skills in the plan presentation (e.g., "Step 2: Extract PDF data [**pdf** skill]")
6. This helps the user understand what capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with ``/skilled-plan-off``.
"@
}
