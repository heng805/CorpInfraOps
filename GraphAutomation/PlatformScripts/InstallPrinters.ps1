# Install Sharp Universal Printer Driver for Carroll Canyon South Printer
#
# Powershell.exe -ExecutionPolicy ByPass -File .\full-script-path\script.ps1

#detection Rule
# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Print\Printers\Carroll Canyon South-Sharp MX-4141N PCL6"


$PrinterDriver = "SHARP MX-4141N PCL6"
$PrinterName = ""
$PrinterPort = "IP_{ip}"

write-host "running pnputil..."
# Staging Driver
pnputil.exe /add-driver ""

Write-Host "Installing driver via IP..."
#Installing Driver
add-PrinterDriver -Name $PrinterDriver

#check if printer port exits, if not, install printer ports
$checkPortExists = Get-Printerport -Name $PrinterPort -ErrorAction SilentlyContinue
if (-not $checkPortExists) 
{
Add-PrinterPort -name $PrinterPort -PrinterHostAddress # {IP}
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

