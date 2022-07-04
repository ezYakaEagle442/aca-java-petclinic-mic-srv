// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

// https://docs.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cjava#configure-managed-identities
@description('The Azure Active Directory tenant ID that should be used to store the GH Actions SPN credentials and to manage Azure Container Apps Identities.')
param tenantId string = subscription().tenantId

param subscriptionId string = subscription().id

@description('The Log Analytics workspace name used by Azure Container Apps')
param logAnalyticsWorkspaceName string = 'log-aca-${appName}'

@allowed([
  'log-analytics'
])
param logDestination string = 'log-analytics'

param appInsightsName string = 'appi-${appName}'
param appInsightsDiagnosticSettingsName string = 'dgs-${appName}-send-logs-and-metrics-to-log-analytics'

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
param vetsServiceContainerAppEnvName string = 'aca-env-${appName}-vets-service'

@description('The Azure Container App instance name for visits-service')
param visitsServiceContainerAppEnvName string = 'aca-env-${appName}-visits-service'

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

param vnetName string = 'vnet-azure-container-apps'

param zoneRedundant bool = false

param revisionName string = 'poc-aca-101'

@description('The GitHub Action Settings name for XXX Azure Container App instance.')
param ghaSettingsName string = 'aca-gha-set-xxx'

@description('The GitHub branch name')
param ghaGitBranchName string = 'main'

@description('The GitHub Action Settings Configuration / Azure Credentials / Client Id')
param ghaSettingsCfgCredClientId string

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


@description('The GitHub Action Settings Configuration / Publish Type')
param ghaSettingsCfgPublishType string = 'xxx'

@description('The GitHub Action Settings Configuration / Registry User Name')
param ghaSettingsCfgRegistryUserName string

@description('The GitHub Action Settings Configuration / Registry Password')
param ghaSettingsCfgRegistryPassword string

@description('The GitHub Action Settings Configuration / Registry URL')
param ghaSettingsCfgRegistryUrl string

@description('The GitHub Action Settings Configuration / Runtime Stack')
param ghaSettingsCfgRegistryRuntimeStack string = 'xxx'

@description('The GitHub Action Settings Configuration / Runtime Version')
param ghaSettingsCfgRegistryRuntimeVersion string = 'xxx'

@description('The GitHub Action Settings / Repo URL')
param ghaSettingsCfgRepoUrl string = 'https://github.com/ezYakaEagle442/aca-java-petclinic-mic-srv'

// https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/workspaces?tabs=bicep
resource logAnalyticsWorkspace  'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: any({
    retentionInDays: 30
    features: {
      searchVersion: 1
    }
    sku: {
      name: 'PerGB2018'
      /*
      Pricing tier: PerGB2018 or legacy tiers (Free, Standalone, PerNode, Standard or Premium) which are not available to all customers."allowedValues": [
        "pergb2018",
        "Free",
        "Standalone",
        "PerNode",
        "Standard",
        "Premium"
        */
    }
  })
}
output logAnalyticsWorkspaceResourceId string = logAnalyticsWorkspace.id
output logAnalyticsWorkspaceCustomerId string = logAnalyticsWorkspace.properties.customerId

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/components?tabs=bicep
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: { 
    Application_Type: 'web'
  }
}
output appInsightsId string = appInsights.id
output appInsightsConnectionString string = appInsights.properties.ConnectionString
output appInsightsInstrumentationKey string = appInsights.properties.InstrumentationKey

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing =  {
  name: vnetName
}

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' = {
  name: azureContainerAppEnvName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: logDestination
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
      zoneRedundant: zoneRedundant
    }
    
    daprAIInstrumentationKey: appInsights.properties.InstrumentationKey
    vnetConfiguration: {
      // The Docker bridge network address represents the default docker0 bridge network address present in all Docker installations. While docker0 bridge is not used by AKS clusters or the pods themselves, you must set this address to continue to support scenarios such as docker build within the AKS cluster. It is required to select a CIDR for the Docker bridge network address because otherwise Docker will pick a subnet automatically, which could conflict with other CIDRs. You must pick an address space that does not collide with the rest of the CIDRs on your networks, including the cluster's service CIDR and pod CIDR. Default of 172.17.0.1/16. You can reuse this range across different AKS clusters.
      // dockerBridgeCidr: '10.42.0.1/16'
      infrastructureSubnetId: vnet.properties.subnets[0].id
      internal: false // Boolean indicating the environment only has an internal load balancer. These environments do not have a public static IP resource. They must provide runtimeSubnetId and infrastructureSubnetId if enabling this property
      platformReservedCidr: vnet.properties.subnets[0].properties.addressPrefix
      platformReservedDnsIP: vnet.properties.dhcpOptions.dnsServers[0]
      runtimeSubnetId: vnet.properties.subnets[1].id
    }
  }
}
output corpManagedEnvironmentId string = corpManagedEnvironment.id 
output defaultDomain string = corpManagedEnvironment.properties.defaultDomain

resource xxxContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: xxxContainerApp
  location: location
  managedEnvironmentId: corpManagedEnvironment.id 
  identity: {
    // https://docs.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cjava#configure-managed-identities
    type: 'SystemAssigned'
    //userAssignedIdentities: {}
  }
  properties: {
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
        targetPort: 80
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
          passwordSecretRef: 'container-registry-connection-string'
          server: 'string'
          username: 'string'
        }
      ]
      secrets: [
        {
          name: 'container-registry-connection-string'
          value: XXX
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
            'ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher", "--server.port=8080", "--spring.profiles.active=docker,mysql"]'
          ]
          env: [
            {
              name: 'SPRING_PROFILES_ACTIVE'
              value: 'docker,mysql'
              //secretRef: 'string'
            }
          ]
          image: xxx // Tagged with GitHub commit ID (SHA), ex: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: xxx
          probes: [
            {
              failureThreshold: 5
              httpGet: {
                host: 'string'
                httpHeaders: [
                  {
                    name: 'string'
                    value: 'string'
                  }
                ]
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
              failureThreshold: int
              httpGet: {
                host: 'string'
                httpHeaders: [
                  {
                    name: 'string'
                    value: 'string'
                  }
                ]
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
            cpu: json('0.1') //100m
            memory: '180Mb' // Gi
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

output xxxContainerAppIdentity string = xxxContainerApp.identity.principalId
output xxxContainerAppOutboundIPAddresses array = xxxContainerApp.properties.outboundIPAddresses
output xxxContainerAppLatestRevisionName string = xxxContainerApp.properties.latestRevisionName
output xxxContainerAppLatestRevisionFqdn string = xxxContainerApp.properties.latestRevisionFqdn
output xxxContainerAppIngressFqdn string = xxxContainerApp.properties.configuration.ingress.fqdn
output xxxContainerAppConfigSecrets array = xxxContainerApp.properties.configuration.secrets

resource githubActionSettings 'Microsoft.App/containerApps/sourcecontrols@2022-03-01' = {
  name: 'xxxGitHubActionSettings'
  parent: xxxContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      dockerfilePath: ghaSettingsCfgDockerFilePathXXX // './docker/xxx/Dockerfile'
      os: 'Linux'
      publishType: ghaSettingsCfgPublishType
      registryInfo: {
        registryPassword: ghaSettingsCfgRegistryPassword
        registryUrl: ghaSettingsCfgRegistryUrl
        registryUserName: ghaSettingsCfgRegistryUserName
      }
      runtimeStack: ghaSettingsCfgRegistryRuntimeStack
      runtimeVersion: ghaSettingsCfgRegistryRuntimeVersion
    }
    repoUrl: ghaSettingsCfgRepoUrl
  }
}


// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep
resource appInsightsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: appInsightsDiagnosticSettingsName
  // scope: xxxContainerApp
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


module dnsprivatezone './dns.bicep' = {
  name: 'dns-private-zone'
  params: {
     location: location
     vnetName: vnetName
     
  }
  dependsOn: [
    azure
  ]     
}

