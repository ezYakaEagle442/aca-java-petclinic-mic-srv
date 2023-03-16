// Check the REST API : https://docs.microsoft.com/en-us/rest/api/containerapps/
@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

param location string = resourceGroup().location

@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string = 'kv-${appName}'

@description('The name of the KV RG')
param kvRGName string

@description('The VNet rules to whitelist for the KV')
param vNetRules array = []

@description('The MySQL DB Admin Login.')
param administratorLogin string = 'mys_adm'

@description('The MySQL DB Server name.')
param dbServerName string = appName


// https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-deploy-on-azure-free-account
@description('Azure database for MySQL SKU')
@allowed([
  'Standard_D4s_v3'
  'Standard_D2s_v3'
  'Standard_B1ms'
])
param databaseSkuName string = 'Standard_B1ms' //  'GP_Gen5_2' for single server

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param databaseSkuTier string = 'Burstable'

@description('PostgreSQL version see https://learn.microsoft.com/en-us/azure/mysql/concepts-version-policy')
@allowed([
  '8.0.21'
  '8.0.28'
  '5.7'
])
param mySqlVersion string = '5.7' // https://docs.microsoft.com/en-us/azure/mysql/concepts-supported-versions

@description('The MySQL DB name.')
param dbName string = 'petclinic'

param charset string = 'utf8'

@allowed( [
  'utf8_general_ci'

])
param collation string = 'utf8_general_ci' // SELECT @@character_set_database, @@collation_database;

resource kvRG 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: kvRGName
  scope: subscription()
}

// see https://github.com/microsoft/azure-container-apps/issues/469
// Now KV must Allow azureContainerAppsOutboundPubIP in the IP rules ...
// Must allow ACA to access Existing KV


resource HelloTestApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: 'hello-test'
}

module kvsetiprules './modules/kv/kv.bicep' = {
  name: 'kv-set-iprules'
  scope: kvRG
  params: {
    appName: appName
    kvName: kvName
    location: location
    ipRules: HelloTestApp.properties.outboundIPAddresses
    vNetRules: vNetRules
  }
}

output keyVault object = kvsetiprules.outputs.keyVault
output keyVaultId string = kvsetiprules.outputs.keyVaultId
output keyVaultName string = kvsetiprules.outputs.keyVaultName
output keyVaultURI string = kvsetiprules.outputs.keyVaultURI
output keyVaultPublicNetworkAccess string = kvsetiprules.outputs.keyVaultPublicNetworkAccess
output keyVaultPublicNetworkAclsPpRules array = kvsetiprules.outputs.keyVaultPublicNetworkAclsPpRules

resource kv 'Microsoft.KeyVault/vaults@2022-11-01' existing = {
  name: kvName
  scope: kvRG
}  

module mysqlPub './modules/mysql/mysql.bicep' = {
  name: 'mysqldbpub'
  params: {
    appName: appName
    location: location
    serverName: dbServerName
    dbName: dbName
    mySqlVersion: mySqlVersion
    databaseSkuName: databaseSkuName
    databaseSkuTier: databaseSkuTier
    charset: charset
    collation: collation
    administratorLogin: administratorLogin
    administratorLoginPassword: kv.getSecret('SPRING-DATASOURCE-PASSWORD')
    azureContainerAppsOutboundPubIP: HelloTestApp.properties.outboundIpAddresses
  }
}

output mySQLResourceID string = mysqlPub.outputs.mySQLResourceID
output mySQLServerName string = mysqlPub.outputs.mySQLServerName
output mySQLServerFQDN string = mysqlPub.outputs.mySQLServerFQDN
output mySQLServerAdminLogin string = mysqlPub.outputs.mySQLServerAdminLogin

output mysqlDBResourceId string = mysqlPub.outputs.mysqlDBResourceId
output mysqlDBName string = mysqlPub.outputs.mysqlDBName
