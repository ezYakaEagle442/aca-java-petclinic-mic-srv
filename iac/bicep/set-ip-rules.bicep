// Check the REST API : https://docs.microsoft.com/en-us/rest/api/containerapps/
@description('A UNIQUE name')
@maxLength(23)
param appName string = 'petcliaca${uniqueString(resourceGroup().id, subscription().id)}'

param location string = resourceGroup().location

@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string = 'kv-${appName}'

@description('The name of the KV RG')
param kvRGName string

@description('The VNet rules to whitelist for the KV')
param vNetRules array = []

@description('The IP rules to whitelist for the KV & MySQL')
param ipRules array

@description('The MySQL DB Admin Login.')
param administratorLogin string = 'mys_adm'

@description('The MySQL DB Server name.')
param dbServerName string = 'petcliaca'

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

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: kvName
  scope: kvRG
}  

module mysqlPub './modules/mysql/mysql.bicep' = {
  name: 'mysqldbpub'
  params: {
    appName: appName
    location: location
    serverName: dbServerName
    administratorLogin: administratorLogin
    administratorLoginPassword: kv.getSecret('SPRING-DATASOURCE-PASSWORD')
    azureContainerAppsOutboundPubIP: HelloTestApp.properties.outboundIPAddresses
  }
}
