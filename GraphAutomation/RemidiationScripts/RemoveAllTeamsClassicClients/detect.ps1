write-host "detecting..."

$output = Get-AppxProvisionedPackage -online|where DisplayName -Like "*Teams" 

new-item C:\Temp_Folder\REMEDIATIONTEST.txt

write-host $output|select *