<# =====================================================================
 HOW TO RUN THIS SCRIPT
 -----------------------------------------------------------------------
 1. Open PowerShell *inside the Dev repo* or anywhere else.
    It does NOT matter where you start.

 2. Run the script using the full path:

       F:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\tools\powershell\Promote-DevToProd.ps1

    Example:

       & "F:\Repos\Dev\gulf-to-bay-analytics-modernization-dev\tools\powershell\Promote-DevToProd.ps1"

 3. What the script does:
       - Switches to Dev
       - Shows Dev status
       - Fetches Dev origin
       - Switches to Prod
       - Fetches Dev into Prod
       - Hard resets Prod to Dev/main
       - Pushes to Prod origin main --force
       - Prints everything as it happens

 4. What the script does NOT do:
       - It does NOT touch your PowerShell profile
       - It does NOT validate branches
       - It does NOT block on uncommitted changes
       - It does NOT try to be clever
       - It does NOT hide anything

 5. If GitHub blocks the push due to secret scanning:
       - Approve the override in GitHub
       - Re-run the script

 ===================================================================== #>

Write-Host "=== PROMOTE DEV → PROD (SIMPLE) ===" -ForegroundColor Cyan

$devPath  = "F:\Repos\Dev\gulf-to-bay-analytics-modernization-dev"
$prodPath = "F:\Repos\Prod\gulf-to-bay-analytics-modernization"

Write-Host "`n[1] Switching to DEV: $devPath" -ForegroundColor Yellow
Set-Location $devPath

Write-Host "`n[2] DEV status:" -ForegroundColor Yellow
git status

Write-Host "`n[3] Fetching DEV origin..." -ForegroundColor Yellow
git fetch origin

Write-Host "`n[4] Switching to PROD: $prodPath" -ForegroundColor Yellow
Set-Location $prodPath

Write-Host "`n[5] Fetching DEV into PROD (remote 'dev')..." -ForegroundColor Yellow
git fetch dev

Write-Host "`n[6] HARD RESET PROD to dev/main..." -ForegroundColor Yellow
git reset --hard dev/main

Write-Host "`n[7] PUSHING to PROD origin main --force..." -ForegroundColor Yellow
git push origin main --force

Write-Host "`n=== PROMOTION COMPLETE (SIMPLE) ===" -ForegroundColor Cyan