
// global defs
param workspaceName string
param rule object


// get workspace
resource sentinelWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
	name: workspaceName
}

// deploy rules
resource analyticRuleDeployment 'Microsoft.SecurityInsights/alertRules@2022-10-01' existing = {
	name: rule.name
	scope: sentinelWorkspace
	kind: rule.kind
	properties: rule.properties
}