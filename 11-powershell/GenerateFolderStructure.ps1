$repoRoot = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization"

Write-Host "`n📁 Folders and Subfolders:`n"

Get-ChildItem -Path $repoRoot -Directory -Recurse |
    Select-Object -ExpandProperty FullName |
    ForEach-Object { $_.Replace($repoRoot, "").TrimStart("\") } |
    Sort-Object |
    Write-Output

Write-Host "`n📄 Files in Root:`n"

Get-ChildItem -Path $repoRoot -File |
    Select-Object -ExpandProperty Name |
    Sort-Object |
    Write-Output
