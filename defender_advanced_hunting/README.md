## Add permissions
1. Go to: Entra Portal -> App registrations -> Your application
2. Open: API permissions -> Add a permission
3. Choose: APIs my organization uses
4. Search for: Microsoft Threat Protection or Microsoft Defender XDR API
5. Select: Application permissions
6. Add:
- `AdvancedHunting.Read.All`
- `Machine.Read.All`
- `SecurityRecommendation.Read.All`

7. Click: Add permissions
8. Then click: Grant admin consent for <tenant>
## Authenticate
```powershell
$tenantId = $env:x_tenant
$clientId = $env:mg_x_root_01_id
$clientSecret = $env:mg_x_root_01_secret

$body = @{
    client_id     = $clientId
    client_secret = $clientSecret
    scope         = "https://api.security.microsoft.com/.default"
    grant_type    = "client_credentials"
}

$token = Invoke-RestMethod `
    -Method Post `
    -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
    -Body $body `
    -ContentType "application/x-www-form-urlencoded"

$accessToken = $token.access_token
```
## Run a query
```powershell
$query = @"
DeviceTvmSoftwareVulnerabilities
| where SoftwareName contains "sql_server_management_studio"
| summarize
    Versions = make_set(SoftwareVersion),
    CVEs = make_set(CveId),
    Severities = make_set(VulnerabilitySeverityLevel),
    VulnerabilityCount = dcount(CveId)
by DeviceName
| order by VulnerabilityCount desc
"@

$huntBody = @{
    Query = $query
} | ConvertTo-Json

$result = Invoke-RestMethod `
    -Method Post `
    -Uri "https://api.security.microsoft.com/api/advancedhunting/run" `
    -Headers @{
        Authorization = "Bearer $accessToken"
    } `
    -Body $huntBody `
    -ContentType "application/json"

$result.Results
```
