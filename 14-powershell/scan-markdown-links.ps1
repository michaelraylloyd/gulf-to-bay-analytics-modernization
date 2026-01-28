# Root of the repo (DEV)
$root = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization-dev"

Write-Host "Scanning for outdated or broken links..." -ForegroundColor Cyan

# Patterns to detect
$patterns = @(
    "15-docs",
    "16-images",
    "\]\("  # any markdown link
)

Get-ChildItem -Path $root -Recurse -Filter *.md | ForEach-Object {
    $file = $_.FullName
    $lines = Get-Content $file

    for ($i = 0; $i -lt $lines.Count; $i++) {
        foreach ($pattern in $patterns) {
            if ($lines[$i] -match $pattern) {
                Write-Host "`nFile: $file" -ForegroundColor Yellow
                Write-Host "Line $($i+1): $($lines[$i])" -ForegroundColor White
            }
        }
    }
}

Write-Host "`nScan complete." -ForegroundColor Green