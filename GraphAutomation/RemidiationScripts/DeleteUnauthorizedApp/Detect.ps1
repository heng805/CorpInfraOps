<#
    Goal: able to use windows package manager to run queries on unauth software

    Long Term: Make it account for any unauth apps, instead of manual input

    TODO: make it verify output from get-package cmdlet, if that fails then resort to 
          using start-process cmdlet to uninstall via that mechanism 
#>
# app search term of interest
$query = "Nessus*"

$packages = get-package -name $query
$out2 = Get-ChildItem "C:\Program Files (x86)\Nessus*"

if ($null -ne $packages)
{
    Write-Output $out2
    exit 1
}
else 
{
    write-output "Nothing here, exiting script"
    exit 0
}

