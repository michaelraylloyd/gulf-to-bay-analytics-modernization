# =====================================================================
#  SECTION 1 — CONFIGURATION & MODULE SETUP
# ---------------------------------------------------------------------
#  PURPOSE:
#     Centralizes all configuration for the Dev→Prod SDLC pipeline.
#     Defines repository paths, exposes them globally, and loads all
#     validator functions from the validators/ directory.
#
#  WHY THIS MATTERS:
#     • Ensures consistent path usage across all validators.
#     • Prevents stale inline definitions from overriding dot-sourced files.
#     • Makes the module deterministic, portable, and CI/CD‑safe.
# =====================================================================

# --- Repository Paths -------------------------------------------------
$DevPath  = "C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev"
$ProdPath = "C:\Repos\Prod\gulf-to-bay-analytics-modernization"

# Expose paths globally so all validators can reference them
Set-Variable -Name DevPath  -Value $DevPath  -Scope Global -Force
Set-Variable -Name ProdPath -Value $ProdPath -Scope Global -Force

# --- Load Validators --------------------------------------------------
. $PSScriptRoot\validators\Test-Readme.ps1
. $PSScriptRoot\validators\Test-Links.ps1
. $PSScriptRoot\validators\Test-Gitignore.ps1
. $PSScriptRoot\validators\Test-RepoHygiene.ps1
. $PSScriptRoot\validators\Test-BranchState.ps1

# =====================================================================
#  SECTION 2 — VALIDATORS & PIPELINE FUNCTIONS
# ---------------------------------------------------------------------
#  PURPOSE:
#     Implements the full SDLC validation and promotion workflow.
#     All functions return structured PSCustomObjects instead of
#     console output, enabling clean orchestration and reporting.
#
#  ARCHITECTURE:
#     • Validators: Test-* functions (no console output)
#     • Diff Engine: Dev↔Prod drift detection
#     • Sync Gate: Ensures repos match before promotion
#     • Preflight: Aggregates validator results
#     • Promotion: Mirrors Dev → Prod safely
#     • Orchestrator: Run-Pipeline (user-facing entrypoint)
# =====================================================================


# =====================================================================
#  DEV↔PROD DIFF ENGINE
# =====================================================================

function Get-RelativeFileMap {
    param(
        [string]$RootPath,
        [string[]]$ExcludeDirs
    )

    $files = Get-ChildItem -Path $RootPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $relative = $_.FullName.Replace($RootPath, "")
            -not ($ExcludeDirs | ForEach-Object { $relative -like "*\$_\*" })
        }

    $map = @{}
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\','/')
        $hash = (Get-FileHash -Path $file.FullName -Algorithm SHA256).Hash
        $map[$relativePath] = $hash
    }

    return $map
}

function Test-DevProdDiff {

    $result = [PSCustomObject]@{
        Name        = "DevProdDiff"
        Passed      = $true
        Errors      = @()
        Warnings    = @()
        Suggestions = @()
        OnlyInDev   = @()
        OnlyInProd  = @()
        Modified    = @()
    }

    $excludeDirs = @(".git", ".venv", "venv", "env", "__pycache__", ".ipynb_checkpoints")

    if (-not (Test-Path $DevPath)) {
        $result.Passed = $false
        $result.Errors += "Dev path does not exist: $DevPath"
        return $result
    }

    if (-not (Test-Path $ProdPath)) {
        $result.Passed = $false
        $result.Errors += "Prod path does not exist: $ProdPath"
        return $result
    }

    $devMap  = Get-RelativeFileMap -RootPath $DevPath  -ExcludeDirs $excludeDirs
    $prodMap = Get-RelativeFileMap -RootPath $ProdPath -ExcludeDirs $excludeDirs

    $devFiles  = $devMap.Keys
    $prodFiles = $prodMap.Keys

    $result.OnlyInDev  = $devFiles  | Where-Object { $_ -notin $prodFiles }
    $result.OnlyInProd = $prodFiles | Where-Object { $_ -notin $devFiles }

    foreach ($file in ($devFiles | Where-Object { $_ -in $prodFiles })) {
        if ($devMap[$file] -ne $prodMap[$file]) {
            $result.Modified += $file
        }
    }

    if ($result.OnlyInDev.Count -gt 0 -or
        $result.OnlyInProd.Count -gt 0 -or
        $result.Modified.Count -gt 0) {

        $result.Passed = $false
    }

    return $result
}

function Compare-DevProd {
    return Test-DevProdDiff
}


# =====================================================================
#  SYNC GATE — ENSURES DEV & PROD MATCH BEFORE PROMOTION
# =====================================================================

function Sync-DevToProd {

    $diff = Test-DevProdDiff

    if ($diff.Passed) {
        return [PSCustomObject]@{
            Name   = "SyncGate"
            Passed = $true
            Errors = @()
        }
    }

    return [PSCustomObject]@{
        Name   = "SyncGate"
        Passed = $false
        Errors = @(
            "Dev and Prod differ.",
            "Only in Dev: $($diff.OnlyInDev -join ', ')",
            "Only in Prod: $($diff.OnlyInProd -join ', ')",
            "Modified: $($diff.Modified -join ', ')"
        )
    }
}


# =====================================================================
#  PREFLIGHT (DEV & PROD)
# =====================================================================

function Invoke-Preflight {

    $results = @(
        Test-Readme
        Test-Links
        Test-Gitignore
        Test-RepoHygiene
        Test-BranchState
    )

    return [PSCustomObject]@{
        Name    = "Preflight"
        Passed  = ($results.Passed -notcontains $false)
        Results = $results
    }
}

function Invoke-PreflightProd {

    $original = $DevPath
    $script:DevPath = $ProdPath

    $result = Invoke-Preflight

    $script:DevPath = $original

    return $result
}


# =====================================================================
#  PROMOTION PIPELINE — DEV → PROD MIRRORING
# =====================================================================

function Promote-ToProd {

    $sync = Sync-DevToProd
    if (-not $sync.Passed) {
        return [PSCustomObject]@{
            Name   = "Promote"
            Passed = $false
            Errors = @("Sync gate failed. Promotion aborted.")
        }
    }

    robocopy $DevPath $ProdPath /MIR /NFL /NDL /NJH /NJS /NP | Out-Null

    if ($LASTEXITCODE -ge 8) {
        return [PSCustomObject]@{
            Name   = "Promote"
            Passed = $false
            Errors = @("Robocopy reported an error during promotion.")
        }
    }

    return [PSCustomObject]@{
        Name   = "Promote"
        Passed = $true
        Errors = @()
    }
}


# =====================================================================
#  TOP-LEVEL ORCHESTRATOR — ONE-LINE SDLC WORKFLOW
# =====================================================================

function Run-Pipeline {

    $dev = Invoke-Preflight
    if (-not $dev.Passed) { return $dev }

    $prod = Invoke-PreflightProd
    if (-not $prod.Passed) { return $prod }

    $sync = Sync-DevToProd
    if (-not $sync.Passed) { return $sync }

    $promote = Promote-ToProd
    return $promote
}


# =====================================================================
#  EXPORT PUBLIC FUNCTIONS
# =====================================================================

Export-ModuleMember -Function `
    Test-Readme, Test-Links, Test-Gitignore, Test-RepoHygiene, Test-BranchState, `
    Compare-DevProd, Invoke-Preflight, Invoke-PreflightProd, `
    Promote-ToProd, Run-Pipeline, Sync-DevToProd