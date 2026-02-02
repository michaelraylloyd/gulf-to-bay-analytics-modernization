# ============================================================
# Test-MarkdownLinks.ps1
# Scans markdown files for broken relative links.
# ============================================================

param(
    [Parameter(Mandatory=\False)]
    [string] \ = (Get-Location).Path
)

Write-Host "Scanning markdown links under \" -ForegroundColor Cyan

Get-ChildItem -Path \ -Recurse -Filter *.md |
    ForEach-Object {
        \ = Get-Content \.FullName
        foreach (\ in \) {
            if (\ -match "\[(.*?)\]\((.*?)\)") {
                \ = \[2]
                if (\ -notmatch "^http" -and -not (Test-Path (Join-Path \ \))) {
                    Write-Host "Broken link in \: \" -ForegroundColor Red
                }
            }
        }
    }
