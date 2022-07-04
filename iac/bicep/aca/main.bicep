// Bicep Templates availables at https://github.com/Azure/azure-quickstart-templates

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-string#uniquestring
// uniqueString: You provide parameter values that limit the scope of uniqueness for the result. You can specify whether the name is unique down to subscription, resource group, or deployment.
// The returned value isn't a random string, but rather the result of a hash function. The returned value is 13 characters long. It isn't globally unique

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-string#guid
//guid function: Returns a string value containing 36 characters, isn't globally unique
// Unique scoped to deployment for a resource group
// param appName string = 'demo${guid(resourceGroup().id, deployment().name)}'

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-string#newguid
// Returns a string value containing 36 characters in the format of a globally unique identifier. 
// /!\ This function can only be used in the default value for a parameter.

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions-date#utcnow
// You can only use this function within an expression for the default value of a parameter.

// Check the REST API : https://docs.microsoft.com/en-us/rest/api/containerapps/


@maxLength(20)
// to get a unique name each time ==> param appName string = 'demo${uniqueString(resourceGroup().id, deployment().name)}'
param appName string = 'petclinic${uniqueString(resourceGroup().id)}'

param location string = 'centralindia'
// param rgName string = 'rg-${appName}'

@description('The Azure Container Apps Resource Provider ID')
param azureContainerAppsRp string

@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string // = 'kv-${appName}'

@description('The name of the KV RG')
param kvRGName string

param setKVAccessPolicies bool = false

@description('Is KV Network access public ?')
@allowed([
  'enabled'
  'disabled'
])
param publicNetworkAccess string = 'enabled'

@description('The KV SKU name')
@allowed([
  'premium'
  'standard'
])
param kvSkuName string = 'standard'

@description('Specifies all KV secrets {"secretName":"","secretValue":""} wrapped in a secure object.')
@secure()
param secretsObject object

@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault.')
param tenantId string = subscription().tenantId

@description('The MySQL DB Admin Login.')
param administratorLogin string = 'mys_adm'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

param appInsightsName string = 'appi-${appName}'
param appInsightsDiagnosticSettingsName string = 'dgs-${appName}-send-logs-and-metrics-to-log-analytics'

param acrName string = 'acr${appName}'

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-${appName}-admin-server'

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-${appName}-config-server'

@description('The Azure Container App instance name for discovery-server')
param discoveryServerContainerAppName string = 'aca-${appName}-discovery-server'

@description('The Azure Container App instance name for api-gateway')
param apiGatewayContainerAppName string = 'aca-${appName}-api-gateway'

@description('The Azure Container App instance name for customers-service')
param customersServiceContainerAppName string = 'aca-${appName}-customers-service'

@description('The Azure Container App instance name for vets-service')
param vetsServiceContainerAppEnvName string = 'aca-env-${appName}-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppEnvName string = 'aca-env-${appName}-visits-service'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

param vnetName string = 'vnet-aca'
param vnetCidr string = '10.42.0.0/21' // /16 minimum ?

@description('Resource ID of a subnet for infrastructure components. This subnet must be in the same VNET as the subnet defined in runtimeSubnetId. Must not overlap with any other provided IP ranges.')
param infrastructureSubnetName string = 'snet-infra' // used for the AKS nodes
param infrastructureSubnetCidr string = '10.42.1.0/23' // The CIDR prefix must be smaller than or equal to 23
@description('Resource ID of a subnet that Container App containers are injected into. This subnet must be in the same VNET as the subnet defined in infrastructureSubnetId. Must not overlap with any other provided IP ranges.')
param runtimeSubnetCidr string = '10.42.2.0/23'
param runtimeSubnetName string = 'snet-run'

@description('An IP address from the IP range defined by platformReservedCidr that will be reserved for the internal DNS server')
param platformReservedDnsIP string = '10.42.1.10'

param zoneRedundant bool = false

@secure()
@description('The MySQL DB Admin Password.')
param administratorLoginPassword string

@description('Allow client workstation to MySQL for local Dev/Test only')
param clientIPAddress string

@description('Allow Azure Container App subnet to access MySQL DB')
param startIpAddress string = '10.42.1.0'

@description('Allow Azure Container App subnet to access MySQL DB')
param endIpAddress string = '10.42.1.255'

@description('The GitHub branch name')
param ghaGitBranchName string = 'main'

@description('The GitHub Action Settings Configuration / Azure Credentials / Client Id')
param ghaSettingsCfgCredClientId string

@description('The GitHub Action Settings Configuration / Azure Credentials / Client Secret')
param ghaSettingsCfgCredClientSecret string

@description('The GitHub Action Settings Configuration / Docker file Path for admin-server Azure Container App ')
param ghaSettingsCfgDockerFilePathAdminServer string = './docker/petclinic-admin-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for discovery-server Azure Container App ')
param ghaSettingsCfgDockerFilePathDiscoveryServer string = './docker/petclinic-discovery-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for api-gateway Azure Container App ')
param ghaSettingsCfgDockerFilePathApiGateway string = './docker/petclinic-api-gateway/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for  config-server Azure Container App ')
param ghaSettingsCfgDockerFilePathConfigserver string = './docker/petclinic-config-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for customers-service Azure Container App ')
param ghaSettingsCfgDockerFilePathCustomersService string = './docker/petclinic-customers-service/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for vets-service Azure Container App ')
param ghaSettingsCfgDockerFilePathVetsService string = './docker/petclinic-vets-service/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for visits-service Azure Container App ')
param ghaSettingsCfgDockerFilePathVisitsService string = './docker/petclinic-visits-service/Dockerfile'


@description('The GitHub Action Settings Configuration / Publish Type')
param ghaSettingsCfgPublishType string = xxx

@description('The GitHub Action Settings Configuration / Registry User Name')
param ghaSettingsCfgRegistryUserName string

@description('The GitHub Action Settings Configuration / Registry Password')
param ghaSettingsCfgRegistryPassword string

@description('The GitHub Action Settings Configuration / Registry URL')
param ghaSettingsCfgRegistryUrl string

@description('The GitHub Action Settings Configuration / Runtime Stack')
param ghaSettingsCfgRegistryRuntimeStack string = xxx

@description('The GitHub Action Settings Configuration / Runtime Version')
param ghaSettingsCfgRegistryRuntimeVersion string = xxx

@description('The GitHub Action Settings / Repo URL')
param ghaSettingsCfgRepoUrl string = xxx

/*
module rg 'rg.bicep' = {
  name: 'rg-bicep-${appName}'
  scope: subscription()
  params: {
    rgName: rgName
    location: location
  }
}
*/

// https://docs.microsoft.com/en-us/azure/spring-cloud/how-to-deploy-in-azure-virtual-network?tabs=azure-portal#virtual-network-requirements
module vnet 'vnet.bicep' = {
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

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
    dataEndpointEnabled: false // data endpoint rule is not supported for the SKU Basic
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}


module azurecontainerapp 'aca.bicep' = {
  name: 'azurecontainerapp'
  // scope: resourceGroup(rg.name)
  params: {
    appName: appName
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsName: appInsightsName
    azureContainerAppEnvName: azureContainerAppEnvName
    vnetName: vnetName
    zoneRedundant: zoneRedundant
    ghaGitBranchName: ghaGitBranchName
    ghaSettingsCfgCredClientId: ghaSettingsCfgCredClientId
    ghaSettingsCfgRegistryUserName: ghaSettingsCfgRegistryUserName
    ghaSettingsCfgRegistryPassword: ghaSettingsCfgRegistryPassword
    ghaSettingsCfgRegistryUrl: ghaSettingsCfgRegistryUrl
    ghaSettingsCfgCredClientSecret: ghaSettingsCfgCredClientSecret
    ghaSettingsCfgDockerFilePathAdminServer: ghaSettingsCfgDockerFilePathAdminServer
    ghaSettingsCfgDockerFilePathApiGateway: ghaSettingsCfgDockerFilePathApiGateway
    ghaSettingsCfgDockerFilePathConfigserver: ghaSettingsCfgDockerFilePathConfigserver
    ghaSettingsCfgDockerFilePathCustomersService: ghaSettingsCfgDockerFilePathCustomersService
    ghaSettingsCfgDockerFilePathVetsService: ghaSettingsCfgDockerFilePathVetsService
    ghaSettingsCfgDockerFilePathDiscoveryServer: ghaSettingsCfgDockerFilePathDiscoveryServer
    ghaSettingsCfgDockerFilePathVisitsService: ghaSettingsCfgDockerFilePathVisitsService
    ghaSettingsCfgRepoUrl: ghaSettingsCfgRepoUrl
    ghaSettingsCfgRegistryRuntimeStack: ghaSettingsCfgRegistryRuntimeStack
    ghaSettingsCfgRegistryRuntimeVersion: ghaSettingsCfgRegistryRuntimeVersion
    ghaSettingsCfgPublishType: ghaSettingsCfgPublishType
    configServerContainerAppName: configServerContainerAppName
    customersServiceContainerAppName: customersServiceContainerAppName
    discoveryServerContainerAppName: discoveryServerContainerAppName
    vetsServiceContainerAppEnvName: vetsServiceContainerAppEnvName
    visitsServiceContainerAppEnvName: visitsServiceContainerAppEnvName
    apiGatewayContainerAppName: apiGatewayContainerAppName

  }
}

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scope-extension-resources
module roleAssignments 'roleAssignments.bicep' = {
  name: 'role-assignments'
  params: {
    vnetName: vnetName
    subnetName: runtimeSubnetName
    acrName: acrName
    kvName: kvName
    kvRGName: kvRGName
    networkRoleType: 'Owner'
    kvRoleType: 'KeyVaultReader'
    acrRoleType: 'AcrPull'
    acaPrincipalId: azurecontainerapp.outputs.xxxContainerAppIdentity
  }
  dependsOn: [
    vnet
    acr
    azurecontainerapp
  ]  
}

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
    azureContainerAppsOutboundPubIP: azurecontainerapp.outputs.xxxContainerAppOutboundIPAddresses
  }
}



var vNetRules = [
  {
    'id': vnet.outputs.infrastructureSubnetId
    'ignoreMissingVnetServiceEndpoint': false
  }
  {
    'id': vnet.outputs.runtimeSubnetId
    'ignoreMissingVnetServiceEndpoint': false
  }  
]

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli
/*
The user who deploys the Bicep file must have the Microsoft.KeyVault/vaults/deploy/action permission for the scope 
of the resource group and key vault. 
The Owner and Contributor roles both grant this access.
If you created the key vault, you're the owner and have the permission.
*/


// Specifies all Apps Identities {"appName":"","appIdentity":""} wrapped into an object.')
var appsObject = { 
  apps: [
    {
    appName: 'customers-service'
    appIdentity: azurecontainerapp.outputs.customersServiceIdentity
    }
    {
    appName: 'vets-service'
    appIdentity: azurecontainerapp.outputs.vetsServiceIdentity
    }
    {
    appName: 'visits-service'
    appIdentity: azurecontainerapp.outputs.visitsServiceIdentity
    }
  ]
}
  
var accessPoliciesObject = {
  accessPolicies: [
    {
      objectId: azurecontainerapp.outputs.customersServiceIdentity
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      objectId: azurecontainerapp.outputs.vetsServiceIdentity
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      objectId:  azurecontainerapp.outputs.visitsServiceIdentity
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
  ]
}


// allow to Azure Container App subnetID and azureContainerAppIdentity
module KeyVault '../kv/kv.bicep'= {
  name: 'KeyVault'
  scope: resourceGroup(kvRGName)
  params: {
    location: location
    appName: appName
    kvName: kvName
    skuName: kvSkuName
    tenantId: tenantId
    publicNetworkAccess: publicNetworkAccess
    vNetRules: vNetRules
    setKVAccessPolicies: true
    accessPoliciesObject: accessPoliciesObject
  } 
}

// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/scenarios-secrets
module KeyVaultsecrets '../kv/kv_sec_key.bicep'= {
  name: 'KeyVaultsecrets'
  scope: resourceGroup(kvRGName)
  params: {
    kvName: kvName
    appName: appName
    secretsObject: secretsObject
  }
}
