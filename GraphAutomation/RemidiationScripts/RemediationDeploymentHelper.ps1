<#
Goal: Want to use this script as the jumping off point to improve and tighten the dev process
    for intune remediation scripting. 
    Unfortunately the MGGraph sdk doesn't natively support invoking a remediation script. 
    - Must implement the HTTP request ourselves and write it in a generic manner for future use
        with other scripts
Assumptions:
    - Microsoft.Graph PS module is installed, loaded, and authenticated with appropriate admin account
        - With scopes: 
            DeviceManagementManagedDevices.Read.All 
            DeviceManagementConfiguration.Read.All
            DeviceManagementManagedDevices.PrivilegedOperations.All
Remarks:
    - Needs to still use the Api BETA for any remediation actions
        - Module -> Microsoft.Graph.Beta.DeviceManagement
#>

class myHTTPRequest 
{
    [string] $devDeviceID
    [string] $RemediationID
    [string] $apiURL

    myHTTPRequest(
        [string] $devDeviceID,
        [string] $RemediationID
    )
    {
        $this.devDeviceID   = $devDeviceID
        $this.RemediationID = $RemediationID
        $this.apiURL        = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$devDeviceID/initiateOnDemandProactiveRemediation"

    }

   [system.object] invokeRemediationPOST()
   {
        $body = @{
            "scriptPolicyId" = $this.RemediationID
        } | ConvertTo-Json
        try 
        {
           $res  = Invoke-MgGraphRequest `
                        -Uri $this.apiURL `
                        -Method POST `
                        -Body $body `
                        -ErrorAction Stop `
                        -Verbose `
                        -Debug
        }
        catch 
        {
           $res = $_.Exception.Message 
        }
        return $res
   }
}

# kick off script with class initialization
$MGGraphPOST = [myHTTPRequest]::new(
    "deb34c74-a799-4329-8f87-9bce4b975e24",
    "69722ebc-b641-4af1-8096-094954e55ad6"
)
$MGGraphPOST.invokeRemediationPOST()


# May need to use this cmdlet at some point? Helps as a good starting place. 
<#
Get-MGDeviceManagementManagedDevice `
    |where UserPrincipalName -eq "henry.guerra@bioratherapeutics.com" `
    |where SerialNumber -eq "9YYHST3" `
    |select *

#>

