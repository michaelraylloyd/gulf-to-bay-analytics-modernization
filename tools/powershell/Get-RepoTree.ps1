# ============================================================
# Get-RepoTree.ps1
# Generates a full ASCII tree of the repository.
# ============================================================

param(
    [Parameter(Mandatory = $false)]
    [string]$Path = (Get-Location).Path
)

Write-Host "Generating repo tree for: $Path" -ForegroundColor Cyan

tree $Path /F