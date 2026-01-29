function Test-Links {
    $result = [PSCustomObject]@{
        Name        = "Links"
        Passed      = $true
        Errors      = @()
        Warnings    = @()
        Suggestions = @()
    }

    $readmePath = Join-Path $DevPath "README.md"
    if (-not (Test-Path $readmePath)) {
        $result.Passed = $false
        $result.Errors += "README.md not found — cannot validate links."
        return $result
    }

    $content = Get-Content $readmePath -Raw
    $links = Select-String -InputObject $content -Pattern "\[[^\]]+\]\(([^)]+)\)" -AllMatches |
             ForEach-Object { $_.Matches.Groups[1].Value }

    foreach ($link in $links) {
        if ($link -match "^http") {
            try {
                $response = Invoke-WebRequest -Uri $link -Method Head -TimeoutSec 5 -ErrorAction Stop
            }
            catch {
                $result.Passed = $false
                $result.Errors += "Broken link: $link"
            }
        }
    }

    return $result
}