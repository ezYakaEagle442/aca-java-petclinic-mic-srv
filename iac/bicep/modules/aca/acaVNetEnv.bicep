
@maxLength(21)
// to get a unique name each time ==> param appName string = 'demo${uniqueString(resourceGroup().id, deployment().name)}'
param appName string = 'petcli${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

param appInsightsName string = 'appi-${appName}'

param zoneRedundant bool = false
param vnetName string = 'vnet-aca'
param vnetCidr string = '10.42.0.0/21' // /16 minimum ? soon /27 see https://github.com/microsoft/azure-container-apps/issues/247

// /!\ The following properties must be set together, or not set at all (they will be set by the platform): 
// DockerBridgeCidr, PlatformReservedCidr, PlatformReservedDnsIP

// Platform and Docker bridge CIDR blocks must not overlap each other, the address ranges of the provided subnets, or the following reserved IP ranges: 169.254.0.0/16,172.30.0.0/16,172.31.0.0/16,192.0.2.0/24,0.0.0.0/8,127.0.0.0/8
// see https://docs.microsoft.com/en-us/azure/container-apps/networking#restrictions
@description('Must have a size between /21 and /12. IP range in CIDR notation that can be reserved for environment infrastructure IP addresses. Must not overlap with any other provided IP ranges.')
param platformReservedCidr string = '10.90.0.0/21'

@description('An IP address from the IP range defined by platformReservedCidr that will be reserved for the internal DNS server. The address can not be the first address in the range, or the network address')
param platformReservedDnsIP string = '10.90.0.10' 

// https://docs.microsoft.com/en-us/azure/container-apps/vnet-custom-internal?tabs=bash&pivots=azure-cli#networking-parameters
// The platform-reserved-cidr and docker-bridge-cidr address ranges can't conflict with each other, or with the ranges of either provided subnet. Further, make sure these ranges don't conflict with any other address range in the VNET.
@description('The address range assigned to the Docker bridge network. This range must have a size between /28 and /12. CIDR notation IP range assigned to the Docker bridge, network. Must not overlap with any other provided IP ranges.')
param dockerBridgeCidr string = '10.42.42.0/28' // 172.17.0.1/16

@description('Resource ID of a subnet for infrastructure components. This subnet must be in the same VNET as the subnet defined in runtimeSubnetId. Must not overlap with any other provided IP ranges.')
param infrastructureSubnetName string = 'snet-infra' // used for the AKS nodes
param infrastructureSubnetCidr string = '10.42.2.0/23' // The CIDR prefix must be smaller than or equal to 23

@allowed([
  'log-analytics'
])
param logDestination string = 'log-analytics'

resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =  {
  name: logAnalyticsWorkspaceName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

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
     // runtimeSubnetCidr: runtimeSubnetCidr
     // runtimeSubnetName: runtimeSubnetName
  }   
}

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = {
  name: vnetName
}

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' =  {
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
    daprAIConnectionString: appInsights.properties.ConnectionString
    vnetConfiguration: {
      // The Docker bridge network address represents the default docker0 bridge network address present in all Docker installations. While docker0 bridge is not used by AKS clusters or the pods themselves, you must set this address to continue to support scenarios such as docker build within the AKS cluster. It is required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that does not collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16. You can reuse this range across different AKS clusters.
      internal: true // set to true if the environnement is private, i.e vnet injected. Boolean indicating the environment only has an internal load balancer. These environments do not have a public static IP resource. They must provide runtimeSubnetId and infrastructureSubnetId if enabling this property
      dockerBridgeCidr: dockerBridgeCidr
      platformReservedCidr: platformReservedCidr
      platformReservedDnsIP: platformReservedDnsIP
      infrastructureSubnetId: vnet.properties.subnets[0].id
      // runtimeSubnetId: vnet.properties.subnets[1].id The “runtime subnet” field is currently deprecated and not used. If you provide a value there during creation of your container apps environment it will be ignored. Only the infrastructure subnet is required if you wish to provide your own VNET.
    }
  }
  dependsOn: [
    vnetModule
  ]
}

output corpManagedEnvironmentId string = corpManagedEnvironment.id
output corpManagedEnvironmentName string = corpManagedEnvironment.name
output corpManagedEnvironmentDefaultDomain string = corpManagedEnvironment.properties.defaultDomain
output corpManagedEnvironmentStaticIp string = corpManagedEnvironment.properties.staticIp
