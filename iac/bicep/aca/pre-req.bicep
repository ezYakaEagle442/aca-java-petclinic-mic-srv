// Check the REST API : https://docs.microsoft.com/en-us/rest/api/containerapps/

@maxLength(20)
// to get a unique name each time ==> param appName string = 'demo${uniqueString(resourceGroup().id, deployment().name)}'
param appName string = 'petcliaca${uniqueString(resourceGroup().id)}'
param location string = 'westeurope'
param acrName string = 'acr${appName}'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

@allowed([
  'log-analytics'
])
param logDestination string = 'log-analytics'

param appInsightsName string = 'appi-${appName}'
param appInsightsDiagnosticSettingsName string = 'dgs-${appName}-send-logs-and-metrics-to-log-analytics'


param vnetName string = 'vnet-aca'
param vnetCidr string = '10.42.0.0/21' // /16 minimum ?
param dockerBridgeCidr string = '10.42.0.0/23' // /16 minimum ?

@description('Resource ID of a subnet for infrastructure components. This subnet must be in the same VNET as the subnet defined in runtimeSubnetId. Must not overlap with any other provided IP ranges.')
param infrastructureSubnetName string = 'snet-infra' // used for the AKS nodes
param infrastructureSubnetCidr string = '10.42.0.0/23' // The CIDR prefix must be smaller than or equal to 23
@description('Resource ID of a subnet that Container App containers are injected into. This subnet must be in the same VNET as the subnet defined in infrastructureSubnetId. Must not overlap with any other provided IP ranges.')
param runtimeSubnetCidr string = '10.42.0.0/23'
param runtimeSubnetName string = 'snet-run' // used to deploy the Apps to Pods

// /!\ The following properties must be set together, or not set at all (they will be set by the platform): 
// DockerBridgeCidr, PlatformReservedCidr, PlatformReservedDnsIP
@description('An IP address from the IP range defined by platformReservedCidr that will be reserved for the internal DNS server')
param platformReservedDnsIP string = '10.42.0.10' 

@description('The MySQL DB Admin Login.')
param administratorLogin string = 'mys_adm'

@secure()
@description('The MySQL DB Admin Password.')
param administratorLoginPassword string

@description('Allow client workstation to MySQL for local Dev/Test only')
param clientIPAddress string

@description('Allow Azure Container App subnet to access MySQL DB')
param startIpAddress string = '10.42.1.0'

@description('Allow Azure Container App subnet to access MySQL DB')
param endIpAddress string = '10.42.1.255'

param zoneRedundant bool = false

@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault.')
param tenantId string = subscription().tenantId

// https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#virtual-network-requirements
module vnetModule 'vnet.bicep' = {
  name: 'vnet-aca'
  // scope: resourceGroup(rg.name)
  params: {
     location: location
     vnetName: vnetName
     vnetCidr: vnetCidr
     infrastructureSubnetCidr: infrastructureSubnetCidr
     infrastructureSubnetName: infrastructureSubnetName
     runtimeSubnetCidr: runtimeSubnetCidr
     runtimeSubnetName: runtimeSubnetName
     platformReservedDnsIP: platformReservedDnsIP
  }   
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?tabs=bicep
resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
    }
  })
}
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceCustomerId string = logAnalyticsWorkspace.properties.customerId

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/components?tabs=bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
    //Flow_Type: 'Bluefield'    
    //ImmediatePurgeDataOn30Days: true // "ImmediatePurgeDataOn30Days cannot be set on current api-version"
    //RetentionInDays: 30
    IngestionMode: 'LogAnalytics' // Cannot set ApplicationInsightsWithDiagnosticSettings as IngestionMode on consolidated application 
    Request_Source: 'rest'
    SamplingPercentage: 20
    WorkspaceResourceId: logAnalyticsWorkspace.id    
  }
}
output appInsightsId string = appInsights.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsightsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: appInsightsDiagnosticSettingsName
  // scope: xxxContainerApp
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

module ACR 'acr.bicep' = {
  name: acrName
  params: {
    appName: appName
    acrName: acrName
    location: location
    tenantId: tenantId
    networkRuleSetCidr: runtimeSubnetCidr
  }
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
    vnetConfiguration: {
      // The Docker bridge network address represents the default docker0 bridge network address present in all Docker installations. While docker0 bridge is not used by AKS clusters or the pods themselves, you must set this address to continue to support scenarios such as docker build within the AKS cluster. It is required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that does not collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16. You can reuse this range across different AKS clusters.
      dockerBridgeCidr: dockerBridgeCidr
      infrastructureSubnetId: vnet.properties.subnets[0].id
      internal: true // set to true if the environnement is private, i.e vnet injected. Boolean indicating the environment only has an internal load balancer. These environments do not have a public static IP resource. They must provide runtimeSubnetId and infrastructureSubnetId if enabling this property
      platformReservedCidr: vnet.properties.subnets[0].properties.addressPrefix
      platformReservedDnsIP: vnet.properties.dhcpOptions.dnsServers[0]
      runtimeSubnetId: vnet.properties.subnets[1].id
    }
  }
}
output corpManagedEnvironmentId string = corpManagedEnvironment.id 
output corpManagedEnvironmentDefaultDomain string = corpManagedEnvironment.properties.defaultDomain
output corpManagedEnvironmentStaticIp string = corpManagedEnvironment.properties.staticIp

module mysql '../mysql/mysql.bicep' = {
  name: 'mysqldb'
  params: {
    appName: appName
    location: location
    clientIPAddress: clientIPAddress
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    azureContainerAppsOutboundPubIP: corpManagedEnvironment.properties.staticIp // CustomersServiceContainerApp.properties.outboundIPAddresses[0]
  }
}
