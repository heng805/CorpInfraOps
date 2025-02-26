# Detection Script for Intune script remediaton

# check for chrome bookmarks exported html file, else return exit 1 to trigger detection rule
$userPath = [System.Environment]::GetFolderPath('MyDocuments')
$fullGenericUserPath = $userPath + "\ChromeBookmarksBackup\ChromeBookmarks.html" 

if ([System.IO.File]::Exists($fullGenericUserPath)) {
    # TODO implement logic to detect new changes to bookmarks file, need to somehow
    # for new changes in bookmarks bar
    Write-Host "chrome bookmark html file exists"
    exit 0
}
else {
    write-host "Exported bookmarks dont exist!"
    exit 1
}

