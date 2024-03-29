// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

param appInsightsName string = 'appi-${appName}'

@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.10.jar'

@description('The applicationinsights config file location')
param applicationInsightsConfigFile string = 'BOOT-INF/classes/applicationinsights.json'

@secure()
@description('The Azure Active Directory tenant ID that should be used by Key Vault in the Spring Config')
param springCloudAzureTenantId string


@maxLength(24)
@description('The name of the KV, must be UNIQUE. A vault name must be between 3-24 alphanumeric characters.')
param kvName string = 'kv-${appName}'

@description('The Azure Key Vault EndPoint that should be used by Key Vault in the Spring Config. Ex: https://<key-vault-name>.vault.azure.net')
param springCloudAzureKeyVaultEndpoint string = 'https://kv-${appName}.vault.azure.net'

// Spring Cloud for Azure params required to get secrets from Key Vault.
// https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#basic-usage-3
// https://microsoft.github.io/spring-cloud-azure/current/reference/html/index.html#advanced-usage
// https://github.com/ezYakaEagle442/spring-cloud-az-kv
// Use - instead of . in secret name. . isn’t supported in secret name. If your application have property name which contains ., 
// like spring.datasource.url, just replace . to - when save secret in Azure Key Vault. 
// For example: Save spring-datasource-url in Azure Key Vault. In your application, you can still use spring.datasource.url to retrieve property value.

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

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-api-gateway:{{ github.sha }}')
param imageNameApiGateway string

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-${appName}-config-server'

@description('The Azure Container App instance name for api-gateway')
param apiGatewayContainerAppName string = 'aca-${appName}-api-gateway'
  
@description('The Azure Container App instance name for customers-service')
param customersServiceContainerAppName string = 'aca-${appName}-customers-service'

@description('The Azure Container App instance name for vets-service')
param vetsServiceContainerAppName string = 'aca-${appName}-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppName string = 'aca-${appName}-visits-service'
  
@description('The api-gateway Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param apiGatewayAppIdentityName string = 'id-aca-${appName}-petclinic-api-gateway-dev-${location}-101'

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-10-01' existing = {
  name: azureContainerAppEnvName
}

resource apiGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: apiGatewayAppIdentityName
}

resource ConfigServerContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: configServerContainerAppName
}

resource CustomersServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: customersServiceContainerAppName
}

resource VetsServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: vetsServiceContainerAppName
}

resource VisitsServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' existing = {
  name: visitsServiceContainerAppName
}

resource ACR 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' existing = {
  name: acrName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsName
}

resource ApiGatewayContainerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: apiGatewayContainerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${apiGatewayIdentity.id}': {}  
    }    
  }
  properties: {
    managedEnvironmentId: corpManagedEnvironment.id 
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        allowInsecure: true
        external: true
        targetPort: 8080
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
          server: ACR.properties.loginServer
          identity: apiGatewayIdentity.id
          //username: registryUsr
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
        {
          name: 'appinscon'
          value: appInsights.properties.ConnectionString
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
            'java', '-javaagent:${applicationInsightsAgentJarFilePath}', 'org.springframework.boot.loader.JarLauncher', '--server.port=8080', '-Xms512m -Xmx1024m', '--spring.cloud.azure.keyvault.secret.enabled=false', '--spring.cloud.azure.keyvault.secret.property-source-enabled=false'
          ]
          env: [
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
            {
              name: 'CFG_SRV_URL'
              value: ConfigServerContainerApp.properties.configuration.ingress.fqdn
            }
            {
              name: 'CUSTOMERS_SVC_URL'
              value: CustomersServiceContainerApp.properties.configuration.ingress.fqdn
            }    
            {
              name: 'VETS_SVC_URL'
              value: VetsServiceContainerApp.properties.configuration.ingress.fqdn
            } 
            {
              name: 'VISITS_SVC_URL'
              value: VisitsServiceContainerApp.properties.configuration.ingress.fqdn
            }
            {
              name: 'ACA_ENV_DNS_SUFFIX'
              value: corpManagedEnvironment.properties.defaultDomain
            }
            {
              name: 'CUSTOMERS_SVC_APP_NAME'
              value: customersServiceContainerAppName
            }
            {
              name: 'VISITS_SVC_APP_NAME'
              value: visitsServiceContainerAppName
            }
            {
              // https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-standalone-config#configuration-file-path
              name: 'APPLICATIONINSIGHTS_CONFIGURATION_FILE'
              value: applicationInsightsConfigFile
            }                                                  
          ]
          image: imageNameApiGateway
          name: apiGatewayContainerAppName
          probes: [
            {
              failureThreshold: 5
              httpGet: {
                path: '/manage/health/liveness' /* /actuator */
                port: 8081
                scheme: 'HTTP'
              }
              initialDelaySeconds: 30
              periodSeconds: 60
              successThreshold: 1 
              timeoutSeconds: 30
              type: 'Liveness'
            }
            {
              failureThreshold: 5
              httpGet: {
                path: '/manage/health/readiness' /* /actuator */
                port: 8081
                scheme: 'HTTP'
              }
              initialDelaySeconds: 30
              periodSeconds: 60
              successThreshold: 1
              timeoutSeconds: 30
              type: 'Readiness'
            } 
            /*
            {
              failureThreshold: 5
              httpGet: {
                path: '/manage/info'
                port: 8081
                scheme: 'HTTP'
              }
              initialDelaySeconds: 60
              periodSeconds: 60
              successThreshold: 1
              timeoutSeconds: 3
              type: 'Startup'             
            }
            */
          ]
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
  dependsOn:  [
    ConfigServerContainerApp
    CustomersServiceContainerApp
    VetsServiceContainerApp
    VisitsServiceContainerApp
  ]
}

output apiGatewayContainerAppoutboundIpAddresses array = ApiGatewayContainerApp.properties.outboundIpAddresses
output apiGatewayContainerAppLatestRevisionName string = ApiGatewayContainerApp.properties.latestRevisionName
output apiGatewayContainerAppLatestRevisionFqdn string = ApiGatewayContainerApp.properties.latestRevisionFqdn
output apiGatewayContainerAppIngressFqdn string = ApiGatewayContainerApp.properties.configuration.ingress.fqdn
output apiGatewayContainerAppConfigSecrets array = ApiGatewayContainerApp.properties.configuration.secrets

output CFG_SRV_URL string = ConfigServerContainerApp.properties.configuration.ingress.fqdn
output CUSTOMERS_SVC_URL string = CustomersServiceContainerApp.properties.configuration.ingress.fqdn
output VETS_SVC_URL string = VetsServiceContainerApp.properties.configuration.ingress.fqdn
output VISITS_SVC_URL string = VisitsServiceContainerApp.properties.configuration.ingress.fqdn
