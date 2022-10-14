
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
@description('Cluster configuration which enables the log daemon to export app logs to a destination. Currently only "log-analytics" is supported https://learn.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?pivots=deployment-language-bicep#managedenvironmentproperties')
param logDestination string = 'log-analytics'

resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing =  {
  name: logAnalyticsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

/*
ACA does not yet support diagnostic settings
container apps do no support currently diagnostic settings. Integration happen trough property on the app environment resource currently.
https://github.com/microsoft/azure-container-apps/issues/382
https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
*/
resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' = {
  name: azureContainerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: logDestination // azure-monitor
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

// https://github.com/microsoft/azure-container-apps/issues/382#issuecomment-1278623205
// https://github.com/cwe1ss/msa-template/blob/db6f134dddf78f682b2cebd681fe11ebfb68026e/infrastructure/environment/app-environment.bicep



resource appInsightsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${azureContainerAppEnvName}-logs-and-metrics-to-log-analytics'
  scope: corpManagedEnvironment
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}
