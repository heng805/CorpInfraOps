# .SYNOPSIS checks validity of installed path for general purposes

function checkTeamViewer {
    
    $path = "C:\Program Files\TeamViewer\x64"

    $result = Get-ChildItem $path

    if ($null -ne $result) {
        Write-Host "path exists"
        exit 0
    } else {
        write-host "Nothing there"   
        # check one level above x64 if the root folder even still exists?
        Get-ChildItem "C:\Program Files (x86)\TeamViewer"

        exit 1
    }
}

Get-ChildItem "C:\Program Files (x86)"