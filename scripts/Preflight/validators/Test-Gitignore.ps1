function Test-Gitignore {
    $result = [PSCustomObject]@{
        Name        = "Gitignore"
        Passed      = $true
        Errors      = @()
        Warnings    = @()
        Suggestions = @()
    }

    $path = Join-Path $DevPath ".gitignore"

    if (-not (Test-Path $path)) {
        $result.Passed = $false
        $result.Errors += ".gitignore file is missing."
        return $result
    }

    $content = Get-Content $path

    $required = @(
        "bin/",
        "obj/",
        ".env",
        "*.user",
        "*.DS_Store"
    )

    foreach ($item in $required) {
        if ($content -notcontains $item) {
            $result.Warnings += "Recommended ignore entry missing: $item"
        }
    }

    return $result
}