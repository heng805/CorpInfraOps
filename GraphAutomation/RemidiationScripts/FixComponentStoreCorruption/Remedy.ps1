
try {
    Dism.exe /Online /Cleanup-Image /Restorehealth
    Sfc.exe /Scannow
} catch {
    throw "Issue with remedy commands"
}