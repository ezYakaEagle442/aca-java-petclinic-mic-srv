// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(23)
param appName string = 'petcliaca${uniqueString(resourceGroup().id, subscription().id)}'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-${appName}-admin-server'

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-${appName}-config-server'

// should be useless as we rely on tha ACA/AKS/K8S native discovery services
@description('The Azure Container App instance name for discovery-server')
param discoveryServerContainerAppName string = 'aca-${appName}-discovery-server'

@description('The Azure Container App instance name for api-gateway')
param apiGatewayContainerAppName string = 'aca-${appName}-api-gateway'

@description('The Azure Container App instance name for customers-service')
param customersServiceContainerAppName string = 'aca-${appName}-customers-service'

@description('The Azure Container App instance name for vets-service')
param vetsServiceContainerAppName string = 'aca-${appName}-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppName string = 'aca-${appName}-visits-service'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: azureContainerAppEnvName
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep
resource AdminServerContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: adminServerContainerAppName
}

resource ApiGatewayContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: apiGatewayContainerAppName
}

resource ConfigServerContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: configServerContainerAppName
}

resource CustomersServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: customersServiceContainerAppName
}

resource VetsServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: vetsServiceContainerAppName
}

resource VisitsServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: visitsServiceContainerAppName
}

resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

/*
ACA does not yet support diagnostic settings
container apps do no support currently diagnostic settings. Integration happen trough property on the app environment resource currently.
https://github.com/microsoft/azure-container-apps/issues/382
https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
*/


resource appInsDgsAdminServer 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${adminServerContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: AdminServerContainerApp
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

resource appInsDgsApiGW 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${apiGatewayContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: ApiGatewayContainerApp
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

resource appInsDgsCfgServer 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${configServerContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: ConfigServerContainerApp
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


resource appInsDgsCustomersService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${customersServiceContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: CustomersServiceContainerApp
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

resource appInsDgsVetsService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${vetsServiceContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: VetsServiceContainerApp
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

resource appInsDgsVisistsService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${visitsServiceContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: VisitsServiceContainerApp
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
