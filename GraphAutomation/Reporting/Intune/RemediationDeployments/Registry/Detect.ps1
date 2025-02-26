<#
.SYNOPSIS 
Validates existance (or not if specified) that a particular registry path value(s)
#>

Write-Host "| Validating Device Lock timeout set to 15 mintues...."
try {
    $result = get-itemProperty Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\Current\device\devicelock\
}
catch {
    Write-Host "| Path does not exist!"
    return 1
}


if ($result.MaxInactivityTimeDeviceLock -ne 15) {
    $actual = $result.MaxInactivityTimeDeviceLock
    Write-Host "| Device screen timeout not set! actual value is: " $actual
    return 1
}
else {
    Write-Host "| OK, Config is present: " $result.MaxInactivityTimeDeviceLock
    return 0
}