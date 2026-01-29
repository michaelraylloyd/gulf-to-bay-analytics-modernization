function Test-BranchState {
    $result = [PSCustomObject]@{
        Name        = "Branch"
        Passed      = $true
        Errors      = @()
        Warnings    = @()
        Suggestions = @()
    }

    $branch = git -C $DevPath rev-parse --abbrev-ref HEAD

    if ($branch -ne "main" -and $branch -ne "dev") {
        $result.Passed = $false
        $result.Errors += "You are on branch '$branch'. Expected 'main' or 'dev'."
    }

    return $result
}