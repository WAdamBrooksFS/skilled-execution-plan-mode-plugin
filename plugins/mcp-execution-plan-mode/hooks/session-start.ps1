# SessionStart hook for MCP Execution Plan Mode (PowerShell version)
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

# Auto-initialize MCP_EXECUTION_PLAN_MODE if it doesn't exist
if ($null -eq $prefs.MCP_EXECUTION_PLAN_MODE) {
    # Add the property
    $prefs | Add-Member -MemberType NoteProperty -Name "MCP_EXECUTION_PLAN_MODE" -Value $true -Force

    # Write back to file
    $prefs | ConvertTo-Json -Depth 10 | Out-File -FilePath $PrefsFile -Encoding UTF8 -NoNewline
}

# If enabled, output instructions for Claude
if ($prefs.MCP_EXECUTION_PLAN_MODE -eq $true) {
    Write-Output @"
# MCP Execution Plan Mode: ENABLED

When you enter plan mode, you should:
1. Check ``.claude/preferences.json`` to confirm ``MCP_EXECUTION_PLAN_MODE`` is ``true``
2. Check which MCP tools are actually available by looking at your function tools list
3. MCP tools are prefixed with "mcp__" in the function definitions (e.g., mcp__plugin_sdet_playwright__browser_snapshot)
4. While creating the plan, proactively evaluate which AVAILABLE MCP servers (if any) would be useful for each step
5. ONLY recommend MCP servers whose tools are currently available and enabled - do not suggest disabled or unavailable MCPs
6. Include mentions of available MCP servers in the plan presentation (e.g., "Step 3: Browser interaction and testing [**mcp__plugin_sdet_playwright** MCP]")
7. This helps the user understand what MCP capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with ``/mcp-plan-off``.
"@
}
