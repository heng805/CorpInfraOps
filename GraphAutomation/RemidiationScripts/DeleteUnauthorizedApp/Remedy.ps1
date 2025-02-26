write-output "Remedy script... uninstall software"


get-package -name "Nessus*"|Uninstall-package -force
