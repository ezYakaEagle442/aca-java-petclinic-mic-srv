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
param vetsServiceContainerAppName string = 'aca-env-${appName}-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppName string = 'aca-env-${appName}-visits-service'

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

@description('The GitHub Action Settings Configuration / Registry User Name')
param ghaSettingsCfgRegistryUserName string

@description('The GitHub Action Settings Configuration / Registry Password')
@secure()
param ghaSettingsCfgRegistryPassword string

@description('The GitHub Action Settings Configuration / Registry URL')
param ghaSettingsCfgRegistryUrl string

@description('The GitHub Action Settings / Repo URL')
param ghaSettingsCfgRepoUrl string = 'https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv'

@description('The GitHub Action Settings Configuration / Publish Type')
param ghaSettingsCfgPublishType string = 'Image'

/* They seem to be more App Service focused as this interface is shared with App Service.
      https://docs.microsoft.com/en-us/javascript/api/@azure/arm-appservice/githubactioncodeconfiguration?view=azure-node-latest
az webapp list-runtimes –-linux [
[
  "DOTNETCORE:6.0",
  "DOTNETCORE:3.1",
  "NODE:16-lts",
  "NODE:14-lts",
  "PYTHON:3.9",
  "PYTHON:3.8",
  "PYTHON:3.7",
  "PHP:8.0",
  "PHP:7.4",
  "RUBY:2.7",
  "JAVA:11-java11",
  "JAVA:8-jre8",
  "JBOSSEAP:7-java11",
  "JBOSSEAP:7-java8",
  "TOMCAT:10.0-java11",
  "TOMCAT:10.0-jre8",
  "TOMCAT:9.0-java11",
  "TOMCAT:9.0-jre8",
  "TOMCAT:8.5-java11",
  "TOMCAT:8.5-jre8"
]
*/
@description('The GitHub Action Settings Configuration / Runtime Stack')
param ghaSettingsCfgRegistryRuntimeStack string = 'JAVA'

@description('The GitHub Action Settings Configuration / Runtime Version')
param ghaSettingsCfgRegistryRuntimeVersion string = '11-java11'

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

module ACR 'acr.bicep' = {
  name: acrName
  params: {
    appName: appName
    acrName: acrName
    location: location
    tenantId: tenantId
    networkRuleSetCidr: runtimeSubnetCidr
  }
}
// /!\ Once ACR is created, you need to build the Apps and to push the images to ACR


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
    adminServerContainerAppName: adminServerContainerAppName
    discoveryServerContainerAppName: discoveryServerContainerAppName
    configServerContainerAppName: configServerContainerAppName
    apiGatewayContainerAppName: apiGatewayContainerAppName
    customersServiceContainerAppName: customersServiceContainerAppName
    vetsServiceContainerAppName: vetsServiceContainerAppName
    visitsServiceContainerAppName: visitsServiceContainerAppName
  }
  dependsOn: [
    ACR
  ]
}

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: azureContainerAppEnvName
  location: location
}

resource CustomersServiceContainerApp 'Microsoft.App/containerApps@2022-03-01' existing = {
  name: customersServiceContainerAppName
}

resource VetsServiceContainerApp 'Microsoft.App/containerApps@2022-03-01' existing = {
  name: vetsServiceContainerAppName
}

resource VisitsServiceContainerApp 'Microsoft.App/containerApps@2022-03-01' existing = {
  name: visitsServiceContainerAppName
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
    acaCustomersServicePrincipalId: CustomersServiceContainerApp.identity.principalId
    acaVetsServicePrincipalId: VetsServiceContainerApp.identity.principalId
    acaVisitsServicePrincipalId: VisitsServiceContainerApp.identity.principalId
  }
  dependsOn: [
    vnet
    ACR
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
    azureContainerAppsOutboundPubIP: corpManagedEnvironment.properties.staticIp // CustomersServiceContainerApp.properties.outboundIPAddresses[0]
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
    appIdentity: CustomersServiceContainerApp.identity.principalId
    }
    {
    appName: 'vets-service'
    appIdentity: VetsServiceContainerApp.identity.principalId
    }
    {
    appName: 'visits-service'
    appIdentity: VisitsServiceContainerApp.identity.principalId
    }
  ]
}
  
var accessPoliciesObject = {
  accessPolicies: [
    {
      objectId: CustomersServiceContainerApp.identity.principalId
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      objectId: VetsServiceContainerApp.identity.principalId
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      objectId: VisitsServiceContainerApp.identity.principalId
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
