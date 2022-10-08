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
    // https://docs.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cjava#configure-managed-identities
    type: 'SystemAssigned'
    //userAssignedIdentities: {}
  }
  properties: {
    managedEnvironmentId: corpManagedEnvironment.id 
    configuration: {
      activeRevisionsMode: 'Multiple'
      /*
      dapr: {
        appId: 'string'
        appPort: int
        appProtocol: 'string'
        enabled: bool
      }
      */
      ingress: {
        allowInsecure: true
        /*
        customDomains: [
          {
            bindingType: 'string'
            certificateId: 'string'
            name: 'string'
          }
        ]
        */
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
          /*
          The first command to execute within the container. Separate each command with a comma and a space as seen in the example. If you're using values that contain sensitive information like passwords in the command override field, it's recommended that you use a secure environment variable to get it into the container instead, and reference the container.
          
          args: [
            '/bin/bash, -c, echo hello; sleep 60'
          ]
          */
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
          image: imageNameAdminServer
          name: adminServerContainerAppName
          probes: [
            {
              failureThreshold: 5
              httpGet: {
                /*
                host: 'string'
                httpHeaders: [
                  {
                    name: 'string'
                    value: 'string'
                  }
                ]
                */
                path: '/manage/health/liveness' /* /actuator */
                port: 8081
                scheme: 'HTTP'
              }
              initialDelaySeconds: 30
              periodSeconds: 60
              successThreshold: 1
              /*
              tcpSocket: {
                host: 'string'
                port: int
              }
              */
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
              type: 'Liveness'
            }
            {
              failureThreshold: 5
              httpGet: {
                /*
                host: 'string'
                httpHeaders: [
                  {
                    name: 'string'
                    value: 'string'
                  }
                ]
                */
                path: '/manage/health/readiness' /* /actuator */
                port: 8081
                scheme: 'HTTP'
              }
              initialDelaySeconds: 30
              periodSeconds: 60
              successThreshold: 1
              /*
              tcpSocket: {
                host: 'string'
                port: int
              }
              */
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
              type: 'Readiness'
            }            
          ]
          resources: {
            cpu: any(containerResourcesCpu)
            memory: containerResourcesMemory
          }
          /*
          volumeMounts: [
            {
              mountPath: 'string'
              volumeName: 'string'
            }
          ]
          */
        }
      ]
      // revisionSuffix: 'string'
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
                concurrentRequests: 10
              }
            }
            name: 'http-scale'
          }
        ]
      }
      /*
      volumes: [
        {
          name: 'string'
          storageName: 'string'
          storageType: 'string'
        }
      ]
      */
    }
  }
}

output adminServerContainerAppIdentity string = AdminServerContainerApp.identity.principalId
output adminServerContainerAppOutboundIPAddresses array = AdminServerContainerApp.properties.outboundIPAddresses
output adminServerContainerAppLatestRevisionName string = AdminServerContainerApp.properties.latestRevisionName
output adminServerContainerAppLatestRevisionFqdn string = AdminServerContainerApp.properties.latestRevisionFqdn
output adminServerContainerAppIngressFqdn string = AdminServerContainerApp.properties.configuration.ingress.fqdn
output adminServerContainerAppConfigSecrets array = AdminServerContainerApp.properties.configuration.secrets

resource ApiGatewayContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: apiGatewayContainerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
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
            '["java", "-javaagent:/tmp/app/applicationinsights-agent-3.4.1.jar", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              terminationGracePeriodSeconds: 60
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
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
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
                concurrentRequests: 10
              }
            }
            name: 'http-scale'
          }
        ]
      }
    }
  }
}

output apiGatewayContainerAppIdentity string = ApiGatewayContainerApp.identity.principalId
output apiGatewayContainerAppOutboundIPAddresses array = ApiGatewayContainerApp.properties.outboundIPAddresses
output apiGatewayContainerAppLatestRevisionName string = ApiGatewayContainerApp.properties.latestRevisionName
output apiGatewayContainerAppLatestRevisionFqdn string = ApiGatewayContainerApp.properties.latestRevisionFqdn
output apiGatewayContainerAppIngressFqdn string = ApiGatewayContainerApp.properties.configuration.ingress.fqdn
output apiGatewayContainerAppConfigSecrets array = ApiGatewayContainerApp.properties.configuration.secrets

resource ConfigServerContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: configServerContainerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
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
          name: 'SPRING_CLOUD_AZURE_TENANT_ID'
          value: springCloudAzureTenantId
        } 
        {
          name: 'SPRING_CLOUD_AZURE_KEY_VAULT_ENDPOINT'
          value: springCloudAzureKeyVaultEndpoint
        }        
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:/tmp/app/applicationinsights-agent-3.4.1.jar", "org.springframework.boot.loader.JarLauncher", "--server.port=8888", "--spring.profiles.active=docker,mysql"]'
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
              terminationGracePeriodSeconds: 60
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
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
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
                concurrentRequests: 10
              }
            }
            name: 'http-scale'
          }
        ]
      }
    }
  }
}

output configServerContainerAppIdentity string = ConfigServerContainerApp.identity.principalId
output configServerContainerAppOutboundIPAddresses array = ConfigServerContainerApp.properties.outboundIPAddresses
output configServerContainerAppLatestRevisionName string = ConfigServerContainerApp.properties.latestRevisionName
output configServerContainerAppLatestRevisionFqdn string = ConfigServerContainerApp.properties.latestRevisionFqdn
output configServerContainerAppIngressFqdn string = ConfigServerContainerApp.properties.configuration.ingress.fqdn
output configServerContainerAppConfigSecrets array = ConfigServerContainerApp.properties.configuration.secrets


resource CustomersServiceContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: customersServiceContainerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
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
            '["java", "-javaagent:/tmp/app/applicationinsights-agent-3.4.1.jar", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              secretRef: springCloudAzureTenantId
            } 
            {
              name: 'SPRING_CLOUD_AZURE_KEY_VAULT_ENDPOINT'
              secretRef: springCloudAzureKeyVaultEndpoint
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
              terminationGracePeriodSeconds: 60
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
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
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
                concurrentRequests: 10
              }
            }
            name: 'http-scale'
          }
        ]
      }
    }
  }
}

output customersServiceContainerAppIdentity string = CustomersServiceContainerApp.identity.principalId
output customersServiceContainerAppOutboundIPAddresses array = CustomersServiceContainerApp.properties.outboundIPAddresses
output customersServiceContainerAppLatestRevisionName string = CustomersServiceContainerApp.properties.latestRevisionName
output customersServiceContainerAppLatestRevisionFqdn string = CustomersServiceContainerApp.properties.latestRevisionFqdn
output customersServiceContainerAppIngressFqdn string = CustomersServiceContainerApp.properties.configuration.ingress.fqdn
output customersServiceContainerAppConfigSecrets array = CustomersServiceContainerApp.properties.configuration.secrets


resource VetsServiceContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: vetsServiceContainerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
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
            '["java", "-javaagent:/tmp/app/applicationinsights-agent-3.4.1.jar", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              secretRef: springCloudAzureTenantId
            } 
            {
              name: 'SPRING_CLOUD_AZURE_KEY_VAULT_ENDPOINT'
              secretRef: springCloudAzureKeyVaultEndpoint
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
              terminationGracePeriodSeconds: 60
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
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
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
                concurrentRequests: 10
              }
            }
            name: 'http-scale'
          }
        ]
      }
    }
  }
}

output vetsServiceContainerAppNameContainerAppIdentity string = VetsServiceContainerApp.identity.principalId
output vetsServiceContainerAppOutboundIPAddresses array = VetsServiceContainerApp.properties.outboundIPAddresses
output vetsServiceContainerAppLatestRevisionName string = VetsServiceContainerApp.properties.latestRevisionName
output vetsServiceContainerAppLatestRevisionFqdn string = VetsServiceContainerApp.properties.latestRevisionFqdn
output vetsServiceContainerAppIngressFqdn string = VetsServiceContainerApp.properties.configuration.ingress.fqdn
output vetsServiceContainerAppConfigSecrets array = VetsServiceContainerApp.properties.configuration.secrets


resource VisitsServiceContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: visitsServiceContainerAppName
  location: location
  identity: {
    type: 'SystemAssigned'
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
            '["java", "-javaagent:/tmp/app/applicationinsights-agent-3.4.1.jar", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              secretRef: springCloudAzureTenantId
            } 
            {
              name: 'SPRING_CLOUD_AZURE_KEY_VAULT_ENDPOINT'
              secretRef: springCloudAzureKeyVaultEndpoint
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
              terminationGracePeriodSeconds: 60
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
              terminationGracePeriodSeconds: 60
              timeoutSeconds: 3
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
                concurrentRequests: 10
              }
            }
            name: 'http-scale'
          }
        ]
      }
    }
  }
}

output visitsServiceContainerAppIdentity string = VisitsServiceContainerApp.identity.principalId
output visitsServiceContainerAppOutboundIPAddresses array = VisitsServiceContainerApp.properties.outboundIPAddresses
output visitsServiceContainerAppLatestRevisionName string = VisitsServiceContainerApp.properties.latestRevisionName
output visitsServiceContainerAppLatestRevisionFqdn string = VisitsServiceContainerApp.properties.latestRevisionFqdn
output visitsServiceContainerAppIngressFqdn string = VisitsServiceContainerApp.properties.configuration.ingress.fqdn
output visitsServiceContainerAppConfigSecrets array = VisitsServiceContainerApp.properties.configuration.secrets
