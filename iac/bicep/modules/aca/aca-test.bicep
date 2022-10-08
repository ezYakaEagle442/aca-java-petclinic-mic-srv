// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

// https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/check-name-availability
@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

@description('The name of the ACR Repository')
param acrRepository string = 'petclinic'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

@description('The Log Analytics workspace name used by Azure Container App instance')
param logAnalyticsWorkspaceName string = 'log-${appName}'

@secure()
@description('The Azure Active Directory tenant ID that should be used by Key Vault in the Spring Config')
param springCloudAzureTenantId string

@secure()
@description('The Azure Key Vault EndPoint that should be used by Key Vault in the Spring Config. Ex: https://<key-vault-name>.vault.azure.net')
param springCloudAzureKeyVaultEndpoint string

@secure()
@description('The Spring Datasource / MySQL DB admin user name  - this is a secret stored in Key Vault')
param springDataSourceUsr string
@secure()
@description('The Spring Datasource / MySQL DB admin user password  - this is a secret stored in Key Vault')
param springDataSourcePwd string
@secure()
@description('The Spring Datasource / MySQL DB URL - this is a secret stored in Key Vault')
param springDataSourceUrl string


// https://docs.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cjava#configure-managed-identities
@description('The Azure Active Directory tenant ID that should be used to store the GH Actions SPN credentials and to manage Azure Container Apps Identities.')
param tenantId string = subscription().tenantId
param subscriptionId string = subscription().id


@allowed([
  '0.25'
  '0.5'
  '0.75'
  '1.0' 
  '1.25'
  '1.5'
  '1.75'
  '2.0'    
])
@description('The container Resources CPU. The total CPU and memory allocations requested for all the containers in a container app must add up to one of the following combinations. See https://learn.microsoft.com/en-us/azure/container-apps/containers#configuration')
param containerResourcesCpu string = '0.5'

@allowed([
  '0.5Gi'
  '1.0Gi'  
  '1.5Gi'
  '2.0Gi'    
  '2.5Gi'
  '3.0Gi'  
  '3.5Gi'
  '4.0Gi'    
])
@description('The container Resources Memory. The total CPU and memory allocations requested for all the containers in a container app must add up to one of the following combinations. See https://learn.microsoft.com/en-us/azure/container-apps/containers#configuration')
param containerResourcesMemory string = '1.0Gi'


@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.1.jar'

@secure()
@description('The Application Insights Intrumention Key. see https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string')
param appInsightsInstrumentationKey string

@description('The GitHub Action Settings / Repo URL')
param ghaSettingsCfgRepoUrl string = 'https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv'

@secure()
@description('The GitHub Action Settings Configuration / Registry User Name')
param ghaSettingsCfgRegistryUserName string

@secure()
@description('The GitHub Action Settings Configuration / Registry Password')
param ghaSettingsCfgRegistryPassword string

@description('The GitHub Action Settings Configuration / Registry URL')
param ghaSettingsCfgRegistryUrl string

param revisionName string = 'poc-aca-101'

@description('The GitHub branch name')
param ghaGitBranchName string = 'main'

@secure()
@description('The GitHub Action Settings Configuration / Azure Credentials / Client Id')
param ghaSettingsCfgCredClientId string

@secure()
@description('The GitHub Action Settings Configuration / Azure Credentials / Client Secret')
param ghaSettingsCfgCredClientSecret string

@description('The GitHub Action Settings Configuration / Docker file Path for admin-server Azure Container App ')
param ghaSettingsCfgDockerFilePathAdminServer string = 'docker/petclinic-admin-server/Dockerfile/'

@description('The GitHub Action Settings Configuration / Docker file Path for discovery-server Azure Container App ')
param ghaSettingsCfgDockerFilePathDiscoveryServer string = '../../../../docker/petclinic-discovery-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for api-gateway Azure Container App ')
param ghaSettingsCfgDockerFilePathApiGateway string = '../../../../docker/petclinic-api-gateway/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for  config-server Azure Container App ')
param ghaSettingsCfgDockerFilePathConfigserver string = '../../../../docker/petclinic-config-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for customers-service Azure Container App ')
param ghaSettingsCfgDockerFilePathCustomersService string = '../../../../docker/petclinic-customers-service/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for vets-service Azure Container App ')
param ghaSettingsCfgDockerFilePathVetsService string = '../../../../docker/petclinic-vets-service/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for visits-service Azure Container App ')
param ghaSettingsCfgDockerFilePathVisitsService string = '../../../../docker/petclinic-visits-service/Dockerfile'


/* They seem to be more App Service focused as this interface is shared with App Service.
https://docs.microsoft.com/en-us/javascript/api/@azure/arm-appservice/githubactioncodeconfiguration?view=azure-node-latest
runtimeStack: ghaSettingsCfgRuntimeStack
runtimeVersion: ghaSettingsCfgRuntimeVersion
*/
@description('The GitHub Action Settings Configuration / Publish Type')
param ghaSettingsCfgPublishType string = 'Image'

@description('The GitHub Action Settings Configuration / Runtime Stack')
param ghaSettingsCfgRuntimeStack string = 'JAVA'

@description('The GitHub Action Settings Configuration / Runtime Version')
param ghaSettingsCfgRuntimeVersion string = '11-java11'

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-${appName}-admin-server'

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-${appName}-config-server'

// should be useless as we rely on tha ACA/AKS/K8S native discovery services
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

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: azureContainerAppEnvName
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep
resource AdminServerContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: adminServerContainerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
    /*
    userAssignedIdentities: {
      '<IDENTITY1_RESOURCE_ID>': {

      }
    }
    */
  }
  properties: {
    managedEnvironmentId: corpManagedEnvironment.id 
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        allowInsecure: true
        external: true
        targetPort: 9090
        traffic: [
          {
            latestRevision: true
            // revisionName: revisionName Traffic weight cannot use "LatestRevision: true" and "RevisionName" at the same time
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          // Managedidentity is enabled on ACR
          server: ghaSettingsCfgRegistryUrl
          identity: 'system'
          //username: ghaSettingsCfgRegistryUserName
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
        {
          name: 'registrypassword'
          value: ghaSettingsCfgRegistryPassword
        }
        {
          name: 'appinscon'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'springcloudazuretenantid'
          value: springCloudAzureTenantId
        }
        {
          name: 'springcloudazurekvendpoint'
          value: springCloudAzureKeyVaultEndpoint
        }                
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:/tmp/app/applicationinsights-agent-3.4.1.jar", "org.springframework.boot.loader.JarLauncher", "--server.port=9090", "--spring.profiles.active=docker,mysql"]'
          ]
          env: [
            {
              name: 'SPRING_PROFILES_ACTIVE'
              value: 'docker,mysql'
            }
            {
              // https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinscon'
            }
            {
              name: 'SPRING_CLOUD_AZURE_TENANT_ID'
              secretRef: 'springcloudazuretenantid'
            }   
            {
              name: 'SPRING_CLOUD_AZURE_KEY_VAULT_ENDPOINT'
              secretRef: 'springcloudazurekvendpoint'
            }                                 
          ]
          image: 'acrpetcliaca.azurecr.io/petclinic/petclinic-admin-server:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' acrpetcliaca/petclinic/petclinic-admin-server:latest
          name: adminServerContainerAppName

          resources: {
            cpu: any(containerResourcesCpu)
            memory: containerResourcesMemory
          }
        }
      ]
    }
  }
}


output AdminServerContainerAppIdentity string = AdminServerContainerApp.identity.principalId
output AdminServerContainerAppOutboundIPAddresses array = AdminServerContainerApp.properties.outboundIPAddresses
output AdminServerContainerAppLatestRevisionName string = AdminServerContainerApp.properties.latestRevisionName
output AdminServerContainerAppLatestRevisionFqdn string = AdminServerContainerApp.properties.latestRevisionFqdn
output AdminServerContainerAppIngressFqdn string = AdminServerContainerApp.properties.configuration.ingress.fqdn
output AdminServerContainerAppConfigSecrets array = AdminServerContainerApp.properties.configuration.secrets


resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

resource githubActionSettingsAdminServer 'Microsoft.App/containerApps/sourcecontrols@2022-03-01' = {
  name: 'aca-gha-set-admin-srv'
  parent: AdminServerContainerApp
  properties: {
    branch: 'main'
    githubActionConfiguration: {
      azureCredentials: {
        clientId:'5733a46c-4cc5-44f7-9f7d-84257b0e2a28'
        clientSecret: 'z3P8Q~i.f.MkjJYST9rkd.JX4UrKDCb_jd4-bcas'
        subscriptionId: '7b5f97dc-3c4d-424d-8288-bdde3891f242'
        tenantId: '72f988bf-86f1-41af-91ab-2d7cd011db47'
      }
      contextPath: './docker/petclinic-admin-server/Dockerfile' // The relative location of the Dockerfile in the repository. If this path is not specified the dockerfile should be in the repository root folder.
      image: 'petclinic/petclinic-admin-server:latest' // Tagged with GitHub commit ID (SHA), ex: petclinic/petclinic-admin-server:${{ github.sha }}
      os: 'Linux'
      registryInfo: {
        // registryPassword: 'W0wA2ogihOROyeiixh4c9Cn3ZA8S1/8F' // Managedidentity is enabled on ACR
        // https://learn.microsoft.com/en-us/azure/container-apps/containers#managed-identity-with-azure-container-registry
        registryUrl: 'acrpetcliaca.azurecr.io' // yourACR.azurecr.io
        // registryUserName: 'acrpetcliaca'
        // registryPassword: ghaSettingsCfgRegistryPassword
      } 
      publishType: 'docker'
    }
    repoUrl: 'https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv'
  }
}
