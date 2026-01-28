# ============================
# CONFIGURATION
# ============================

# Azure SQL DB connection
$azureServer   = "gtb-sqlserver.database.windows.net"
$azureDatabase = "AdventureWorksCloud"      # adjust if needed
$azureUser     = "sqladmin"                 # adjust
$azurePassword = "The Af!95863274"       # adjust

# On-prem SQL Server connection
$localServer   = "DESKTOP-JIA1LJ1\SQLEXPRESS"
$localDatabase = "AdventureWorks2019"       # adjust if needed

# Output folders
$azureOutput = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization\03-sql-server\csv\azure"
$localOutput = "C:\Users\Public\_MRLloydWorkProjects\gulf-to-bay-analytics-modernization\03-sql-server\csv\local"

# Ensure output folders exist
foreach ($folder in @($azureOutput, $localOutput)) {
    if (!(Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder | Out-Null
    }
}

# Tables to export (schema-qualified)
$tables = @(
    "Sales.SalesOrderHeader",
    "Sales.SalesOrderDetail",
    "Sales.Customer",
    "Production.Product"
)

# ============================
# EXPORT FROM AZURE SQL DB
# ============================

Write-Host "`n=== Exporting from Azure SQL DB ===`n"

foreach ($table in $tables) {
    Write-Host "Exporting $table from Azure..."

    $query = "SELECT * FROM $table"

    try {
        Invoke-Sqlcmd `
            -ServerInstance $azureServer `
            -Database $azureDatabase `
            -Username $azureUser `
            -Password $azurePassword `
            -Query $query |
            Export-Csv -Path (Join-Path $azureOutput ("$($table.Replace('.', '_')).csv")) -NoTypeInformation

        Write-Host "✓ $table exported successfully from Azure."
    }
    catch {
        Write-Warning "Failed to export $table from Azure: $_"
    }
}

# ============================
# EXPORT FROM LOCAL SQL SERVER
# ============================

Write-Host "`n=== Exporting from Local SQL Server ===`n"

foreach ($table in $tables) {
    Write-Host "Exporting $table from local SQL..."

    $query = "SELECT * FROM $table"

    try {
        Invoke-Sqlcmd `
            -ServerInstance $localServer `
            -Database $localDatabase `
            -Query $query `
            -TrustServerCertificate `
        | Export-Csv -Path (Join-Path $localOutput ("$($table.Replace('.', '_')).csv")) -NoTypeInformation

        Write-Host "✓ $table exported successfully from local SQL."
    }
    catch {
        Write-Warning "Failed to export $table from local SQL: $_"
    }
}