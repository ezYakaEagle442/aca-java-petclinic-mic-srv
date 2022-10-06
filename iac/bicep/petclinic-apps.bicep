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
param appName string = 'petcliaca${uniqueString(resourceGroup().id)}'

param location string = 'westeurope'
// param rgName string = 'rg-${appName}'

@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string // = 'kv-${appName}'

@description('The name of the KV RG')
param kvRGName string

param setKVAccessPolicies bool = true

@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault.')
param tenantId string = subscription().tenantId

@description('The Azure Subscription ID that should be used for authenticating requests to the Key Vault and used by GitHub Action settings.')
param subscriptionId string = subscription().id

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.3.0.jar'

param appInsightsName string = 'appi-${appName}'

// https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/check-name-availability
@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('Should the service be deployed to a Corporate VNet ?')
param deployToVNet bool = false

param vnetName string = 'vnet-aca'

@description('The GitHub Action Settings / git Revision')
param revisionName string = 'poc-aca-101'

@description('The GitHub Action Settings / Repo URL')
param ghaSettingsCfgRepoUrl string = 'https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv'

@description('The GitHub branch name')
param ghaGitBranchName string = 'main'
/*
@secure()
@description('The GitHub Action Settings Configuration / Azure Credentials / Client Id')
param ghaSettingsCfgCredClientId string

@secure()
@description('The GitHub Action Settings Configuration / Azure Credentials / Client Secret')
param ghaSettingsCfgCredClientSecret string
*/

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

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = if (deployToVNet) {
  name: vnetName
}

resource ACR 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: acrName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource kvRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: kvRGName
  scope: subscription()
}

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: kvName
  scope: kvRG
}

// Spring Cloud for Azure params required to get secrets from Key Vault.
// https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#basic-usage-3
// https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#advanced-usage
// https://github.com/ezYakaEagle442/spring-cloud-az-kv
// Use - instead of . in secret name. . isn’t supported in secret name. If your application have property name which contains ., 
// like spring.datasource.url, just replace . to - when save secret in Azure Key Vault. 
// For example: Save spring-datasource-url in Azure Key Vault. In your application, you can still use spring.datasource.url to retrieve property value.
module azurecontainerapp './modules/aca/aca.bicep' = {
  name: 'azurecontainerapp'
  // scope: resourceGroup(rg.name)
  params: {
    appName: appName
    location: location
    acrName: acrName
    azureContainerAppEnvName: azureContainerAppEnvName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsInstrumentationKey: appInsights.properties.ConnectionString
    applicationInsightsAgentJarFilePath: applicationInsightsAgentJarFilePath
    springCloudAzureKeyVaultEndpoint: kv.getSecret('SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT')
    springCloudAzureTenantId: kv.getSecret('SPRING-CLOUD-AZURE-TENANT-ID')
    revisionName: revisionName
    ghaGitBranchName: ghaGitBranchName
    springDataSourceUrl: kv.getSecret('SPRING-DATASOURCE-URL')
    springDataSourceUsr: kv.getSecret('SPRING-DATASOURCE-USERNAME')
    springDataSourcePwd: kv.getSecret('SPRING-DATASOURCE-PASSWORD')
    tenantId: tenantId
    subscriptionId: subscriptionId
    ghaSettingsCfgCredClientId: kv.getSecret('SPN-ID') // ghaSettingsCfgCredClientId
    ghaSettingsCfgCredClientSecret: kv.getSecret('SPN-PWD') // ghaSettingsCfgCredClientSecret
    ghaSettingsCfgRegistryUserName: ACR.listCredentials().username
    ghaSettingsCfgRegistryPassword: ACR.listCredentials().passwords[0].value
    ghaSettingsCfgRegistryUrl: ACR.properties.loginServer
    ghaSettingsCfgDockerFilePathAdminServer: ghaSettingsCfgDockerFilePathAdminServer
    ghaSettingsCfgDockerFilePathApiGateway: ghaSettingsCfgDockerFilePathApiGateway
    ghaSettingsCfgDockerFilePathConfigserver: ghaSettingsCfgDockerFilePathConfigserver
    ghaSettingsCfgDockerFilePathCustomersService: ghaSettingsCfgDockerFilePathCustomersService
    ghaSettingsCfgDockerFilePathVetsService: ghaSettingsCfgDockerFilePathVetsService
    ghaSettingsCfgDockerFilePathDiscoveryServer: ghaSettingsCfgDockerFilePathDiscoveryServer
    ghaSettingsCfgDockerFilePathVisitsService: ghaSettingsCfgDockerFilePathVisitsService
    ghaSettingsCfgRepoUrl: ghaSettingsCfgRepoUrl
    ghaSettingsCfgPublishType: ghaSettingsCfgPublishType
    // ghaSettingsCfgRuntimeStack: ghaSettingsCfgRuntimeStack
    // ghaSettingsCfgRuntimeVersion: ghaSettingsCfgRuntimeVersion
    adminServerContainerAppName: adminServerContainerAppName
    discoveryServerContainerAppName: discoveryServerContainerAppName
    configServerContainerAppName: configServerContainerAppName
    apiGatewayContainerAppName: apiGatewayContainerAppName
    customersServiceContainerAppName: customersServiceContainerAppName
    vetsServiceContainerAppName: vetsServiceContainerAppName
    visitsServiceContainerAppName: visitsServiceContainerAppName
  }
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
module roleAssignments './modules/aca/roleAssignments.bicep' = {
  name: 'role-assignments'
  params: {
    acrName: acrName
    acrRoleType: 'AcrPull'
    acaCustomersServicePrincipalId: CustomersServiceContainerApp.identity.principalId
    acaVetsServicePrincipalId: VetsServiceContainerApp.identity.principalId
    acaVisitsServicePrincipalId: VisitsServiceContainerApp.identity.principalId
    kvName: kvName
    kvRGName: kvRGName
    kvRoleType: 'KeyVaultSecretsUser'
    /*
    vnetName: vnetName
    subnetName: infrastructureSubnetName
    networkRoleType: 'Owner'
    */
  }
  dependsOn: [
    azurecontainerapp
  ]  
}


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

module KeyVaultAccessPolicies './modules/kv/kv_policies.bicep'= {
  name: 'KeyVaultAccessPolicies'
  scope: resourceGroup(kvRGName)
  params: {
    appName: appName
    kvName: kvName
    tenantId: tenantId
    accessPoliciesObject: accessPoliciesObject
  } 
}
