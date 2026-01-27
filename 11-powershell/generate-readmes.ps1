<#
.SYNOPSIS
  Recursively walks the repo and ensures every folder contains a professional README.md.
  - Creates README.md if missing
  - Updates README.md if it exists
  - Inserts folder-specific descriptions based on folder name

.DESCRIPTION
  Idempotent. Safe to run repeatedly. Produces consistent, professional documentation.
#>

param(
    [string]$RepoRoot = (Get-Location).Path
)

# --------------------------------------------------------------------
# Folder description map (extend anytime)
# --------------------------------------------------------------------
$FolderDescriptions = @{
    "azure-data-factory"      = "Contains Azure Data Factory assets including pipelines, datasets, linked services, and triggers."
    "pipelines"               = "Contains pipeline definitions and documentation."
    "datasets"                = "Contains dataset definitions and documentation."
    "linked-services"         = "Contains linked service definitions and connection metadata."
    "triggers"                = "Contains trigger definitions and scheduling metadata."
    "integration-runtimes"    = "Contains integration runtime configuration and documentation."
    "global-parameters"       = "Contains global parameter definitions for ADF."
    "fabric-data-factory"     = "Contains Fabric Data Factory pipelines, dataflows, and connection documentation."
    "dataflows"               = "Contains Dataflow Gen2 definitions or documentation."
    "connections"             = "Contains Fabric connection and gateway documentation."
    "power-automate"          = "Contains Power Automate flow exports and documentation."
    "flows"                   = "Contains exported flow definitions (definition.json, connections.json, manifest.json)."
    "sql"                     = "Contains SQL objects including tables, views, stored procedures, and scripts."
    "tables"                  = "Contains SQL table creation scripts."
    "views"                   = "Contains SQL view definitions."
    "stored-procedures"       = "Contains SQL stored procedure definitions."
    "scripts"                 = "Contains utility SQL scripts."
    "docs"                    = "Contains project documentation, architecture notes, and modernization narrative."
    "modernization"           = "Contains documentation of the end-to-end modernization journey."
}

# --------------------------------------------------------------------
# Function: Generate README content
# --------------------------------------------------------------------
function Get-ReadmeContent {
    param(
        [string]$FolderName,
        [string]$FullPath
    )

    $description = $FolderDescriptions[$FolderName]
    if (-not $description) {
        $description = "This folder contains project assets related to $FolderName."
    }

    return @"
# $FolderName

$description

## Location
$FullPath

## Notes
This README was automatically generated or updated to maintain consistent documentation across the repository.
"@
}

# --------------------------------------------------------------------
# Main: Walk repo and update/create README.md
# --------------------------------------------------------------------
Write-Output "Scanning repo: $RepoRoot"

$folders = Get-ChildItem -Path $RepoRoot -Directory -Recurse

foreach ($folder in $folders) {
    $readmePath = Join-Path $folder.FullName "README.md"
    $folderName = $folder.Name

    $content = Get-ReadmeContent -FolderName $folderName -FullPath $folder.FullName

    if (Test-Path $readmePath) {
        Write-Output "Updating README: $readmePath"
        Set-Content -Path $readmePath -Value $content -Encoding UTF8
    }
    else {
        Write-Output "Creating README: $readmePath"
        Set-Content -Path $readmePath -Value $content -Encoding UTF8
    }
}

Write-Output "README generation and update complete."
