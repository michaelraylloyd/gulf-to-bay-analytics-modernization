param(
    [Parameter(Mandatory = $true)]
    [string] $TenantId,
    [Parameter(Mandatory = $true)]
    [string] $ClientId,
    [Parameter(Mandatory = $true)]
    [string] $ClientSecret,
    [Parameter(Mandatory = $true)]
    [string] $WorkspaceId,
    [Parameter(Mandatory = $true)]
    [string] $PbixPath,
    [Parameter(Mandatory = $true)]
    [string] $LakehouseWorkspaceId,
    [Parameter(Mandatory = $true)]
    [string] $LakehouseId
)

# -------------------------------------------------------------------
# 1. Get AAD token for Power BI REST API
# -------------------------------------------------------------------

$body = @{
    grant_type    = "client_credentials"
    client_id     = $ClientId
    client_secret = $ClientSecret
    scope         = "https://analysis.windows.net/powerbi/api/.default"
}

$tokenResponse = Invoke-RestMethod -Method Post -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Body $body
$accessToken   = $tokenResponse.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
}

# -------------------------------------------------------------------
# 2. Import PBIX as a semantic model into the workspace
# -------------------------------------------------------------------

Write-Host "Importing PBIX into workspace $WorkspaceId..."

$importUri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/imports?datasetDisplayName=SalesAnalyticsModel&nameConflict=CreateOrOverwrite"

$importResponse = Invoke-RestMethod -Method Post -Uri $importUri -Headers $headers -InFile $PbixPath -ContentType "multipart/form-data"

$datasetId = $importResponse.datasets[0].id
Write-Host "Imported dataset id: $datasetId"

# -------------------------------------------------------------------
# 3. Rebind dataset to Lakehouse (update datasource)
# -------------------------------------------------------------------

Write-Host "Updating dataset datasource to Lakehouse..."

$updateDatasourceUri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/datasets/$datasetId/Default.UpdateDatasources"

$bodyUpdate = @{
    updateDetails = @(
        @{
            datasourceSelector = @{
                datasourceType    = "Lakehouse"
                connectionDetails = @{
                    workspaceId = $LakehouseWorkspaceId
                    lakehouseId = $LakehouseId
                }
            }
            connectionDetails = @{
                workspaceId = $LakehouseWorkspaceId
                lakehouseId = $LakehouseId
            }
        }
    )
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Method Post -Uri $updateDatasourceUri -Headers $headers -Body $bodyUpdate -ContentType "application/json"

Write-Host "Datasource updated."

# -------------------------------------------------------------------
# 4. Trigger dataset refresh
# -------------------------------------------------------------------

Write-Host "Triggering dataset refresh..."

$refreshUri = "https://api.powerbi.com/v1.0/myorg/groups/$WorkspaceId/datasets/$datasetId/refreshes"

Invoke-RestMethod -Method Post -Uri $refreshUri -Headers $headers -Body (@{} | ConvertTo-Json) -ContentType "application/json"

Write-Host "Refresh triggered."