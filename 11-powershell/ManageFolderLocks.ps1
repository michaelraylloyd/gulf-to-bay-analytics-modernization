# Wrapper to detect and optionally kill processes locking a folder
$handlePath = "C:\Users\Public\Artifacts\_GitRepoScripts\Handle\handle64.exe"
$targetFolder = "C:\Users\Public\1MRLloydWorkProjects\GulfToBay_OnPrem_Analytics"

# Run handle64.exe and capture output
$handleOutput = & $handlePath $targetFolder 2>&1

if ($handleOutput -match "No matching handles found") {
    Write-Host "`n✅ No locks detected on folder:`n$targetFolder"
} else {
    Write-Host "`n🔒 Locks detected:`n"
    $handleOutput | ForEach-Object { Write-Host $_ }

    # Extract PIDs from output
    $pids = ($handleOutput | Select-String -Pattern "pid: (\d+)" | ForEach-Object {
        ($_ -match "pid: (\d+)") | Out-Null
        $matches[1]
    }) | Sort-Object -Unique

    if ($pids.Count -gt 0) {
        Write-Host "`n⚠️ Processes holding locks:`n"
        $pids | ForEach-Object { Write-Host "PID: $_" }

        # Prompt to kill
        $confirm = Read-Host "`nDo you want to kill these processes? (y/n)"
        if ($confirm -eq "y") {
            foreach ($procId in $pids) {
                try {
                    Stop-Process -Id $procId -Force
                    Write-Host "✅ Killed PID ${procId}"
                } catch {
                    Write-Host "❌ Failed to kill PID ${procId}: $_"
                }
            }
        } else {
            Write-Host "🛑 No processes were terminated."
        }
    } else {
        Write-Host "⚠️ No PIDs found, but locks may still exist."
    }
}
