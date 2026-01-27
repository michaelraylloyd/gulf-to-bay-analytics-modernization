Get-ChildItem -Path "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization" -Recurse |
    Select-Object `
        @{Name="FullPath";Expression={$_.FullName}},
        @{Name="Folder";Expression={$_.DirectoryName}},
        @{Name="Name";Expression={$_.Name}},
        @{Name="Type";Expression={if ($_.PSIsContainer) {"Folder"} else {"File"}}},
        @{Name="Extension";Expression={$_.Extension}} |
    Export-Csv -Path "C:\Users\Public\RepoInventory.csv"