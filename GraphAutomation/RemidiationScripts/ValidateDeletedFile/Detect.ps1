#scans users Downloads folder for pdf malware related files

$exeList = Get-ChildItem "$env:USERPROFILE\Downloads" -Include '*.exe' -Recurse
if ($exeList.Name -like '*pdf*') 
{
    $result = $exeList.Name -like '*pdf*'
    Write-Host "PASSED WITH RESULT -> " $result
    
    # consider this an "issue" so return with error for remediation script to trigger
    return 1
}
else 
{
    write-host "pdf malware file not found"
    return 0
}

