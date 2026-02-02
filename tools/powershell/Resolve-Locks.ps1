# ============================================================
# Resolve-Locks.ps1
# Attempts to release Windows file locks by terminating
# processes holding handles on the target path.
# ============================================================

param(
    [Parameter(Mandatory=$true)]
    [string] $TargetPath
)

Write-Host "Attempting to resolve locks on: $TargetPath" -ForegroundColor Cyan

Get-Process | ForEach-Object {
    try {
        $handles = (Get-Process -Id $_.Id -ErrorAction SilentlyContinue).Modules |
            Where-Object { $_.FileName -like "*$TargetPath*" }

        if ($handles) {
            Write-Host "Killing process $($_.Name) ($($_.Id))" -ForegroundColor Yellow
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
        }
    } catch {}
}

Write-Host "Lock resolution attempt complete." -ForegroundColor Green