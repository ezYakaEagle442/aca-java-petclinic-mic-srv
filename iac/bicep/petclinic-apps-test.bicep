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
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.1.jar'

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

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-discovery-server:{{ github.sha }}')
param imageNameDiscoveryServer string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-api-gateway:{{ github.sha }}')
param imageNameApiGateway string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-config-server:{{ github.sha }}')
param imageNameConfigServer string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-customers-service:{{ github.sha }}')
param imageNameCustomersService string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-vets-service:{{ github.sha }}')
param imageNameVetsService string

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-visits-service:{{ github.sha }}')
param imageNameVisitsService string

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

module azurecontainerapp './modules/aca/aca-user-id.bicep' = {
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
    springCloudAzureKeyVaultEndpoint:  kv.getSecret('SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT')
    springCloudAzureTenantId: kv.getSecret('SPRING-CLOUD-AZURE-TENANT-ID')
    springDataSourceUrl:  kv.getSecret('SPRING-DATASOURCE-URL') 
    springDataSourceUsr: kv.getSecret('SPRING-DATASOURCE-USERNAME')
    springDataSourcePwd: kv.getSecret('SPRING-DATASOURCE-PASSWORD')
    tenantId: tenantId
    subscriptionId: subscriptionId
    registryUrl: ACR.properties.loginServer
    //registryUsr: ACR.listCredentials().username //ACR.properties.adminUserEnabled ? ACR.properties.adminUsername : ''
    //registryPassword: ACR.listCredentials().passwords[0].value
    adminServerContainerAppName: adminServerContainerAppName
    discoveryServerContainerAppName: discoveryServerContainerAppName
    configServerContainerAppName: configServerContainerAppName
    apiGatewayContainerAppName: apiGatewayContainerAppName
    customersServiceContainerAppName: customersServiceContainerAppName
    vetsServiceContainerAppName: vetsServiceContainerAppName
    visitsServiceContainerAppName: visitsServiceContainerAppName
    imageNameAdminServer: imageNameAdminServer
    imageNameApiGateway: imageNameApiGateway
    imageNameConfigServer: imageNameConfigServer
    imageNameCustomersService: imageNameCustomersService
    imageNameDiscoveryServer: imageNameDiscoveryServer
    imageNameVetsService: imageNameVetsService
    imageNameVisitsService: imageNameVisitsService    
  }
}
