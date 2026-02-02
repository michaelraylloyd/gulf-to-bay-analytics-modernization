# ============================================================
# Search-Repo.ps1
# Recursively searches for a text pattern inside the repo.
# ============================================================

param(
    [Parameter(Mandatory=\True)]
    [string] \,

    [Parameter(Mandatory=\False)]
    [string] \ = (Get-Location).Path
)

Write-Host "Searching for pattern '\' under \" -ForegroundColor Cyan

Get-ChildItem -Path \ -Recurse -File |
    Select-String -Pattern \ -SimpleMatch |
    Select-Object Filename, LineNumber, Line
