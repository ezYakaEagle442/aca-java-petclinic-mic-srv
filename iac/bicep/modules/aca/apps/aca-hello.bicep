// https://docs.microsoft.com/en-us/azure/templates/microsoft.appplatform/spring?tabs=bicep
@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

@description('The location of the Azure resources.')
param location string = resourceGroup().location

@description('The Azure Container App Environment name')
param azureContainerAppEnvName string = 'aca-env-${appName}'

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

resource corpManagedEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: azureContainerAppEnvName
}

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep
resource HelloContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' = {
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
    }
    template: {
      containers: [
        {
          image: 'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest'
          name: 'hello-test'
          resources: {
            cpu: any(containerResourcesCpu)
            memory: containerResourcesMemory
          }
        }
      ]
      scale: {
        maxReplicas: 1
        minReplicas: 2
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

// output helloContainerAppIdentity string = HelloContainerApp.identity.principalId
output helloContainerAppoutboundIpAddresses array = HelloContainerApp.properties.outboundIpAddresses
output helloContainerAppLatestRevisionName string = HelloContainerApp.properties.latestRevisionName
output helloContainerAppLatestRevisionFqdn string = HelloContainerApp.properties.latestRevisionFqdn
output helloContainerAppIngressFqdn string = HelloContainerApp.properties.configuration.ingress.fqdn
output helloContainerAppConfigSecrets array = HelloContainerApp.properties.configuration.secrets
