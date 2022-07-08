// https://docs.microsoft.com/en-us/azure/templates/microsoft.app/managedenvironments?tabs=bicep#vnetconfiguration
// https://docs.microsoft.com/en-us/azure/container-apps/vnet-custom?tabs=bash&pivots=azure-portal

param location string = 'centralindia'

param vnetName string = 'vnet-aca'
param vnetCidr string = '10.42.0.0/21' // /16 minimum ?

@description('Resource ID of a subnet for infrastructure components. This subnet must be in the same VNET as the subnet defined in runtimeSubnetId. Must not overlap with any other provided IP ranges.')
param infrastructureSubnetName string = 'snet-infra' // used for the AKS nodes
param infrastructureSubnetCidr string = '10.42.1.0/23' // The CIDR prefix must be smaller than or equal to 23

// https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#virtual-network-requirements
var infrastructureSubnet = {
  name: infrastructureSubnetName
  cidr: infrastructureSubnetCidr
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCidr
      ]
    }
    subnets: [
      {
        name: infrastructureSubnet.name
        properties: {
          addressPrefix: infrastructureSubnet.cidr
          serviceEndpoints: [
            {
              service: 'Microsoft.ContainerRegistry'
              locations: [
                '*'
              ]
            }
            {
              service: 'Microsoft.KeyVault'
              locations: [
                '*'
              ]
            }            
          ]
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }        
      }
    ]
    enableDdosProtection: false
  }
}

output vnetId string = vnet.id
output infrastructureSubnetId string = vnet.properties.subnets[0].id
output infrastructureSubnetAddressPrefix string = vnet.properties.subnets[0].properties.addressPrefix

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing =  {
  name: infrastructureSubnetName
}

// output subnetIpCfgId string = subnet.properties.ipConfigurations[0].id
