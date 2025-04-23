<#
.SYNOPSIS
Helper module to log events to Log Analytics

.NOTES
Would like the ability to specify Log Analytics env (prd or tst)

TODO Need an arg to specify _CL!!!
#>

#-- parameters provided by calling script --#
param (
    [string] $payload
)
#-- azure monitor variables --#
$dcrImmutableId = ""
$dceURI = "https://it-automation-prd-dce-4q77.westus-1.ingest.monitor.azure.com"
$logName = "IntuneDeviceDiscoveredApps_CL"

#-- local variables from KeyVault  (must be logged into azure from calling script) --#
$tenantId = Get-AzKeyVaultSecret -VaultName "IT-Automation-Key-Vault" -Name "Biora-Azure-TenantID" -AsPlainText
$appId = Get-AzKeyVaultSecret -VaultName "IT-Automation-Key-Vault" -Name "IT-Automation-ApplicationID" -AsPlainText
$appSecret = Get-AzKeyVaultSecret -VaultName "IT-Automation-Key-Vault" -Name "IT-Automation-Logger-App-Secret" -AsPlainText

#-- obtain a bearer token used to authenticate against the data collection endpoint --#
$scope = [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
$body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials"
$headers = @{"Content-Type" = "application/x-www-form-urlencoded" };
$uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token

#-- send the data to azure monitor via the DCR and return response --#
$contentType = "application/json"
$headers = @{"Authorization" = "Bearer $bearerToken"; "Content-Type" = "application/json" }
$uri = "$dceURI/dataCollectionRules/$dcrImmutableId/streams/Custom-$logName"+"?api-version=2023-01-01"
$response = Invoke-WebRequest -Uri $uri -Method "Post" -ContentType $contentType -Headers $headers -Body $payload -UseBasicParsing -Verbose
Write-Host $response.RawContent

return $response.StatusCode