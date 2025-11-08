# SessionStart hook for Agent Execution Plan Mode (PowerShell version)
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

# Auto-initialize AGENT_EXECUTION_PLAN_MODE if it doesn't exist
if ($null -eq $prefs.AGENT_EXECUTION_PLAN_MODE) {
    # Add the property
    $prefs | Add-Member -MemberType NoteProperty -Name "AGENT_EXECUTION_PLAN_MODE" -Value $false -Force

    # Write back to file
    $prefs | ConvertTo-Json -Depth 10 | Out-File -FilePath $PrefsFile -Encoding UTF8 -NoNewline
}

# If enabled, output instructions for Claude
if ($prefs.AGENT_EXECUTION_PLAN_MODE -eq $true) {
    Write-Output @"
# Agent Execution Plan Mode: ENABLED

When you enter plan mode, you should:
1. Check ``.claude/preferences.json`` to confirm ``AGENT_EXECUTION_PLAN_MODE`` is ``true``
2. While creating the plan, proactively evaluate which agents (if any) would be useful for each step
3. Consider available agents such as:
   - **general-purpose**: Complex multi-step tasks, code search, autonomous execution
   - **Explore**: Fast codebase exploration, pattern matching, keyword searches
   - **sdet:playwright-engineer**: Playwright setup, smoke/a11y tests, CI guidance
   - **sdet:orchestration-agent**: Test planning, triaging, delegation
   - **sdet:a11y-inspector**: Comprehensive accessibility testing with reports
   - **sdet:qa-shared-librarian**: Org-shared test utilities and snippets
   - **sdet:github-ops**: Repository/PR workflow for test assets
   - **sdet:spring-boot-api-tester**: RestAssured smoke tests for Spring Boot
   - **sdet:wdio-engineer**: WebdriverIO setup and maintenance
   - **sdet:figma-bridge**: Figma specs to Playwright assertions
   - **sdet:intl-auditor**: Internationalization checks and locale tests
   - **sdet:risk-strategist**: Risk quantification and test prioritization
   - **sdet:machine-provisioner**: Local environment readiness checks
   - **sdet:docs-steward**: README and test plan generation
   - **sdet:jira-analyst**: JIRA to BDD scenarios and Playwright tests
   - **sdet:test-case-generator**: AC/specs to BDD and Playwright stubs
   - **mcp-specialist**: MCP server installation, configuration, troubleshooting
4. Include mentions of applicable agents in the plan presentation (e.g., "Step 2: Explore codebase structure [**Explore** agent]")
5. This helps the user understand what agent capabilities will be leveraged before execution begins

This mode is currently ENABLED. The user can disable it with ``/agent-plan-off``.
"@
}
