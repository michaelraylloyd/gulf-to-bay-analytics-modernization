# =====================================================================
#  SECTION 1 — CONFIGURATION & MODULE SETUP
# =====================================================================

$DevPath  = "C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev"
$ProdPath = "C:\Repos\Prod\gulf-to-bay-analytics-modernization"

Set-Variable -Name DevPath  -Value $DevPath  -Scope Global -Force
Set-Variable -Name ProdPath -Value $ProdPath -Scope Global -Force

. $PSScriptRoot\validators\Test-Readme.ps1
. $PSScriptRoot\validators\Test-Links.ps1
. $PSScriptRoot\validators\Test-Gitignore.ps1
. $PSScriptRoot\validators\Test-RepoHygiene.ps1
. $PSScriptRoot\validators\Test-BranchState.ps1


# =====================================================================
#  SECTION 2 — VALIDATORS & PIPELINE FUNCTIONS
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
    param(
        [switch]$Publish,
        [string]$CommitMessage = "Promotion: Dev → Prod sync and publish"
    )

    # PHASE 1 — DEV PREFLIGHT
    $dev = Invoke-Preflight
    if (-not $dev.Passed) {
        return [PSCustomObject]@{
            Name    = "Pipeline"
            Passed  = $false
            Stage   = "Dev Preflight"
            Details = $dev
        }
    }

    # PHASE 2 — PROD PREFLIGHT
    $prod = Invoke-PreflightProd
    if (-not $prod.Passed) {
        return [PSCustomObject]@{
            Name    = "Pipeline"
            Passed  = $false
            Stage   = "Prod Preflight"
            Details = $prod
        }
    }

    # PHASE 3 — SYNC GATE
    $sync = Sync-DevToProd
    if (-not $sync.Passed) {
        return [PSCustomObject]@{
            Name    = "Pipeline"
            Passed  = $false
            Stage   = "Sync Gate"
            Details = $sync
        }
    }

    # PHASE 4 — PROMOTION
    $promote = Promote-ToProd
    if (-not $promote.Passed) {
        return [PSCustomObject]@{
            Name    = "Pipeline"
            Passed  = $false
            Stage   = "Promotion"
            Details = $promote
        }
    }

    # PHASE 5 — OPTIONAL GIT PUBLISH
    if ($Publish) {

        $repoRoot = git rev-parse --show-toplevel 2>$null
        if (-not $repoRoot) {
            return [PSCustomObject]@{
                Name    = "Pipeline"
                Passed  = $false
                Stage   = "Git Publish"
                Details = "Not inside a Git repository."
            }
        }

        $originalLocation = Get-Location
        Set-Location $repoRoot

        try {
            $conflicts = git diff --name-only --diff-filter=U
            if ($conflicts) {
                return [PSCustomObject]@{
                    Name    = "Pipeline"
                    Passed  = $false
                    Stage   = "Git Publish"
                    Details = "Merge conflicts detected: $($conflicts -join ', ')"
                }
            }

            $pending = git status --porcelain
            if (-not $pending) {
                return [PSCustomObject]@{
                    Name    = "Pipeline"
                    Passed  = $true
                    Stage   = "Complete (No Git Changes)"
                    Details = @{
                        DevPreflight   = $dev
                        ProdPreflight  = $prod
                        SyncGate       = $sync
                        Promotion      = $promote
                        GitPublish     = "No changes to commit."
                    }
                }
            }

            $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            $finalMessage = "$CommitMessage — $timestamp"

            git add .
            git commit -m "$finalMessage"
            git push

            return [PSCustomObject]@{
                Name    = "Pipeline"
                Passed  = $true
                Stage   = "Complete + Published"
                Details = @{
                    DevPreflight   = $dev
                    ProdPreflight  = $prod
                    SyncGate       = $sync
                    Promotion      = $promote
                    GitPublish     = "Committed and pushed: $finalMessage"
                }
            }
        }
        finally {
            Set-Location $originalLocation
        }
    }

    return [PSCustomObject]@{
        Name    = "Pipeline"
        Passed  = $true
        Stage   = "Complete"
        Details = @{
            DevPreflight   = $dev
            ProdPreflight  = $prod
            SyncGate       = $sync
            Promotion      = $promote
        }
    }
}


# =====================================================================
#  EXPORT PUBLIC FUNCTIONS
# =====================================================================

Export-ModuleMember -Function `
    Test-Readme, Test-Links, Test-Gitignore, Test-RepoHygiene, Test-BranchState, `
    Compare-DevProd, Invoke-Preflight, Invoke-PreflightProd, `
    Promote-ToProd, Run-Pipeline, Sync-DevToProd