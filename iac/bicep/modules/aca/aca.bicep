// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

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
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.10.jar'

@description('The applicationinsights config file location')
param applicationInsightsConfigFile string = 'BOOT-INF/classes/applicationinsights.json'

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

@description('The Container Registry URL')
param registryUrl string

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

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-admin-server'

@description('The Azure Container App instance name for config-server')
param configServerContainerAppName string = 'aca-config-server'

@description('The Azure Container App instance name for customers-service')
param customersServiceContainerAppName string = 'aca-customers-service'

@description('The Azure Container App instance name for vets-service')
param vetsServiceContainerAppName string = 'aca-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppName string = 'aca-visits-service'

@description('The admin-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param adminServerAppIdentityName string = 'id-aca-${appName}-petclinic-admin-server-dev-${location}-101'

@description('The config-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param configServerAppIdentityName string = 'id-aca-${appName}-petclinic-config-server-dev-${location}-101'

@description('The api-gateway Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param apiGatewayAppIdentityName string = 'id-aca-${appName}-petclinic-api-gateway-dev-${location}-101'

@description('The customers-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param customersServiceAppIdentityName string = 'id-aca-${appName}-petclinic-customers-service-dev-${location}-101'

@description('The vets-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param vetsServiceAppIdentityName string = 'id-aca-${appName}-petclinic-vets-service-dev-${location}-101'

@description('The visits-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param visitsServiceAppIdentityName string = 'id-aca-${appName}-petclinic-visits-service-dev-${location}-101'

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-06-01-preview' existing = {
  name: azureContainerAppEnvName
}

resource configServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: configServerAppIdentityName
}

resource apiGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: apiGatewayAppIdentityName
}

resource customersServicedentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: customersServiceAppIdentityName
}

resource vetsServiceAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: vetsServiceAppIdentityName
}

resource visitsServiceIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: visitsServiceAppIdentityName
}

resource adminServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview'existing = {
  name: adminServerAppIdentityName
}

resource ConfigServerContainerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: configServerContainerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${configServerIdentity.id}': {}
    }    
  }
  properties: {
    managedEnvironmentId: corpManagedEnvironment.id 
    configuration: {
      activeRevisionsMode: 'Multiple'
      ingress: {
        allowInsecure: true
        external: true
        targetPort: 8888
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
          server: registryUrl
          identity: configServerIdentity.id
          //username: registryUsr
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
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
            'java', '-javaagent:"${applicationInsightsAgentJarFilePath}"', 'org.springframework.boot.loader.JarLauncher', '--server.port=8888', '-Xms512m -Xmx1024m'
          ]
          env: [
            {
              // https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              secretRef: 'appinscon'
            }
            {
              // https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-standalone-config#configuration-file-path
              name: 'APPLICATIONINSIGHTS_CONFIGURATION_FILE'
              value: applicationInsightsConfigFile
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
          image: imageNameConfigServer
          name: configServerContainerAppName
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
              timeoutSeconds: 3
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
              timeoutSeconds: 3
              type: 'Readiness'
            }
            /*
            {
              failureThreshold: 5
              httpGet: {
                path: '/manage/health/XXX'
                port: 8081
                scheme: 'HTTP'
              }
              initialDelaySeconds: 30
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
}

//output configServerContainerAppIdentity string = ConfigServerContainerApp.identity.principalId
output configServerContainerAppoutboundIpAddresses array = ConfigServerContainerApp.properties.outboundIpAddresses
output configServerContainerAppLatestRevisionName string = ConfigServerContainerApp.properties.latestRevisionName
output configServerContainerAppLatestRevisionFqdn string = ConfigServerContainerApp.properties.latestRevisionFqdn
output configServerContainerAppIngressFqdn string = ConfigServerContainerApp.properties.configuration.ingress.fqdn
output configServerContainerAppConfigSecrets array = ConfigServerContainerApp.properties.configuration.secrets


resource CustomersServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: customersServiceContainerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${customersServicedentity.id}': {}
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
          server: registryUrl
          identity: customersServicedentity.id
          //username: registryUsr
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
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
            'java', '-javaagent:"${applicationInsightsAgentJarFilePath}"', 'org.springframework.boot.loader.JarLauncher', '--server.port=8080', '--spring.profiles.active=docker,mysql', '-Xms512m -Xmx1024m'
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
              // https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-standalone-config#configuration-file-path
              name: 'APPLICATIONINSIGHTS_CONFIGURATION_FILE'
              value: applicationInsightsConfigFile
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
              name: 'CUSTOMERS_SVC_APP_IDENTITY_CLIENT_ID'
              value: customersServicedentity.properties.clientId
            }   
          ]
          image: imageNameCustomersService
          name: customersServiceContainerAppName
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
              /*
              auth: [
                {
                  secretRef: 'string'
                  triggerParameter: 'string'
                }
              ]
              */
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
    VetsServiceContainerApp
    VisitsServiceContainerApp
  ]  
}

//output customersServiceContainerAppIdentity string = CustomersServiceContainerApp.identity.principalId
output customersServiceContainerAppoutboundIpAddresses array = CustomersServiceContainerApp.properties.outboundIpAddresses
output customersServiceContainerAppLatestRevisionName string = CustomersServiceContainerApp.properties.latestRevisionName
output customersServiceContainerAppLatestRevisionFqdn string = CustomersServiceContainerApp.properties.latestRevisionFqdn
output customersServiceContainerAppIngressFqdn string = CustomersServiceContainerApp.properties.configuration.ingress.fqdn
output customersServiceContainerAppConfigSecrets array = CustomersServiceContainerApp.properties.configuration.secrets

resource VetsServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: vetsServiceContainerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${vetsServiceAppIdentity.id}': {}
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
          server: registryUrl
          identity: vetsServiceAppIdentity.id
          //username: registryUsr
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
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
            'java', '-javaagent:"${applicationInsightsAgentJarFilePath}"', 'org.springframework.boot.loader.JarLauncher', '--server.port=8080', '--spring.profiles.active=docker,mysql', '-Xms512m -Xmx1024m'
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
              // https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-standalone-config#configuration-file-path
              name: 'APPLICATIONINSIGHTS_CONFIGURATION_FILE'
              value: applicationInsightsConfigFile
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
              name: 'VETS_SVC_APP_IDENTITY_CLIENT_ID'
              value: vetsServiceAppIdentity.properties.clientId
            }                               
          ]
          image: imageNameVetsService
          name: vetsServiceContainerAppName
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
}

//output vetsServiceContainerAppNameContainerAppIdentity string = VetsServiceContainerApp.identity.principalId
output vetsServiceContainerAppoutboundIpAddresses array = VetsServiceContainerApp.properties.outboundIpAddresses
output vetsServiceContainerAppLatestRevisionName string = VetsServiceContainerApp.properties.latestRevisionName
output vetsServiceContainerAppLatestRevisionFqdn string = VetsServiceContainerApp.properties.latestRevisionFqdn
output vetsServiceContainerAppIngressFqdn string = VetsServiceContainerApp.properties.configuration.ingress.fqdn
output vetsServiceContainerAppConfigSecrets array = VetsServiceContainerApp.properties.configuration.secrets

resource VisitsServiceContainerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: visitsServiceContainerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${visitsServiceIdentity.id}': {}
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
          server: registryUrl
          identity: visitsServiceIdentity.id
          //username: registryUsr
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
        // https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string
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
            'java', '-javaagent:"${applicationInsightsAgentJarFilePath}"', 'org.springframework.boot.loader.JarLauncher', '--server.port=8080', '--spring.profiles.active=docker,mysql', '-Xms512m -Xmx1024m'
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
              // https://learn.microsoft.com/en-us/azure/azure-monitor/app/java-standalone-config#configuration-file-path
              name: 'APPLICATIONINSIGHTS_CONFIGURATION_FILE'
              value: applicationInsightsConfigFile
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
              name: 'VISITS_SVC_APP_IDENTITY_CLIENT_ID'
              value: visitsServiceIdentity.properties.clientId
            }            
          ]
          image: imageNameVisitsService
          name: visitsServiceContainerAppName
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
}

//output visitsServiceContainerAppIdentity string = VisitsServiceContainerApp.identity.principalId
output visitsServiceContainerAppoutboundIpAddresses array = VisitsServiceContainerApp.properties.outboundIpAddresses
output visitsServiceContainerAppLatestRevisionName string = VisitsServiceContainerApp.properties.latestRevisionName
output visitsServiceContainerAppLatestRevisionFqdn string = VisitsServiceContainerApp.properties.latestRevisionFqdn
output visitsServiceContainerAppIngressFqdn string = VisitsServiceContainerApp.properties.configuration.ingress.fqdn
output visitsServiceContainerAppConfigSecrets array = VisitsServiceContainerApp.properties.configuration.secrets
