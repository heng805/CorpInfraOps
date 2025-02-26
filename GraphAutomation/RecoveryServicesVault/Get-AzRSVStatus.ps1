# general health overview of devices with MARS agent deployed
# mostly deals with devices in CMC / R&D labs that need data protected
$vault = Get-AzRecoveryServicesVault -ResourceGroupName rg-lz-labmachines-westus-prd-001

# next, NEED to set RSV context (seems specific only to MARS agent deployments)
Set-AzRecoveryServicesVaultContext -Vault $vault.ID 

# sanity check right RSV is set, and get all items
$container = Get-AzRecoveryServicesBackupContainer -containerType Windows -BackupManagementType MAB

# get current status of most recent backups
# Note, despite the on-prem devices being physical laptops, the workload type STILL needs to be "AzureVM"
# Can only handle one element of the Container object array at a time, hence the array position in the param
$backupItems = Get-AzRecoveryServicesBackupItem -container $container[0] -WorkloadType AzureVM -VaultId $vault.ID

