
@description('A UNIQUE name')
@maxLength(20)
param appName string = 'iacdemo${uniqueString(resourceGroup().id)}'

@description('The location of the MySQL DB.')
param location string = resourceGroup().location

@secure()
@description('The MySQL DB Admin Login.')
param administratorLogin string

@secure()
@description('The MySQL DB Admin Password.')
param administratorLoginPassword string

@secure()
@description('The MySQL DB Server name.')
param serverName string

@description('Azure Container Apps Outbound Public IP as an Array')
param azureContainerAppsOutboundPubIP array

@description('Should a MySQL Firewall be set to allow client workstation for local Dev/Test only')
param setFwRuleClient bool = false

@description('Allow client workstation IP adress for local Dev/Test only, requires setFwRuleClient=true')
param clientIPAddress string

@description('Allow Azure Container Apps from Apps subnet to access MySQL DB')
param startIpAddress string

@description('Allow Azure Container Apps from Apps subnet to access MySQL DB')
param endIpAddress string

var databaseSkuName = 'Standard_B1ms' //  'GP_Gen5_2' for single server
var databaseSkuTier = 'Burstable' // 'GeneralPurpose'
var mySqlVersion = '5.7' // https://docs.microsoft.com/en-us/azure/mysql/concepts-supported-versions

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

// Add firewall config to allow Azure Container Apps :
// virtualNetwork FirewallRules to Allow public access from Azure services 
/*
resource fwRuleAzureContainerApps 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-05-01' = {
  name: 'Allow-Azure-Container-AppsIpRange'
  parent: mysqlserver
  properties: {
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
  }
}
*/

// Allow client workstation with IP 'clientIPAddress' for local Dev/Test only
resource fwRuleClientIPAddress 'Microsoft.DBforMySQL/flexibleServers/firewallRules@2021-12-01-preview' = if (setFwRuleClient) {
  name: 'ClientIPAddress'
  parent: mysqlserver
  properties: {
    startIpAddress: clientIPAddress
    endIpAddress: clientIPAddress
  }
}

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
