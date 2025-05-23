#credits: Mostly to tobibeer and Snak3d0c @ https://stackoverflow.com/questions/47345612/export-chrome-bookmarks-to-csv-file-using-powershell

#Path to chrome bookmarks
$pathToJsonFile = "$env:localappdata\Google\Chrome\User Data\Default\Bookmarks"

# build path
$str = [System.Environment]::GetFolderPath('MyDocuments')
# create new dir, if not yet exists, then move exported html file into that backup dir
$destinationPath = $str + "\ChromeBookmarksBackup"
if (Test-Path $destinationPath) 
{
    Write-Host "folder backup exists, moving on"    
} 
else
{
    Write-Host "creating final destination folder..."
    mkdir $destinationPath
}
$finalPath = $destinationPath + "\ChromeBookmarks.html"
$htmlOut = $finalPath

$htmlHeader = @'
<!DOCTYPE NETSCAPE-Bookmark-file-1>
<!--This is an automatically generated file.
    It will be read and overwritten.
    Do Not Edit! -->
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
<Title>Bookmarks</Title>
<H1>Bookmarks</H1>
<DL><p>
'@

$htmlHeader | Out-File -FilePath $htmlOut -Force -Encoding utf8 #line59

#A nested function to enumerate bookmark folders
Function Get-BookmarkFolder {
    [cmdletbinding()]
    Param(
        [Parameter(Position=0,ValueFromPipeline=$True)]
        $Node
    )
    Process 
    {
        foreach ($child in $node.children) 
        {
            $da = [math]::Round([double]$child.date_added / 1000000) #date_added - from microseconds (Google Chrome {dates}) to seconds 'standard' epoch.
            $dm = [math]::Round([double]$child.date_modified / 1000000) #date_modified - from microseconds (Google Chrome {dates}) to seconds 'standard' epoch.
            if ($child.type -eq 'Folder') 
            {
                "    <DT><H3 FOLDED ADD_DATE=`"$($da)`">$($child.name)</H3>" | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
                "       <DL><p>" | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
                Get-BookmarkFolder $child
                "       </DL><p>" | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
            }
            else 
            {
                "       <DT><a href=`"$($child.url)`" ADD_DATE=`"$($da)`">$($child.name)</a>" | Out-File -FilePath $htmlOut -Append -Encoding utf8
            } #else url
        } #foreach
    } #process
} #end function

$data = Get-content $pathToJsonFile -Encoding UTF8 | out-string | ConvertFrom-Json
$sections = $data.roots.PSObject.Properties | select -ExpandProperty name
ForEach ($entry in $sections) {
    $data.roots.$entry | Get-BookmarkFolder
}

# saves directly to users's onedrive for data durability
'</DL>' | Out-File -FilePath $htmlOut -Append -Force -Encoding utf8
