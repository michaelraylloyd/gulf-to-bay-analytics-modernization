$root = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization"

Get-ChildItem -Path $root -Directory -Recurse | ForEach-Object {
    $folder = $_.FullName
    $readme = Join-Path $folder "README.md"

    Write-Host "----------------------------------------"
    Write-Host "Folder: $folder"

    if (Test-Path $readme) {
        Write-Host "README.md: Present"
    }
    else {
        Write-Host "README.md: MISSING"
    }
}

# Also check the root folder itself
$rootReadme = Join-Path $root "README.md"
Write-Host "----------------------------------------"
Write-Host "Folder: $root"
Write-Host ("README.md: " + (if (Test-Path $rootReadme) {"Present"} else {"MISSING"}))