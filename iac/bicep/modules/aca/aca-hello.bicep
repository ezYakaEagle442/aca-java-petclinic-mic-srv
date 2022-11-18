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


@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.4.jar'

// Spring Cloud for Azure params required to get secrets from Key Vault.
// https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#basic-usage-3
// https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#advanced-usage
// https://github.com/ezYakaEagle442/spring-cloud-az-kv
// Use - instead of . in secret name. . isn’t supported in secret name. If your application have property name which contains ., 
// like spring.datasource.url, just replace . to - when save secret in Azure Key Vault. 
// For example: Save spring-datasource-url in Azure Key Vault. In your application, you can still use spring.datasource.url to retrieve property value.

/*
useless as no Service Principal is Used, ManagedIdentities are used
@secure()
param springCloudAzureClientId string
@secure()
param springCloudAzureClientSecret string
*/

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

@secure()
@description('The Application Insights Intrumention Key. see https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string')
param appInsightsInstrumentationKey string

@description('The Container Registry Username')
param registryUsr string

@secure()
@description('The Container Registry Password')
param registryPassword string

@description('The Container Registry URL')
param registryUrl string


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
  name: 'aca-hello-test'
  location: location
  properties: {
    managedEnvironmentId: corpManagedEnvironment.id 
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        allowInsecure: true
        external: true
        targetPort: 80
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
        transport: 'auto'
      }
      secrets: [
        {
          name: 'registrypassword'
          value: registryPassword
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
          env: [
            {
              name: 'SPRING_PROFILES_ACTIVE'
              value: 'docker'
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
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: 'hello-test'
          resources: {
            cpu: any(containerResourcesCpu)
            memory: containerResourcesMemory
          }
        }
      ]
      scale: {
        maxReplicas: 10
        minReplicas: 1
        rules: [
          {
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
            name: 'http-scale'
          }
        ]
      }
    }
  }
}

// output adminServerContainerAppIdentity string = AdminServerContainerApp.identity.principalId
output adminServerContainerAppOutboundIPAddresses array = AdminServerContainerApp.properties.outboundIPAddresses
output adminServerContainerAppLatestRevisionName string = AdminServerContainerApp.properties.latestRevisionName
output adminServerContainerAppLatestRevisionFqdn string = AdminServerContainerApp.properties.latestRevisionFqdn
output adminServerContainerAppIngressFqdn string = AdminServerContainerApp.properties.configuration.ingress.fqdn
output adminServerContainerAppConfigSecrets array = AdminServerContainerApp.properties.configuration.secrets
