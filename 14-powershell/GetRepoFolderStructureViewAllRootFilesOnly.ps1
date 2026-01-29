# List folders and subfolders only, exclude files except in root
$repoRoot = "C:\Repos\Dev\gulf-to-bay-analytics-modernization-dev"

Write-Host "`n📁 Folders and Subfolders:`n"

Get-ChildItem -Path $repoRoot -Directory -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Replace($repoRoot, "").TrimStart("\")
    Write-Host $relativePath
}

Write-Host "`n📄 Files in Root:`n"

Get-ChildItem -Path $repoRoot -File | ForEach-Object {
    Write-Host $_.Name
}