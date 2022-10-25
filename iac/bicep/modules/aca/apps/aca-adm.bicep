// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(20)
param appName string = '101-${uniqueString(deployment().name)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

param appInsightsName string = 'appi-${appName}'

@description('The applicationinsights-agent-3.x.x.jar file is downloaded in each Dockerfile. See https://docs.microsoft.com/en-us/azure/azure-monitor/app/java-spring-boot#spring-boot-via-docker-entry-point')
param applicationInsightsAgentJarFilePath string = '/tmp/app/applicationinsights-agent-3.4.1.jar'

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

@description('The GitHub Action Settings Configuration / Image Tag, with GitHub commit ID (SHA) github.sha. Ex: petclinic/petclinic-admin-server:{{ github.sha }}')
param imageNameAdminServer string

@description('The Azure Container App instance name for admin-server')
param adminServerContainerAppName string = 'aca-${appName}-admin-server'

@description('The admin-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param adminServerAppIdentityName string = 'id-aca-petclinic-admin-server-dev-westeurope-101'

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: azureContainerAppEnvName
}

resource adminServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview'existing = {
  name: adminServerAppIdentityName
}

resource ACR 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: acrName
}

resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: appInsightsName
}

resource AdminServerContainerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: adminServerContainerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${adminServerIdentity.id}': {}
    }    
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
          server: ACR.properties.loginServer
          identity: adminServerIdentity.id
          //username: registryUsr
          // passwordSecretRef: 'registrypassword'
        }
      ]
      secrets: [
        {
          name: 'appinscon'
          value: appInsights.properties.ConnectionString
        }
      ]
    }
    template: {
      containers: [
        { 
          command: [
            'java', '-javaagent:${applicationInsightsAgentJarFilePath}', 'org.springframework.boot.loader.JarLauncher', '--server.port=8888'
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
          ]
          image: imageNameAdminServer
          name: adminServerContainerAppName
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
                path: '/manage/info'
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

output adminServerContainerAppOutboundIPAddresses array = AdminServerContainerApp.properties.outboundIPAddresses
output adminServerContainerAppLatestRevisionName string = AdminServerContainerApp.properties.latestRevisionName
output adminServerContainerAppLatestRevisionFqdn string = AdminServerContainerApp.properties.latestRevisionFqdn
output adminServerContainerAppIngressFqdn string = AdminServerContainerApp.properties.configuration.ingress.fqdn
output adminServerContainerAppConfigSecrets array = AdminServerContainerApp.properties.configuration.secrets
