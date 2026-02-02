# ============================================================
# New-RepoReadmes.ps1
# Creates README.md files in any folder missing one.
# ============================================================

param(
    [Parameter(Mandatory=\False)]
    [string] \ = (Get-Location).Path
)

Write-Host "Generating missing README.md files under \" -ForegroundColor Cyan

Get-ChildItem -Path \ -Recurse -Directory |
    ForEach-Object {
        \ = Join-Path \.FullName "README.md"
        if (-not (Test-Path \)) {
            "# README for \
" | Set-Content -Path \ -Encoding UTF8
            Write-Host "Created: \" -ForegroundColor Green
        }
    }
