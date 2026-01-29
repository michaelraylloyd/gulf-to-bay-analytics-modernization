# =====================================================================
# Gulf to Bay Analytics — Lakehouse Expansion
# Folder Scaffold + README Promulgation Script
# =====================================================================

# Set Dev root (adjust if needed)
$root = "C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev"

# New Lakehouse project folder
$proj = Join-Path $root "15-lakehouse-expansion"

# Generic README generator (matches your modernization style)
function New-GenericReadme {
    param(
        [string]$FolderPath
    )

    $folderName = Split-Path $FolderPath -Leaf
    $cleanName = ($folderName -replace "^\d+-", "") -replace "-", " "
    $cleanName = $cleanName.Substring(0,1).ToUpper() + $cleanName.Substring(1)

    $content = @"
# $cleanName

This folder is part of the Gulf to Bay Analytics modernization project.  
It contains assets, scripts, or resources related to **$cleanName**, aligned with the overall goal of creating a clean, automated, cloud‑ready analytics ecosystem.

## Purpose

This folder contributes to the modernization effort by organizing work related to **$cleanName** in a clear, maintainable structure.

## Contents

This folder may include:
- Source files
- Scripts
- Configuration
- Supporting assets

## Modernization Context

As part of the end‑to‑end modernization, this folder helps ensure:
- Clean separation of responsibilities
- Improved maintainability
- Consistent documentation
- Recruiter‑ready project organization
"@

    $readmePath = Join-Path $FolderPath "README.md"
    $content | Out-File -FilePath $readmePath -Encoding UTF8
}

# ---------------------------------------------------------------------
# Folder structure definition
# ---------------------------------------------------------------------

$folders = @(
    "$proj",
    "$proj\notebooks",
    "$proj\notebooks\bronze_ingest",
    "$proj\notebooks\silver_transform",
    "$proj\notebooks\gold_modeling",
    "$proj\notebooks\streaming_ingest",
    "$proj\notebooks\exploration",

    "$proj\pipelines",
    "$proj\pipelines\dlt",
    "$proj\pipelines\batch",

    "$proj\delta",
    "$proj\delta\bronze",
    "$proj\delta\silver",
    "$proj\delta\gold",

    "$proj\tests",
    "$proj\tests\pyspark",
    "$proj\tests\delta_validation",

    "$proj\docs",
    "$proj\docs\architecture",
    "$proj\docs\lakehouse_overview",
    "$proj\docs\pipeline_walkthrough",
    "$proj\docs\data_dictionary",
    "$proj\docs\real_time_analytics",

    "$proj\.github",
    "$proj\.github\workflows"
)

# ---------------------------------------------------------------------
# Create folders + README.md files
# ---------------------------------------------------------------------

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }

    # Add README.md to each directory
    New-GenericReadme -FolderPath $folder
}

# ---------------------------------------------------------------------
# Create placeholder CI/CD file
# ---------------------------------------------------------------------

$ciPath = Join-Path $proj ".github\workflows\ci_cd.yml"
if (-not (Test-Path $ciPath)) {
@"
# Placeholder CI/CD workflow for Lakehouse Expansion
# GitHub Actions pipeline will be added in future iterations.
"@ | Out-File -FilePath $ciPath -Encoding UTF8
}

Write-Host "Lakehouse Expansion scaffold created successfully at: $proj"