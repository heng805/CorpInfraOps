// NOTE: Eventually will be basis for finish post deployment config in prod

@description('Specify name of workspace')
param sentinelName string

@description('specify location of workspace')
param location string = resourceGroup().location

@allowed([
  'dev'
  'tst'
  'prd'
])
param env string = 'prd'

// We only use the standard pay-as-you-go model for now
param sku string = 'standard'

param envID int = 0 + 1

@minValue(30)
param retentionDays int = 90

var workspaceName = '${sentinelName}-${location}-${env}-${envID}'
var solutionName = 'SecurityInsights(${sentinelWorkspace.name})'

// Define resources
resource sentinelWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: sentinelName
  location: location
  properties: {
    sku: {
      name: 'Standard'
    }
    retentionInDays: retentionDays
  }
}
resource sentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: solutionName
  location:location
  properties: {
    workspaceResourceId:sentinelWorkspace.id
  }
  plan:{
    name: solutionName
    publisher: 'Microsoft'
    product: 'OMSGallery/SecurityInsights'
    promotionCode: ''
  }
}
