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
param ghaSettingsCfgRuntimeStack string = 'JAVA'

@description('The GitHub Action Settings Configuration / Runtime Version')
param ghaSettingsCfgRuntimeVersion string = '11-java11'


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

module azurecontainerapp './modules/aca/aca-test.bicep' = {
  name: 'azurecontainerapp'
  // scope: resourceGroup(rg.name)
  params: {
    appName: appName
    location: location
    acrName: acrName
    acrRepository:acrRepository
    azureContainerAppEnvName: azureContainerAppEnvName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    appInsightsInstrumentationKey: appInsights.properties.ConnectionString
    applicationInsightsAgentJarFilePath: applicationInsightsAgentJarFilePath
    springCloudAzureKeyVaultEndpoint:  kv.getSecret('SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT') // 'https://kv-petcliaca442.vault.azure.net/'
    springCloudAzureTenantId: kv.getSecret('SPRING-CLOUD-AZURE-TENANT-ID') // '72f988bf-86f1-41af-91ab-2d7cd011db47'
    revisionName: revisionName
    ghaGitBranchName: ghaGitBranchName
    springDataSourceUrl:  kv.getSecret('SPRING-DATASOURCE-URL') // 'jdbc:mysql://petcliaca.mysql.database.azure.com:3306/petclinic?useSSL=true&requireSSL=true&enabledTLSProtocols=TLSv1.2&verifyServerCertificate=true'
    springDataSourceUsr: kv.getSecret('SPRING-DATASOURCE-USERNAME') // 'mys_adm' 
    springDataSourcePwd: kv.getSecret('SPRING-DATASOURCE-PASSWORD') // 'IsTrator42!'
    tenantId: tenantId
    subscriptionId: subscriptionId
    ghaSettingsCfgCredClientId:  kv.getSecret('SPN-ID') //'5733a46c-4cc5-44f7-9f7d-84257b0e2a28'  ghaSettingsCfgCredClientId
    ghaSettingsCfgCredClientSecret: kv.getSecret('SPN-PWD')  // 'z3P8Q~i.f.MkjJYST9rkd.JX4UrKDCb_jd4-bcas' ghaSettingsCfgCredClientSecret
    ghaSettingsCfgRegistryUserName: ACR.listCredentials().username // 'acrpetcliaca' 
    ghaSettingsCfgRegistryPassword: ACR.listCredentials().passwords[0].value // 'W0wA2ogihOROyeiixh4c9Cn3ZA8S1/8F'
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
    //ghaSettingsCfgRuntimeStack: ghaSettingsCfgRuntimeStack
    //ghaSettingsCfgRuntimeVersion: ghaSettingsCfgRuntimeVersion
    adminServerContainerAppName: adminServerContainerAppName
    discoveryServerContainerAppName: discoveryServerContainerAppName
    configServerContainerAppName: configServerContainerAppName
    apiGatewayContainerAppName: apiGatewayContainerAppName
    customersServiceContainerAppName: customersServiceContainerAppName
    vetsServiceContainerAppName: vetsServiceContainerAppName
    visitsServiceContainerAppName: visitsServiceContainerAppName
  }
}
