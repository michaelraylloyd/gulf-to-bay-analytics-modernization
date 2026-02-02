# ============================================================
# Update-RepoDocumentation.ps1
# Ensures required folders + README.md files exist and updates
# them with dynamic content. Also propagates .gitignore files.
# ============================================================

param(
    [string]$Root = (Get-Location).Path
)

Write-Host "Running documentation promulgation from: $Root" -ForegroundColor Cyan

# -----------------------------
# 1. Required folder structure
# -----------------------------
$RequiredFolders = @(
    "docs",
    "docs\bronze",
    "docs\silver",
    "docs\gold",
    "docs\architecture",
    "docs\pipelines",
    "docs\semantic-model",
    "docs\data-dictionary",
    "docs\data-dictionary\bronze",
    "docs\data-dictionary\silver",
    "docs\data-dictionary\gold"
)

foreach ($folder in $RequiredFolders) {
    $fullPath = Join-Path $Root $folder
    if (-not (Test-Path $fullPath)) {
        Write-Host "Creating folder: $folder" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $fullPath | Out-Null
    }
}

# -----------------------------
# 2. Required README files
# -----------------------------
$RequiredReadmes = @(
    "README.md",
    "docs\bronze\README.md",
    "docs\silver\README.md",
    "docs\gold\README.md",
    "docs\architecture\README.md",
    "docs\pipelines\README.md",
    "docs\semantic-model\README.md",
    "docs\data-dictionary\bronze\README.md",
    "docs\data-dictionary\silver\README.md",
    "docs\data-dictionary\gold\README.md"
)

# -----------------------------
# 3. Dynamic content generator
# -----------------------------
function Get-DynamicContent {
    param([string]$SectionName)

    switch ($SectionName) {

        "bronze" {
            return @"
# Bronze Layer Documentation
This section describes the ingestion layer for the Sales Analytics Lakehouse.
It includes raw data ingestion, schema alignment, and exception handling.
"@
        }

        "silver" {
            return @"
# Silver Layer Documentation
This section covers the transformation logic applied to Bronze data.
It includes type enforcement, normalization, and exception routing.
"@
        }

        "gold" {
            return @"
# Gold Layer Documentation
This section describes the dimensional modeling layer.
It includes surrogate key creation, fact/dimension tables, and join validation.
"@
        }

        "architecture" {
            return @"
# Architecture Overview
This document outlines the medallion architecture for the Sales Analytics Lakehouse.
It includes Bronze → Silver → Gold flow, SQL views, and semantic model integration.
"@
        }

        "pipelines" {
            return @"
# Pipeline Documentation
This folder contains the orchestration pipeline that runs Bronze, Silver, and Gold notebooks.
"@
        }

        "semantic-model" {
            return @"
# Semantic Model Documentation
This section describes the semantic layer used for reporting and analytics.
"@
        }

        default {
            return "# Documentation"
        }
    }
}

# -----------------------------
# 4. Create or update README.md
# -----------------------------
foreach ($readme in $RequiredReadmes) {
    $fullPath = Join-Path $Root $readme
    $section = Split-Path $readme -LeafBase

    $content = Get-DynamicContent -SectionName $section

    if (-not (Test-Path $fullPath)) {
        Write-Host "Creating README: $readme" -ForegroundColor Green
        Set-Content -Path $fullPath -Value $content
    }
    else {
        Write-Host "Updating README: $readme" -ForegroundColor Cyan
        Set-Content -Path $fullPath -Value $content
    }
}

# -----------------------------
# 5. Propagate .gitignore
# -----------------------------
$rootGitignore = Join-Path $Root ".gitignore"

if (Test-Path $rootGitignore) {
    Write-Host "Propagating .gitignore to subfolders..." -ForegroundColor Magenta

    Get-ChildItem -Path $Root -Recurse -Directory |
        Where-Object { $_.FullName -notmatch "\\\.git" } |
        ForEach-Object {
            $target = Join-Path $_.FullName ".gitignore"
            Copy-Item -Path $rootGitignore -Destination $target -Force
        }
}

Write-Host "Documentation + .gitignore propagation complete." -ForegroundColor Green