$path = "C:\Program Files\FileZilla FTP Client\uninstall.exe"
Start-Process -Wait -FilePath $path -Args "/S" -PassThru

