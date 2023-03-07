@description('A UNIQUE name')
@maxLength(23)
param appName string = 'petcliaca${uniqueString(resourceGroup().id, subscription().id)}'

@description('The location of the MySQL DB.')
param location string = resourceGroup().location

@description('The MySQL DB Admin Login.')
param administratorLogin string = 'mys_adm'

@secure()
@description('The MySQL DB Admin Password.')
param administratorLoginPassword string

@description('The MySQL DB Server name.')
param serverName string = appName

@description('The MySQL DB name.')
param dbName string = 'petclinic'

@description('Azure Container Apps Outbound Public IP as an Array')
param azureContainerAppsOutboundPubIP array

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
  '8.0'
  '5.7'
])
param mySqlVersion string = '5.7' // https://docs.microsoft.com/en-us/azure/mysql/concepts-supported-versions

param charset string = 'utf8'

@allowed( [
  'utf8_general_ci'

])
param collation string = 'utf8_general_ci' // SELECT @@character_set_database, @@collation_database;

resource mysqlserver 'Microsoft.DBforMySQL/flexibleServers@2021-12-01-preview' = {
  name: serverName
  location: location
  sku: {
    name: databaseSkuName
    tier: databaseSkuTier
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    // availabilityZone: '1'
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Disabled'
    }
    createMode: 'Default'
    highAvailability: {
      mode: 'Disabled'
    }
    replicationRole: 'None'
    version: mySqlVersion
  }
}

output mySQLResourceID string = mysqlserver.id
output mySQLServerName string = mysqlserver.name
output mySQLServerFQDN string = mysqlserver.properties.fullyQualifiedDomainName
output mySQLServerAdminLogin string = mysqlserver.properties.administratorLogin

resource mysqlDB 'Microsoft.DBforMySQL/flexibleServers/databases@2021-12-01-preview' = {
  name: dbName
  parent: mysqlserver
  properties: {
    charset: charset
    collation: collation
  }
}

output mysqlDBResourceId string = mysqlDB.id
output mysqlDBName string = mysqlDB.name

 // Allow Azure Container Apps
 resource fwRuleAllowAzureContainerApps 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-12-01-preview' = {
  name: 'Allow-Azure-Container-Apps-OutboundPubIP'
  parent: mysqlserver
  properties: {
    startIpAddress: azureContainerAppsOutboundPubIP[0]
    endIpAddress: azureContainerAppsOutboundPubIP[0]
  }
}

 // /!\ SECURITY Risk: Allow ANY HOST for local Dev/Test only
 /*
 // Allow public access from any Azure service within Azure to this server
 // This option configures the firewall to allow connections from IP addresses allocated to any Azure service or asset,
 // including connections from the subscriptions of other customers.
 resource fwRuleAllowAnyHost 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-05-01' = {
  name: 'Allow Any Host'
  parent: mysqlserver
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '0.0.0.0'
  }
}

 resource fwRuleAllowAnyHost 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-05-01' = {
  name: 'Allow Any Host'
  parent: mysqlserver
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}
*/
