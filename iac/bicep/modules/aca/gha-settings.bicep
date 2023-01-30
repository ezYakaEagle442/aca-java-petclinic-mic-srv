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

// https://docs.microsoft.com/en-us/azure/container-apps/managed-identity?tabs=portal%2Cjava#configure-managed-identities
@description('The Azure Active Directory tenant ID that should be used to store the GH Actions SPN credentials and to manage Azure Container Apps Identities.')
param tenantId string = subscription().tenantId
param subscriptionId string = subscription().id

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

// https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep
resource AdminServerContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' existing = {
  name: adminServerContainerAppName
}

resource ApiGatewayContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' existing = {
  name: apiGatewayContainerAppName
}

resource ConfigServerContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' existing = {
  name: configServerContainerAppName
}

resource CustomersServiceContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' existing = {
  name: customersServiceContainerAppName
}

resource VetsServiceContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' existing = {
  name: vetsServiceContainerAppName
}

resource VisitsServiceContainerApp 'Microsoft.App/containerApps@2022-06-01-preview' existing = {
  name: visitsServiceContainerAppName
}

resource githubActionSettingsCustomers 'Microsoft.App/containerApps/sourcecontrols@2022-06-01-preview' = {
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
      contextPath: ghaSettingsCfgDockerFilePathCustomersService
      image: imageNameCustomersService
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

resource githubActionSettingsVets 'Microsoft.App/containerApps/sourcecontrols@2022-06-01-preview' = {
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
      contextPath: ghaSettingsCfgDockerFilePathVetsService
      image: imageNameVetsService
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

resource githubActionSettingsVisits 'Microsoft.App/containerApps/sourcecontrols@2022-06-01-preview' = {
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
      contextPath: ghaSettingsCfgDockerFilePathVisitsService
      image: imageNameVisitsService
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

resource githubActionSettingsAPI 'Microsoft.App/containerApps/sourcecontrols@2022-06-01-preview' = {
  name: 'aca-gha-set-api-gw'
  parent: ApiGatewayContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      contextPath: ghaSettingsCfgDockerFilePathApiGateway
      image: imageNameApiGateway
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

resource githubActionSettingsConfigServer 'Microsoft.App/containerApps/sourcecontrols@2022-06-01-preview' = {
  name: 'aca-gha-set-cfg-srv'
  parent: ConfigServerContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      contextPath: ghaSettingsCfgDockerFilePathConfigserver
      image: imageNameConfigServer
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


resource githubActionSettingsAdminServer 'Microsoft.App/containerApps/sourcecontrols@2022-06-01-preview' = {
  name: 'aca-gha-set-admin-srv'
  parent: AdminServerContainerApp
  properties: {
    branch: ghaGitBranchName
    githubActionConfiguration: {
      azureCredentials: {
        clientId:ghaSettingsCfgCredClientId
        clientSecret: ghaSettingsCfgCredClientSecret
        subscriptionId: subscriptionId
        tenantId: tenantId
      }
      contextPath: ghaSettingsCfgDockerFilePathAdminServer // Dockerfile location
      image: imageNameAdminServer
      os: 'Linux'
      registryInfo: {
        // Managedidentity is enabled on ACR
        // https://learn.microsoft.com/en-us/azure/container-apps/containers#managed-identity-with-azure-container-registry
        registryUrl: ghaSettingsCfgRegistryUrl // yourACR.azurecr.io
        registryUserName: ghaSettingsCfgRegistryUserName
        // registryPassword: ghaSettingsCfgRegistryPassword
      }
      publishType: ghaSettingsCfgPublishType
    }
    repoUrl: ghaSettingsCfgRepoUrl
  }
}
