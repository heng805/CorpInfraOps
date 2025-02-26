<#
.SYNOPSIS
Uses mggraph beta to get current set of all non compliant Biora devices along with their 
compliance error status description. Creates Sentinel incident (Medium status) to trigger ticket creation
in Service Desk. 

.EXAMPLE
.\Get-DeviceCompliance 

.NOTES 
Assumes mggraph is already in active context for now... 

.OUTPUTS
Set of devices in non compliance along with their error descriptions
#>

class FinalReport {
    [System.Object] $device

    # properties to pull out from $complianceDetails
    [string] $nonComplianceReason

    FinalReport(
        [System.Object] $device,
        [string] $nonComplianceReason
    ) {
        $this.device              = $device
        $this.nonComplianceReason = $nonComplianceReason
    }

    [PSCustomObject] formatData() {
        $formattedData = [PSCustomObject]@{
            Device              = $this.device
            NonComplianceReason = $this.nonComplianceReason
        }
        return $formattedData
    }
}

 # Get set of current non compliant devices, add into array
$devices = Get-MgDeviceManagementManagedDevice -filter "complianceState eq 'noncompliant'" `
                | Select-Object UserDisplayName `
                , DeviceName `
                , LastSyncDateTime `
                , Id

 # iterate through list, getting device id
 $finalDevices = @()
foreach($device in $devices) {

    $deviceComplianceDetailsUri = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$($device.Id)/getNonCompliantSettings"

    $complianceDetails = (Invoke-MgGraphRequest -Method GET $deviceComplianceDetailsUri| Select-Object -ExpandProperty Value)

    $finalDevice = [FinalReport]::new($device, $complianceDetails.setting)
    $finalData = $finalDevice.formatData()

    $finalDevices += $finalData
}
$sentinelFinalDataBatch = $finalDevices|Out-String
# Create new incident in Sentinel, IFF finalDevices[] has at least one element
$rg = "rg-sentinel-westus-prd-001"
$workspace = "sentinel-westus-prd-001"
$incidentName = "Intune Device Noncompliance via PS Script"
$incidentSeverity = "Medium"
$status = "New"


New-AzSentinelIncident -ResourceGroupName $rg -WorkspaceName $workspace -Title $incidentName -Severity $incidentSeverity -Status $status -Description $sentinelFinalDataBatch