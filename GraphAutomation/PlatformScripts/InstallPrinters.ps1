# Install Sharp Universal Printer Driver for Carroll Canyon South Printer
#
# Powershell.exe -ExecutionPolicy ByPass -File .\full-script-path\script.ps1

#detection Rule
# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers\Carroll Canyon South-Sharp MX-4141N PCL6"


$PrinterDriver = "SHARP MX-4141N PCL6"
$PrinterName = "Carroll Canyon South-Sharp MX-4141N PCL6"
$PrinterPort = "IP_10.5.0.85"

write-host "running pnputil..."
# Staging Driver
pnputil.exe /add-driver "C:\CC_South_Printer\Sharp_MX-4141N_PCL6\64bit\ss0emenu.inf"

Write-Host "Installing driver via IP..."
#Installing Driver
add-PrinterDriver -Name $PrinterDriver

#check if printer port exits, if not, install printer ports
$checkPortExists = Get-Printerport -Name $PrinterPort -ErrorAction SilentlyContinue
if (-not $checkPortExists) 
{
Add-PrinterPort -name $PrinterPort -PrinterHostAddress 10.5.0.85
}

#check if printer driver exists
$printDriverExists = Get-PrinterDriver -name $PrinterDriver -ErrorAction SilentlyContinue

#Install printer Driver
if ($printDriverExists)
{
Add-printer -Name $PrinterName -DriverName $PrinterDriver -port $PrinterPort
Write-Host "Printer Driver installed Sucessfully"
}
else
{
Write-Warning "Printer Driver not installed"
}

