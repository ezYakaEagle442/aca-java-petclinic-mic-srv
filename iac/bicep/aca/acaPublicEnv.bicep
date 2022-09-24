
@maxLength(20)
// to get a unique name each time ==> param appName string = 'demo${uniqueString(resourceGroup().id, deployment().name)}'
param appName string = 'petcliaca${uniqueString(resourceGroup().id)}'
param location string = 'westeurope'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

param appInsightsName string = 'appi-${appName}'

param zoneRedundant bool = false

@allowed([
  'log-analytics'
])
param logDestination string = 'log-analytics'

resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing =  {
  name: logAnalyticsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: azureContainerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: logDestination
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
    zoneRedundant: zoneRedundant
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
  }
}

output corpManagedEnvironmentId string = corpManagedEnvironment.id 
output corpManagedEnvironmentDefaultDomain string = corpManagedEnvironment.properties.defaultDomain
output corpManagedEnvironmentStaticIp string = corpManagedEnvironment.properties.staticIp
