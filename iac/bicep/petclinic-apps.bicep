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


@description('A UNIQUE name')
@maxLength(23)
param appName string = 'petcliaca${uniqueString(resourceGroup().id, subscription().id)}'

param location string = resourceGroup().location
// param rgName string = 'rg-${appName}'

@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string // = 'kv-${appName}'

@description('The name of the KV RG')
param kvRGName string

@description('The name of the KV Endpoint')
param springCloudAzureKeyVaultEndpoint string = 'https://${kvName}.vault.azure.net'

param setKVAccessPolicies bool = true

@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault.')
param tenantId string = subscription().tenantId

@description('The Azure Subscription ID that should be used for authenticating requests to the Key Vault and used by GitHub Action settings.')
param subscriptionId string = subscription().id

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.4.jar'

param appInsightsName string = 'appi-${appName}'

// https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/check-name-availability
@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

@description('The name of the ACR Repository')
param acrRepository string = 'petclinic'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('Should the service be deployed to a Corporate VNet ?')
param deployToVNet bool = false

param vnetName string = 'vnet-aca'

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
param vetsServiceContainerAppName string = 'aca-${appName}-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppName string = 'aca-${appName}-visits-service'

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-admin-server:{{ github.sha }}')
param imageNameAdminServer string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-config-server:{{ github.sha }}')
param imageNameConfigServer string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-customers-service:{{ github.sha }}')
param imageNameCustomersService string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-vets-service:{{ github.sha }}')
param imageNameVetsService string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-visits-service:{{ github.sha }}')
param imageNameVisitsService string

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' existing = if (deployToVNet) {
  name: vnetName
}

resource ACR 'Microsoft.ContainerRegistry/registries@2022-12-01' existing = {
  name: acrName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource kvRG 'Microsoft.Resources/resourceGroups@2022-09-01' existing = {
  name: kvRGName
  scope: subscription()
}

resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
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

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep
module azurecontainerapp './modules/aca/aca.bicep' = {
  name: 'azurecontainerapp'
  // scope: resourceGroup(rg.name)
  params: {
    appName: appName
    location: location
    acrName: acrName
    acrRepository:acrRepository
    azureContainerAppEnvName: azureContainerAppEnvName
    appInsightsInstrumentationKey: appInsights.properties.ConnectionString
    applicationInsightsAgentJarFilePath: applicationInsightsAgentJarFilePath
    springCloudAzureKeyVaultEndpoint: springCloudAzureKeyVaultEndpoint
    springCloudAzureTenantId: kv.getSecret('SPRING-CLOUD-AZURE-TENANT-ID')
    tenantId: tenantId
    subscriptionId: subscriptionId
    registryUrl: ACR.properties.loginServer
    //registryUsr: ACR.listCredentials().username
    //registryPassword: ACR.listCredentials().passwords[0].value
    // ghaSettingsCfgRuntimeStack: ghaSettingsCfgRuntimeStack
    // ghaSettingsCfgRuntimeVersion: ghaSettingsCfgRuntimeVersion
    adminServerContainerAppName: adminServerContainerAppName
    configServerContainerAppName: configServerContainerAppName
    customersServiceContainerAppName: customersServiceContainerAppName
    vetsServiceContainerAppName: vetsServiceContainerAppName
    visitsServiceContainerAppName: visitsServiceContainerAppName
    imageNameAdminServer: imageNameAdminServer
    imageNameConfigServer: imageNameConfigServer
    imageNameCustomersService: imageNameCustomersService
    imageNameVetsService: imageNameVetsService
    imageNameVisitsService: imageNameVisitsService
  }
}


// https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/key-vault-parameter?tabs=azure-cli
/*
The user who deploys the Bicep file must have the Microsoft.KeyVault/vaults/deploy/action permission for the scope 
of the resource group and key vault. 
The Owner and Contributor roles both grant this access.
If you created the key vault, you're the owner and have the permission.
*/


// Specifies all Apps Identities {"appName":"","appIdentity":""} wrapped into an object.')
/*
var appsObject = { 
  apps: [
    {
    appName: 'customers-service'
    appIdentity: azurecontainerapp.outputs.customersServiceContainerAppIdentity
    }
    {
    appName: 'vets-service'
    appIdentity: azurecontainerapp.outputs.vetsServiceContainerAppNameContainerAppIdentity
    }
    {
    appName: 'visits-service'
    appIdentity: azurecontainerapp.outputs.visitsServiceContainerAppIdentity
    }
  ]
}
  
var accessPoliciesObject = {
  accessPolicies: [
    {
      objectId: azurecontainerapp.outputs.customersServiceContainerAppIdentity
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      objectId: azurecontainerapp.outputs.vetsServiceContainerAppNameContainerAppIdentity
      tenantId: tenantId
      permissions: {
        secrets: [
          'get'
          'list'
        ]
      }
    }
    {
      objectId:  azurecontainerapp.outputs.visitsServiceContainerAppIdentity
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

// create accessPolicies https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/accesspolicies?tabs=bicep
// When enableRbacAuthorization is true in KV, the key vault will use RBAC for authorization of data actions, and the access policies specified in vault properties will be ignored
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
*/
