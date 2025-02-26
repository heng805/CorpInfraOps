#-- parameters provided by calling script --#
param (
    [String] $scriptName,
    [String] $scriptID,
    [String] $activity
)
Write-Host "IN LOG EVENT BUILDER"
#-- set log event dynamic properties based on calling script name --#
switch ($activity)
{
    "ScriptStarted" {
        $auditScope = "NA"
        $message = "Subject script has started"
        $dynamicProperties = @"
        {
            "Description": "$description"
        }
"@}
    "ScriptCompleted"{
        $auditScope = "NA"
        $message = "Subject script has completed"
        $dynamicProperties = @"
        {
            "Description": "$description"
        }
"@}
}

#-- build the log event --#
$logEvent = @"
    [{  "ScriptName": "$scriptName",
        "AuditScope": "$auditScope",
        "ScriptID": "$scriptID",
        "Platform": "Azure Automation",
        "Frequency": "$frequency",
        "Activity": "$activity",
        "Message": "$message",
        "DynamicProperties": $dynamicProperties
    }]
"@

return $logEvent
