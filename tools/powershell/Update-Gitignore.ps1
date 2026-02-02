# ============================================================
# Update-Gitignore.ps1
# Rewrites .gitignore with a clean, standard template.
# ============================================================

param(
    [Parameter(Mandatory=\False)]
    [string] \ = (Get-Location).Path
)

\ = Join-Path \ ".gitignore"

\ = @'
# Standard Gitignore
.ipynb_checkpoints/
__pycache__/
*.tmp
*.log
*.bak
*.DS_Store
'@

Write-Host "Updating .gitignore at \" -ForegroundColor Cyan
\ | Set-Content -Path \ -Encoding UTF8
