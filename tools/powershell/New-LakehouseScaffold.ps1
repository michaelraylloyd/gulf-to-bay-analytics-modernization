# ============================================================
# New-LakehouseScaffold.ps1
# Creates Bronze/Silver/Gold folders with README.md files.
# ============================================================

param(
    [Parameter(Mandatory=\True)]
    [string] \C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\14-powershell
)

Write-Host "Creating Lakehouse scaffold under \C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\14-powershell" -ForegroundColor Cyan

\ = @(
    "bronze",
    "silver",
    "gold"
)

foreach (\ in \) {
    \ = Join-Path \C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\14-powershell \
    if (-not (Test-Path \)) {
        New-Item -ItemType Directory -Path \ | Out-Null
        Write-Host "Created folder: \" -ForegroundColor Green
    }

    \ = Join-Path \ "README.md"
    if (-not (Test-Path \)) {
        "# \ layer
" | Set-Content -Path \ -Encoding UTF8
        Write-Host "Created README: \" -ForegroundColor Yellow
    }
}
