// Check the REST API : https://docs.microsoft.com/en-us/rest/api/containerapps/

@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

param location string = resourceGroup().location
param acrName string = 'acr${appName}'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('The Custom DNS suffix used for all apps in this environment')
param dnsSuffix string = 'petclinic'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

@allowed([
  'log-analytics'
])
param logDestination string = 'log-analytics'

param appInsightsName string = 'appi-${appName}'

@description('Should the service be deployed to a Corporate VNet ?')
param deployToVNet bool = false

@description('Resource ID of a subnet for infrastructure components. This subnet must be in the same VNET as the subnet defined in runtimeSubnetId. Must not overlap with any other provided IP ranges.')
param infrastructureSubnetName string = 'snet-infra' // used for the AKS nodes
param infrastructureSubnetCidr string = '10.42.2.0/23' // The CIDR prefix must be smaller than or equal to 23

@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault.')
param tenantId string = subscription().tenantId

@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string = 'kv-${appName}'

@description('The name of the KV RG')
param kvRGName string

@description('The VNet rules to whitelist for MySQL')
param vNetRules array = []

@description('The IP rules to whitelist for the MySQL')
param ipRules array = []

@description('The MySQL DB Admin Login.')
param administratorLogin string = 'mys_adm'

@description('The MySQL DB Server name.')
param mySQLDbServerName string = appName

@description('The MySQL DB name.')
param mySQLDbName string = 'petclinic'

param mySqlCharset string = 'utf8'

@allowed( [
  'utf8_general_ci'

])
param mySqlCollation string = 'utf8_general_ci' // SELECT @@character_set_database, @@collation_database;

// https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-deploy-on-azure-free-account
@description('Azure Database SKU')
@allowed([
  'Standard_D4s_v3'
  'Standard_D2s_v3'
  'Standard_B1ms'
])
param databaseSkuName string = 'Standard_B1ms' //  'GP_Gen5_2' for single server

@description('Azure Database pricing tier')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param databaseSkuTier string = 'Burstable'

@description('MySQL version see https://learn.microsoft.com/en-us/azure/mysql/concepts-version-policy')
@allowed([
  '8.0.21'
  '8.0.28'
  '5.7'
])
param mySqlVersion string = '5.7'

// https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?tabs=bicep
resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
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
output logAnalyticsWorkspaceName string = logAnalyticsWorkspace.name
output logAnalyticsWorkspaceCustomerId string = logAnalyticsWorkspace.properties.customerId

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/components?tabs=bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
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
output appInsightsName string = appInsights.name
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

module ACR './modules/aca/acr.bicep' = {
  name: acrName
  params: {
    appName: appName
    acrName: acrName
    location: location
    tenantId: tenantId
    networkRuleSetCidr: infrastructureSubnetCidr
  }
}

output acrId string = ACR.outputs.acrId
output acrName string = ACR.outputs.acrName
output acrIdentity string = ACR.outputs.acrIdentity
output acrType string = ACR.outputs.acrType
output acrRegistryUrl string = ACR.outputs.acrRegistryUrl

/*
ACA does not yet support diagnostic settings
container apps do no support currently diagnostic settings. Integration happen trough property on the app environment resource currently.
https://github.com/microsoft/azure-container-apps/issues/382
https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
*/
module defaultPublicManagedEnvironment './modules/aca/acaPublicEnv.bicep' = if (!deployToVNet) {
  name: 'aca-pub-env'
  params: {
    appName: appName
    location: location
    azureContainerAppEnvName: azureContainerAppEnvName
    appInsightsName: appInsightsName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    logDestination: logDestination
    dnsSuffix: dnsSuffix
  }
  dependsOn: [
    logAnalyticsWorkspace
    appInsights
  ]
}

output corpManagedEnvironmentId string = defaultPublicManagedEnvironment.outputs.corpManagedEnvironmentId
output corpManagedEnvironmentName string = defaultPublicManagedEnvironment.outputs.corpManagedEnvironmentName
output corpManagedEnvironmentDefaultDomain string = defaultPublicManagedEnvironment.outputs.corpManagedEnvironmentDefaultDomain
output corpManagedEnvironmentStaticIp string = defaultPublicManagedEnvironment.outputs.corpManagedEnvironmentStaticIp

resource kvRG 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: kvRGName
  scope: subscription()
}

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: kvName
  scope: kvRG
}  

module mysqlPub './modules/mysql/mysql.bicep' = {
  name: 'mysqldbpub'
  params: {
    appName: appName
    location: location
    serverName: mySQLDbServerName
    dbName: mySQLDbName
    mySqlVersion: mySqlVersion
    databaseSkuName: databaseSkuName
    databaseSkuTier: databaseSkuTier
    charset: mySqlCharset
    collation: mySqlCollation
    administratorLogin: administratorLogin
    administratorLoginPassword: kv.getSecret('SPRING-DATASOURCE-PASSWORD')
    azureContainerAppsOutboundPubIP: ipRules
  }
}

output mySQLResourceID string = mysqlPub.outputs.mySQLResourceID
output mySQLServerName string = mysqlPub.outputs.mySQLServerName
output mySQLServerFQDN string = mysqlPub.outputs.mySQLServerFQDN
output mySQLServerAdminLogin string = mysqlPub.outputs.mySQLServerAdminLogin

output mysqlDBResourceId string = mysqlPub.outputs.mysqlDBResourceId
output mysqlDBName string = mysqlPub.outputs.mysqlDBName

module identities './modules/aca/identity.bicep' = {
  name: 'aca-identities'
  params: {
    appName: appName
    location: location
  }
}

output adminServerIdentityId string = identities.outputs.adminServerIdentityId
output adminServerPrincipalId string = identities.outputs.adminServerPrincipalId
output adminServerClientId string = identities.outputs.adminServerClientId

output configServerIdentityId string = identities.outputs.configServerIdentityId
output configServerPrincipalId string = identities.outputs.configServerPrincipalId
output configServerClientId string = identities.outputs.configServerClientId

output apiGatewayIdentityId string = identities.outputs.apiGatewayIdentityId
output apiGatewayPrincipalId string = identities.outputs.apiGatewayPrincipalId
output apiGatewayClientId string = identities.outputs.apiGatewayClientId

output customersServiceIdentityId string = identities.outputs.customersServiceIdentityId
output customersServicePrincipalId string = identities.outputs.customersServicePrincipalId
output customersServiceClientId string = identities.outputs.customersServiceClientId

output vetsServiceIdentityId string = identities.outputs.vetsServiceIdentityId
output vetsServicePrincipalId string = identities.outputs.vetsServicePrincipalId
output vetsServiceClientId string = identities.outputs.vetsServiceClientId

output visitsServiceIdentityId string = identities.outputs.visitsServiceIdentityId
output visitsServicePrincipalId string = identities.outputs.visitsServicePrincipalId
output visitsServiceClientId string = identities.outputs.visitsServiceClientId

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
module roleAssignments './modules/aca/roleAssignments.bicep' = {
  name: 'role-assignments'
  params: {
    appName: appName
    acrName: acrName
    acrRoleType: 'AcrPull'
    acaCustomersServicePrincipalId: identities.outputs.customersServicePrincipalId
    acaVetsServicePrincipalId: identities.outputs.vetsServicePrincipalId
    acaVisitsServicePrincipalId: identities.outputs.visitsServicePrincipalId
    acaAdminServerPrincipalId: identities.outputs.adminServerPrincipalId
    acaApiGatewayPrincipalId: identities.outputs.apiGatewayPrincipalId
    acaConfigServerPrincipalId: identities.outputs.configServerPrincipalId
  }
}
