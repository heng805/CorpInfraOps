// Will be first attempt at deploying bicep template via Az DevOps build pipeline
// Ideally will be prefered process to create new resources, or change configurations on existing ones

@description('RG where Sentinel workspace resides')
param resourceGroupName string


@description('Log Analytics Workspace of associated Sentinel instance')
param workspacename string

var ootbRules = ''
var overwriteRules = ''

targetScope = 'subscription'


resource sentinelResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
	name: resourceGroupName
}

// deploy analytics rules
module deployOOTBRules 'deploy-rules.bicep' = {
	scope: sentinelResourceGroup
	name: 'deployOOTBRules'
	params: {
		workspaceName: workspacename
		rules: ootbRules
	}
}

// deploy overwrite rules