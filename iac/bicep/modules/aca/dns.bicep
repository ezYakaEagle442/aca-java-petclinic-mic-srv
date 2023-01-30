@description('The location of the Azure resources.')
param location string = resourceGroup().location

param vnetName string = 'vnet-aca'

@description('Static IP of the Environment')
param corpManagedEnvironmentStaticIp string

/*

@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-${appName}-admin-server'

@description('The Azure Container App instance name for api-gateway')
param apiGatewayContainerAppName string = 'aca-${appName}-api-gateway'

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-${appName}-config-server'

@description('The Azure Container App instance name for customers-service')
param customersServiceContainerAppName string = 'aca-${appName}-customers-service'

@description('The Azure Container App Environment name for vets-service')
param vetsServiceContainerAppName string = 'aca-${appName}-vets-service'

@description('The Azure Container App Environment name for visits-service')
param visitsServiceContainerAppName string = 'aca-${appName}-visits-service'
*/

resource acaPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  //<env>.<RANDOM>.<REGION>.azurecontainerapps.io. Ex: https://aca-test-vnet.wittyhill-01dfb8c1.westeurope.azurecontainerapps.io
  name: '${location}.azurecontainerapps.io' // 'private.azurecontainerapps.io'
  location: 'global'  // /!\ 'global' instead of '${location}'. This is because Azure DNS is a global service. otherwise you will hit this error:"MissingRegistrationForLocation. "The subscription is not registered for the resource type 'privateDnsZones' in the location 'westeurope' 
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing =  {
  name: vnetName
}
output vnetId string = vnet.id

resource DnsVNetLinklnkACA 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'dns-vnet-lnk-aca-petclinic'
  location: 'global'  // /!\ 'global' instead of '${location}'. This is because Azure DNS is a global service.
  parent: acaPrivateDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}
output private_dns_link_id string = DnsVNetLinklnkACA.id

resource acaAppsRecordSet 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '*' // customersServiceContainerAppName
  parent: acaPrivateDnsZone
  properties: {
    aRecords: [
      {
        ipv4Address: corpManagedEnvironmentStaticIp // appsAksLb.properties.frontendIPConfigurations[0].properties.privateIPAddress
      }
    ]
    /*
    cnameRecord: {
      cname: customersServiceContainerAppName
    }
    */
    ttl: 360
  }
}

/*

resource appNetworkRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: appNetworkResourceGroup
  scope: subscription()
}

resource serviceRuntimeNetworkRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: serviceRuntimeNetworkResourceGroup
  scope: subscription()
}

resource appsAksLb 'Microsoft.Network/loadBalancers@2021-05-01' existing = {
  scope: appNetworkRG
  name: 'kubernetes-internal' // 'kubernetes'
}
output appsAksLbFrontEndIpConfigId string = appsAksLb.properties.frontendIPConfigurations[0].id
output appsAksLbFrontEndIpConfigName string = appsAksLb.properties.frontendIPConfigurations[0].name
output appsAksLbFrontEndIpPrivateIpAddress string = appsAksLb.properties.frontendIPConfigurations[0].properties.privateIPAddress

resource acaServiceRuntime_AksLb 'Microsoft.Network/loadBalancers@2021-05-01' existing = {
  scope: serviceRuntimeNetworkRG
  name: 'kubernetes-internal'
}
output acaServiceRuntime_AksLbFrontEndIpConfigId string = acaServiceRuntime_AksLb.properties.frontendIPConfigurations[0].id
output acaServiceRuntime_AksLbFrontEndIpConfigName string = acaServiceRuntime_AksLb.properties.frontendIPConfigurations[0].name

*/
