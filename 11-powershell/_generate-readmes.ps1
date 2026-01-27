# Root of the repo
$root = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization"

# Folder to skip (special handling)
$skipDocsPortfolio = Join-Path $root "12-docs\portfolio-overview"

# Function to convert folder names like "03-sql-server" → "SQL Server"
function Convert-FolderName {
    param($name)
    $clean = $name -replace "^\d+-", ""
    $clean = $clean -replace "-", " "
    return ($clean.Substring(0,1).ToUpper() + $clean.Substring(1))
}

# Function to generate README content
function Get-ReadmeContent {
    param($folderPath)

    $folderName = Split-Path $folderPath -Leaf
    $title = Convert-FolderName $folderName

    return @"
# $title

This folder is part of the Gulf to Bay Analytics modernization project.  
It contains assets, scripts, or resources related to **$title**, aligned with the overall goal of creating a clean, automated, cloud‑ready analytics ecosystem.

## Purpose

This folder contributes to the modernization effort by organizing work related to **$title** in a clear, maintainable structure.

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
}

# Walk all folders
Get-ChildItem -Path $root -Directory -Recurse | ForEach-Object {

    $folder = $_.FullName

    # Skip the root folder
    if ($folder -eq $root) { return }

    # Skip the special docs folder entirely
    if ($folder -eq $skipDocsPortfolio) { return }

    # Look for README variants
    $existingReadme = Get-ChildItem -Path $folder -File |
        Where-Object { $_.Name -match "^readme(\.md)?$" }

    $readmePath = Join-Path $folder "README.md"
    $content = Get-ReadmeContent -folderPath $folder

    if ($existingReadme) {
        # Overwrite existing README
        $existingPath = $existingReadme.FullName
        $content | Out-File -FilePath $existingPath -Encoding UTF8
        Write-Host "Updated README in $folder"
    }
    else {
        # Create new README
        $content | Out-File -FilePath $readmePath -Encoding UTF8
        Write-Host "Created README in $folder"
    }
}