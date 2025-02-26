<#
Meant to be run in Defender Live Response session
Consolidates all relevant agent logs and zips them to be downloaded for offline analysis
#>

$PATH = 'C:\Program Files (x86)\ManageEngine\UEMS_Agent\bin\'
#$LOG_OUTPUT = 'C:\Program Files (x86)\ManageEngine\UEMS_Agent\'

if (Test-Path $PATH) {
    try {
        $exe = $PATH + "dcagenttrayicon.exe"
        #.\dcagenttrayicon.exe -logs
        Start-Process -FilePath $exe -ArgumentList "-logs"
    }
    catch {
        Write-Error "Can't initiate log compression"
    }
}

