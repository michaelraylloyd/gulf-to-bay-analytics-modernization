# Root of your repo
$repoRoot = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization"

# The GTB-standard .gitignore content
$gitignoreContent = @"
# ----------------------------------------
# SQL Server
# ----------------------------------------
*.bak
*.mdf
*.ldf
*.trn
*.dacpac
*.bacpac

# ----------------------------------------
# SSAS / SSIS / SSDT Artifacts
# ----------------------------------------
bin/
obj/
*.abf
*.asdatabase
*.deploymentoptions
*.deploymenttargets
*.settings
*.user
*.suo
*.cache
*.ispac
*.dwproj.user
*.smproj.user

# ----------------------------------------
# Power BI
# ----------------------------------------
*.pbix
*.pbit
*.rdl.data
*.rds

# ----------------------------------------
# Python
# ----------------------------------------
.venv/
__pycache__/
*.pyc
env/
venv/

# ----------------------------------------
# Environment Variables
# ----------------------------------------
*.env
*.env.local
config.env

# ----------------------------------------
# PowerShell
# ----------------------------------------
*.ps1.psd1
*.ps1.psm1

# ----------------------------------------
# Repo Inventory / Generated Files
# ----------------------------------------
RepoInventory.csv

# ----------------------------------------
# Artifacts Folder (your new folder)
# ----------------------------------------
Artifacts/
artifacts/

# ----------------------------------------
# Power Apps (Canvas App Unpacked Artifacts)
# ----------------------------------------
/[Cc]ontrols/
/[Cc]hecksum.json
/[Hh]eader.json
/[Aa]pp[Cc]hecker[Rr]esult.sarif
*.msapp

# ----------------------------------------
# Logs
# ----------------------------------------
*.log
logs/
Log/
LOG/

# ----------------------------------------
# IDE / Editor
# ----------------------------------------
.vscode/
.idea/

# ----------------------------------------
# OS Junk
# ----------------------------------------
Thumbs.db
.DS_Store

# ----------------------------------------
# R
# ----------------------------------------
.Rhistory
.RData
.Rproj.user/
.Ruserdata/
.Rproj.user
*.Rproj
.Rapp.history

# ----------------------------------------
# Databricks
# ----------------------------------------
# Local notebook checkpoints
*.dbc
*.dbc.zip
*.dbarchive

# Databricks Repos metadata
*.repo/
*.databricks/

# Python/R temp inside Databricks
**/.ipynb_checkpoints/
**/.Rproj.user/

# ----------------------------------------
# Dataverse / Power Platform ALM
# ----------------------------------------
# Solution unpack artifacts
**/Other/
**/Customizations/
**/Workflows/
**/PluginAssemblies/
**/WebResources/

# Power Platform CLI temp
.ppac/
*.zip
*.solution.zip
*.managed.zip
*.unmanaged.zip

# Dataverse dataflow temp
*.cdm.json
*.manifest.cdm.json
"@

# 1. Update all existing .gitignore files
$gitignoreFiles = Get-ChildItem -Path $repoRoot -Filter ".gitignore" -Recurse -File

foreach ($file in $gitignoreFiles) {
    Write-Host "Updating existing: $($file.FullName)"
    Set-Content -Path $file.FullName -Value $gitignoreContent -Encoding UTF8
}

# 2. Create .gitignore where missing
$allFolders = Get-ChildItem -Path $repoRoot -Recurse -Directory

foreach ($folder in $allFolders) {
    $gitignorePath = Join-Path $folder.FullName ".gitignore"

    if (-not (Test-Path $gitignorePath)) {
        Write-Host "Creating missing: $gitignorePath"
        Set-Content -Path $gitignorePath -Value $gitignoreContent -Encoding UTF8
    }
}

Write-Host "All .gitignore files updated or created."