// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

// https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/check-name-availability
@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

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

@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.3.0.jar'

@secure()
@description('The Application Insights Intrumention Key. see https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-in-process-agent#set-the-application-insights-connection-string')
param appInsightsInstrumentationKey string

@description('The GitHub Action Settings / Repo URL')
param ghaSettingsCfgRepoUrl string = 'https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv'

@description('The GitHub Action Settings Configuration / Registry User Name')
param ghaSettingsCfgRegistryUserName string

@description('The GitHub Action Settings Configuration / Registry Password')
@secure()
param ghaSettingsCfgRegistryPassword string

@description('The GitHub Action Settings Configuration / Registry URL')
param ghaSettingsCfgRegistryUrl string

param revisionName string = 'poc-aca-101'

@description('The GitHub branch name')
param ghaGitBranchName string = 'main'

@description('The GitHub Action Settings Configuration / Azure Credentials / Client Id')
param ghaSettingsCfgCredClientId string

@description('The GitHub Action Settings Configuration / Azure Credentials / Client Secret')
param ghaSettingsCfgCredClientSecret string

@description('The GitHub Action Settings Configuration / Docker file Path for admin-server Azure Container App ')
param ghaSettingsCfgDockerFilePathAdminServer string = '../../docker/petclinic-admin-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for discovery-server Azure Container App ')
param ghaSettingsCfgDockerFilePathDiscoveryServer string = '../../docker/petclinic-discovery-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for api-gateway Azure Container App ')
param ghaSettingsCfgDockerFilePathApiGateway string = '../../docker/petclinic-api-gateway/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for  config-server Azure Container App ')
param ghaSettingsCfgDockerFilePathConfigserver string = '../../docker/petclinic-config-server/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for customers-service Azure Container App ')
param ghaSettingsCfgDockerFilePathCustomersService string = '../../docker/petclinic-customers-service/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for vets-service Azure Container App ')
param ghaSettingsCfgDockerFilePathVetsService string = '../../docker/petclinic-vets-service/Dockerfile'

@description('The GitHub Action Settings Configuration / Docker file Path for visits-service Azure Container App ')
param ghaSettingsCfgDockerFilePathVisitsService string = '../../docker/petclinic-visits-service/Dockerfile'


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
            revisionName: revisionName
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          passwordSecretRef: 'registrypassword'
          server: ghaSettingsCfgRegistryUrl
          username: ghaSettingsCfgRegistryUserName
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
          name: 'SPRING-CLOUD-AZURE-TENANT-ID'
          value: springCloudAzureTenantId
        }
        {
          name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
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
            '["java", "-javaagent:${applicationInsightsAgentJarFilePath}", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              name: 'SPRING-CLOUD-AZURE-TENANT-ID'
              secretRef: 'SPRING-CLOUD-AZURE-TENANT-ID'
            }   
            {
              name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
              secretRef: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
            }                                 
          ]
          image: '${acrName}/${adminServerContainerAppName}:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            cpu: json('0.25') // 250m
            memory: json('0.5') // Gi
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

output AdminServerContainerAppIdentity string = AdminServerContainerApp.identity.principalId
output AdminServerContainerAppOutboundIPAddresses array = AdminServerContainerApp.properties.outboundIPAddresses
output AdminServerContainerAppLatestRevisionName string = AdminServerContainerApp.properties.latestRevisionName
output AdminServerContainerAppLatestRevisionFqdn string = AdminServerContainerApp.properties.latestRevisionFqdn
output AdminServerContainerAppIngressFqdn string = AdminServerContainerApp.properties.configuration.ingress.fqdn
output AdminServerContainerAppConfigSecrets array = AdminServerContainerApp.properties.configuration.secrets

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
            revisionName: revisionName
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          passwordSecretRef: 'registrypassword'
          server: ghaSettingsCfgRegistryUrl
          username: ghaSettingsCfgRegistryUserName
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
          name: 'SPRING-CLOUD-AZURE-TENANT-ID'
          value: springCloudAzureTenantId
        }
        {
          name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
          value: springCloudAzureKeyVaultEndpoint
        }            
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:${applicationInsightsAgentJarFilePath}", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              name: 'SPRING-CLOUD-AZURE-TENANT-ID'
              secretRef: 'SPRING-CLOUD-AZURE-TENANT-ID'
            }   
            {
              name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
              secretRef: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
            }                    
          ]
          image: '${acrName}/${apiGatewayContainerAppName}:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            cpu: json('0.25') // 250m
            memory: json('0.5') // Gi
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
            revisionName: revisionName
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          passwordSecretRef: 'registrypassword'
          server: ghaSettingsCfgRegistryUrl
          username: ghaSettingsCfgRegistryUserName
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
          name: 'SPRING-CLOUD-AZURE-TENANT-ID'
          value: springCloudAzureTenantId
        } 
        {
          name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
          value: springCloudAzureKeyVaultEndpoint
        }        
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:${applicationInsightsAgentJarFilePath}", "org.springframework.boot.loader.JarLauncher", "--server.port=8888", "--spring.profiles.active=docker,mysql"]'
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
              name: 'SPRING-CLOUD-AZURE-TENANT-ID'
              secretRef: 'SPRING-CLOUD-AZURE-TENANT-ID'
            }
            {
              name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
              secretRef: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
            }
          ]
          image: '${acrName}/${configServerContainerAppName}:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            cpu: json('0.25') // 250m
            memory: json('0.5') // Gi
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

output configServerContainerAppContainerAppIdentity string = ConfigServerContainerApp.identity.principalId
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
            revisionName: revisionName
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          passwordSecretRef: 'registrypassword'
          server: ghaSettingsCfgRegistryUrl
          username: ghaSettingsCfgRegistryUserName
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
          name: 'SPRING-CLOUD-AZURE-TENANT-ID'
          value: springCloudAzureTenantId
        } 
        {
          name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
          value: springCloudAzureKeyVaultEndpoint
        }
        {
          name: 'SPRING-DATASOURCE-USERNAME'
          value: springDataSourceUsr
        }
        {
          name: 'SPRING-DATASOURCE-PASSWORD'
          value: springDataSourcePwd
        } 
        {
          name: 'SPRING-DATASOURCE-URL'
          value: springDataSourceUrl
        }                              
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:${applicationInsightsAgentJarFilePath}", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              name: 'SPRING-CLOUD-AZURE-TENANT-ID'
              secretRef: springCloudAzureTenantId
            } 
            {
              name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
              secretRef: springCloudAzureKeyVaultEndpoint
            }
            {
              name: 'SPRING-DATASOURCE-USERNAME'
              secretRef: springDataSourceUsr
            }
            {
              name: 'SPRING-DATASOURCE-PASSWORD'
              secretRef: springDataSourcePwd
            } 
            {
              name: 'SPRING-DATASOURCE-URL'
              secretRef: springDataSourceUrl
            }                          
          ]
          image: '${acrName}/${customersServiceContainerAppName}:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            cpu: json('0.25') // 250m
            memory: json('0.5') // Gi
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
            revisionName: revisionName
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          passwordSecretRef: 'registrypassword'
          server: ghaSettingsCfgRegistryUrl
          username: ghaSettingsCfgRegistryUserName
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
          name: 'SPRING-CLOUD-AZURE-TENANT-ID'
          value: springCloudAzureTenantId
        } 
        {
          name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
          value: springCloudAzureKeyVaultEndpoint
        }
        {
          name: 'SPRING-DATASOURCE-USERNAME'
          value: springDataSourceUsr
        }
        {
          name: 'SPRING-DATASOURCE-PASSWORD'
          value: springDataSourcePwd
        } 
        {
          name: 'SPRING-DATASOURCE-URL'
          value: springDataSourceUrl
        }               
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:${applicationInsightsAgentJarFilePath}", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              name: 'SPRING-CLOUD-AZURE-TENANT-ID'
              secretRef: springCloudAzureTenantId
            } 
            {
              name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
              secretRef: springCloudAzureKeyVaultEndpoint
            }
            {
              name: 'SPRING-DATASOURCE-USERNAME'
              secretRef: springDataSourceUsr
            }
            {
              name: 'SPRING-DATASOURCE-PASSWORD'
              secretRef: springDataSourcePwd
            } 
            {
              name: 'SPRING-DATASOURCE-URL'
              secretRef: springDataSourceUrl
            }                      
          ]
          image: '${acrName}/${vetsServiceContainerAppName}:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            cpu: json('0.25') // 250m
            memory: json('0.5') // Gi
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
            revisionName: revisionName
            weight: 100
          }
        ]
        transport: 'auto'
      }
      registries: [
        {
          passwordSecretRef: 'registrypassword'
          server: ghaSettingsCfgRegistryUrl
          username: ghaSettingsCfgRegistryUserName
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
          name: 'SPRING-CLOUD-AZURE-TENANT-ID'
          value: springCloudAzureTenantId
        } 
        {
          name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
          value: springCloudAzureKeyVaultEndpoint
        }
        {
          name: 'SPRING-DATASOURCE-USERNAME'
          value: springDataSourceUsr
        }
        {
          name: 'SPRING-DATASOURCE-PASSWORD'
          value: springDataSourcePwd
        } 
        {
          name: 'SPRING-DATASOURCE-URL'
          value: springDataSourceUrl
        }          
      ]
    }
    template: {
      containers: [
        {
          command: [
            '["java", "-javaagent:${applicationInsightsAgentJarFilePath}", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
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
              name: 'SPRING-CLOUD-AZURE-TENANT-ID'
              secretRef: springCloudAzureTenantId
            } 
            {
              name: 'SPRING-CLOUD-AZURE-KEY-VAULT-ENDPOINT'
              secretRef: springCloudAzureKeyVaultEndpoint
            }
            {
              name: 'SPRING-DATASOURCE-USERNAME'
              secretRef: springDataSourceUsr
            }
            {
              name: 'SPRING-DATASOURCE-PASSWORD'
              secretRef: springDataSourcePwd
            } 
            {
              name: 'SPRING-DATASOURCE-URL'
              secretRef: springDataSourceUrl
            }                           
          ]
          image: '${acrName}/${visitsServiceContainerAppName}:latest' // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
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
            cpu: json('0.25') // 250m
            memory: json('0.5') // Gi
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


resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' existing = {
  name: logAnalyticsWorkspaceName
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsDgsAdminServer 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${adminServerContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: AdminServerContainerApp
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsDgsApiGW 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${apiGatewayContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: ApiGatewayContainerApp
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsDgsCfgServer 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${configServerContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: ConfigServerContainerApp
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}


// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsDgsCustomersService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${customersServiceContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: CustomersServiceContainerApp
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsDgsVetsService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${vetsServiceContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: VetsServiceContainerApp
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsDgsVisistsService 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'dgs-${appName}-send-${visitsServiceContainerAppName}-logs-and-metrics-to-log-analytics'
  scope: VisitsServiceContainerApp
  properties: {
    logAnalyticsDestinationType: 'AzureDiagnostics'
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'ApplicationConsole'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'SystemLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
      {
        category: 'IngressLogs'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }    
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          days: 7
          enabled: true
        }
      }
    ]
  }
}


resource githubActionSettingsCustomers 'Microsoft.App/containerApps/sourcecontrols@2022-03-01' = {
  name: 'aca-gha-set-customers-svc'
  parent: CustomersServiceContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      dockerfilePath: ghaSettingsCfgDockerFilePathCustomersService
      os: 'Linux'
      registryInfo: {
        registryPassword: ghaSettingsCfgRegistryPassword
        registryUrl: ghaSettingsCfgRegistryUrl
        registryUserName: ghaSettingsCfgRegistryUserName
      }
      publishType: ghaSettingsCfgPublishType
    }
    repoUrl: ghaSettingsCfgRepoUrl
  }
}

resource githubActionSettingsVets 'Microsoft.App/containerApps/sourcecontrols@2022-03-01' = {
  name: 'aca-gha-set-vets-svc'
  parent: VetsServiceContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      dockerfilePath: ghaSettingsCfgDockerFilePathVetsService
      os: 'Linux'
      registryInfo: {
        registryPassword: ghaSettingsCfgRegistryPassword
        registryUrl: ghaSettingsCfgRegistryUrl
        registryUserName: ghaSettingsCfgRegistryUserName
      }
      publishType: ghaSettingsCfgPublishType
    }
    repoUrl: ghaSettingsCfgRepoUrl
  }
}

resource githubActionSettings 'Microsoft.App/containerApps/sourcecontrols@2022-03-01' = {
  name: 'aca-gha-set-visits-svc'
  parent: VisitsServiceContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      dockerfilePath: ghaSettingsCfgDockerFilePathVisitsService
      os: 'Linux'
      registryInfo: {
        registryPassword: ghaSettingsCfgRegistryPassword
        registryUrl: ghaSettingsCfgRegistryUrl
        registryUserName: ghaSettingsCfgRegistryUserName
      }
      publishType: ghaSettingsCfgPublishType
    }
    repoUrl: ghaSettingsCfgRepoUrl
  }
}
