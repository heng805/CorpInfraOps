Function Get-MgDeviceRemediationsStatus {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Computername
    )

    # Requires the Microsoft Graph PowerShell SDK (Microsoft.Graph.*)
    # MS Graph required permissions (delegated)
    # DeviceManagementManagedDevices.Read.All
    # DeviceManagementConfiguration.Read.All

    Process 
    {
        foreach ($Computer in $Computername)
        {
            # Find managed device in Graph
            try 
            {
                $Device = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$Computer'" -ErrorAction Stop
            }
            catch 
            {
                Write-Error $_.Exception.Message
                continue
            }
            
            # Make sure only 1 result returned
            if ($null -eq $Device)
            {
                Write-Error "Device not found"
                continue
            }
            if ($Device.Count -gt 1)
            {
                Write-Error "Multiple devices found with the name '$Computer'. Device names must be unique."
                continue
            }

            # Get the remediations status
            try 
            {
                $result = Get-MgBetaDeviceManagementManagedDeviceHealthScriptState -ManagedDeviceId $Device.id -All -ErrorAction Stop
            }
            catch 
            {
                Write-Error $_.Exception.Message
                continue
            }
           
            # Select only the desired properties
            if ($result.Count -lt 1)
            {
                Write-Warning "No remediations status found for '$Computer'"
                continue
            }
            $result = $result | Select -Property * -Unique 
            $Properties = @("DeviceName","PolicyName","UserName","LastStateUpdateDateTime","DetectionState","RemediationState","PreRemediationDetectionScriptOutput","PreRemediationDetectionScriptError","RemediationScriptError","PostRemediationDetectionScriptOutput","PostRemediationDetectionScriptError")
            ($result | Select -Property $Properties | Sort PolicyName)
        }
    }
}

Get-MgDeviceRemediationsStatus -Computername ""