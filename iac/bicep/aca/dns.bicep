/*
Test with
az deployment group create --name iac-101-aca-dns -f ./aca/dns.bicep -g rg-iac-aca-petclinic-mic-srv \
    -p appName=petcliaca --debug 
 --what-if to test like a dry-run
*/

@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

param vnetName string = 'vnet-azure-container-apps'

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-${appName}-admin-server'

@description('The Azure Container App instance name for api-gateway')
param apiGatewayContainerAppName string = 'aca-${appName}-api-gateway'

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-${appName}-config-server'

@description('The Azure Container App instance name for customers-service')
param customersServiceContainerAppName string = 'aca-${appName}-customers-service'

@description('The Azure Container App Environment name for vets-service')
param vetsServiceContainerAppName string = 'aca-env-${appName}-vets-service'

@description('The Azure Container App Environment name for visits-service')
param visitsServiceContainerAppName string = 'aca-env-${appName}-visits-service'

@description('Static IP of the Environment')
param corpManagedEnvironmentStaticIp string

/*
@description('The resource group where all network resources for apps will be created in')
param appNetworkResourceGroup string = 'rg-aca-petclinic'

@description('The resource group where all network resources for Azure Container App service runtime will be created in. Ex: MC_wittyhill-01dfb8c1-rg_wittyhill-01dfb8c1_westeurope')
param serviceRuntimeNetworkResourceGroup string
*/
resource acaPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  //<env>.<RANDOM>.<REGION>.azurecontainerapps.io. Ex: https://aca-test-vnet.wittyhill-01dfb8c1.westeurope.azurecontainerapps.io
  name: '${location}.azurecontainerapps.io' // 'private.azurecontainerapps.io'
  location:location
  // properties: {}
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing =  {
  name: vnetName
}
output vnetId string = vnet.id

resource DnsVNetLinklnkACA 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'dns-vnet-lnk-aca-petclinic'
  location: location
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
