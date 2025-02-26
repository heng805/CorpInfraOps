<#
.SYNOPSIS
Gets inventory of ALL managed devices, queries all discovered apps. Then dumps logs into 
Log Analytics. 

.NOTES
Assumes that mggraph is already authenticated with admin account
TODO USE MANUAL API CALLS INSTEAD OF SDK
#>

# Run call to log analytics, send data over
# necessary variables for logging
$description = "Query all Intune device discovered apps."
$frequency = "Weekly"
$thisName = "Get-DeviceAppInventory"


# Connect to IT prd kv
$vaultName = "IT-Automation-Key-Vault"
$certThumb = Get-AzKeyVaultSecret -VaultName $vaultName -Name "IT-Automation-CertificateThumbPrint" -AsPlainText
$appId     = Get-AzKeyVaultSecret -VaultName $vaultName -Name "IT-Automation-ApplicationID" -AsPlainText
$tenantId  = Get-AzKeyVaultSecret -VaultName $vaultName -Name "Biora-azure-TenantID" -AsPlainText

# TODO uncomment this msgraph connection at DEPLOYMENT
#Connect-MgGraph -ClientId $appId -TenantId $tenantId -CertificateThumbprint $certThumb

# Log event builder funcitons
$GUID = New-Guid
$ScriptId = $GUID.ToString()

# TODO revert back to current dir for the helper scripts as done in prd Runbooks
<#
$scriptStarted = &"C:\Users\HenryGuerra\OneDrive - Biora Therapeutics, Inc\Documents\GithubRepos\BioraInfraOps\AzureAutomation\Shared\Azure-Monitor-Log-Event-Builder.ps1" $thisName $ScriptId "Script started"
$scriptStartedResponse = &"C:\Users\HenryGuerra\OneDrive - Biora Therapeutics, Inc\Documents\GithubRepos\BioraInfraOps\AzureAutomation\Shared\Azure-Monitor-Logger.ps1" $scriptStarted
Write-Output "$scriptStartedResponse | Script started"
#>

# Log analytics event builders
function Add-InstalledApps-Log-Event {
    param (
        [Parameter(Mandatory = $true)] [string] $bioraDevices
    )
    $dynamicProperties = @"
        {
            "DeviceApps": "$bioraDevices"
        }
"@   
    $discoveredAppsLogEvent = @"
        [{
            "ScriptName": "$thisName",
            "Activity": "DiscoveredAppsLogEvent",
            "AuditScope": "NA",
            "ScriptID": "$ScriptId",
            "Platform": "Azure Automation",
            "Frequency": "$frequency",
            "Message": "$description".
            "DynamicProperties": "[$dynamicProperties]"
        }]
"@
    Write-Host $discoveredAppsLogEvent
    $result = &"C:\Users\HenryGuerra\OneDrive - Biora Therapeutics, Inc\Documents\GithubRepos\BioraInfraOps\AzureAutomation\Shared\Azure-Monitor-Logger.ps1" $discoveredAppsLogEvent
    Write-Output "$result | Discovered Apps Events"
}

# Core script logic
class BioraDevice {
    [System.Object] $installedApps
    [System.Object] $managedDevice

    BioraDevice(
        [System.Object]   $installedApps,
        [System.Object]   $managedDevice
    ) {
        $this.installedApps = $installedApps
        $this.managedDevice = $managedDevice
    }

    [PSCustomObject] formatData() {
        $formattedData = [PSCustomObject]@{
            Device        = $this.managedDevice
            InstalledApps = $this.installedApps
        }
        return $formattedData
    }
}

# Get full dataset of discovered apps for ALL managed devices
$deviceSet = Get-MgBetaDeviceManagementManagedDevice `
                | select DeviceName, UserDisplayName, Id
                | select -first 5

$bioradevices = @()
foreach ($device in $deviceSet) {
    # assign detected apps into []installedApps 
    # TODO USE THE BELOW GET INSTEAD
    # https://graph.microsoft.com/beta/deviceManagement/manageddevices('9dd8137c-a799-4a50-b51c-461e7edbb874')/detectedApps?$top=100&$orderBy=displayName asc
    $detectedApps = Get-MgBetaDeviceManagementManagedDeviceDetectedApp `
                                    -ManagedDeviceId $device.Id
                                    | select DisplayName, Id
    $bioraDevice = [BioraDevice]::new($detectedApps, $device)
    $finalData = $bioraDevice.formatData()
    # Add full object to array of biora devices
    $bioradevices += $finalData
}

# Need to cast the powershell object into a json string 
$bioradevices = $bioradevices | ConvertTo-Json
$bioradevices

# pass full data set into log analytics helper to post data to _CL table
Add-InstalledApps-Log-Event $bioradevices

# Clean up, disconnect from modules