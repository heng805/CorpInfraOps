<#
.SYNOPSIS Script that runs locally on a Biora pc, copies all contents of folder into a sharepoint site.
.NOTES For now, will use interactive login with henry.guerra.admin account until cert auth is fully tested 
       and implemented. 
       To register the app in the Biora tenant, the following line was used: 
       Register-PnPAzureADApp -ApplicationName "Copy Local Device Resources to Sharepoint" -Tenant bioratherapeutics.onmicrosoft.com -DeviceLogin -OutPath .
TODO Need to eventually make this more generic in terms of the site and relative paths
TODO There is a new spectrometer that will also need to upload to CMCDev SP site
#>

#Import-Module AzureAD
#Import-Module PnP.PowerShell

start-transcript -path "C:\Temp_Folder\PSDebuggingLogs\copy-tospsite.txt" -noclobber

# Auth to Azure Automation via self signed cert
$PNP_APP_ID     = 'c3195b48-3361-46c9-9bcf-bcb11676cbd5'
$SP_TENANT_URL  = 'bioratherapeutics.onmicrosoft.com'
$spRootURL      = 'bioratherapeuticsinc.sharepoint.com/sites/BioraCMCDevelopment'
$certThumb      = '7FA6B1E3D2539189B07EB6C47176BF7FC1C8520C'

try 
{
       Connect-PnPOnline -ClientId $PNP_APP_ID -Tenant $SP_TENANT_URL -thumbprint $certThumb -Url $spRootURL
} 
catch
{
       stop-transcript
       throw $_.Exception.Message
}

# Get working path of SP folder
$rootPath = "Shared Documents/FTIR Results/"

# Get local path of results data dump, static path
$localReportsPath = "C:\Users\Public\Documents\Agilent\MicroLab\Results"
$localFTIRResults = ""
if (Test-Path $localReportsPath) 
{
       $localFTIRResults = $localReportsPath
} 
else 
{
       throw "Required path for generated reports does not exist, exiting script..."
}

# Must use this function to upload folders AND files to SP site, not officially supported via PnP
# Source:https://michelkamp.wordpress.com/2021/04/20/upload-complete-directory-with-files-recursively-to-teams-sharepoint/ 

# The root directory of the files to upload
$sourcePath = $localFTIRResults

# The destination document library path
$destionationPath = $rootPath + "$(Get-date -Format 'D') " + "Snapshot"

# get all files with full path as string array so the will be sorted automatically
$filesToUpload= Get-ChildItem -Recurse -Path $sourcePath -File -Name

# upload each file.
# No need to create a directory folder first with Add-PnPFolder and adding recursively code the PnP-File will handle this too !
foreach ($file in $filesToUpload )
{
       # get path name
       $parentDir = Split-Path $file

       # get file name
       $destFile = Split-Path $file -Leaf

       # upload the file
       Add-PnPFile -Path "$sourcePath\$file" -NewFileName $destFile -Folder "$destionationPath/$parentDir"
}

stop-transcript