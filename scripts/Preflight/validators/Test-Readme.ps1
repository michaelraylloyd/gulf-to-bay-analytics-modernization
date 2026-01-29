function Test-Readme {
    $result = [PSCustomObject]@{
        Name        = "README"
        Passed      = $true
        Errors      = @()
        Warnings    = @()
        Suggestions = @()
    }

    $readmePath = Join-Path $DevPath "README.md"

    if (-not (Test-Path $readmePath)) {
        $result.Passed = $false
        $result.Errors += "README.md not found in Dev repo."
        return $result
    }

    $content = Get-Content $readmePath -Raw

    if ($content.Length -lt 50) {
        $result.Warnings += "README.md is very short — consider adding project context."
    }

    if ($content -notmatch "# ") {
        $result.Warnings += "README.md has no top-level heading."
    }

    return $result
}