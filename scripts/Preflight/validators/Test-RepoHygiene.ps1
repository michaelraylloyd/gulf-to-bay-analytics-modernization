function Test-RepoHygiene {
    $result = [PSCustomObject]@{
        Name        = "Hygiene"
        Passed      = $true
        Errors      = @()
        Warnings    = @()
        Suggestions = @()
    }

    $forbidden = @(
        "*.tmp",
        "*.bak",
        "*.old",
        "*~"
    )

    foreach ($pattern in $forbidden) {
        $matches = Get-ChildItem -Path $DevPath -Recurse -Filter $pattern -ErrorAction SilentlyContinue
        if ($matches) {
            $result.Passed = $false
            $result.Errors += "Found forbidden file(s): $pattern"
        }
    }

    return $result
}