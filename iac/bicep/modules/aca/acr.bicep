@description('A UNIQUE name')
@maxLength(23)
param appName string = 'petcliaca${uniqueString(resourceGroup().id, subscription().id)}'

// https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/check-name-availability
@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

@description('The ACR location')
param location string = resourceGroup().location

// Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed
@description('The Azure Container App Env. VNet CIDR')
param networkRuleSetCidr string

@description('The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault.')
param tenantId string = subscription().tenantId

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Basic'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // https://learn.microsoft.com/en-us/azure/container-registry/container-registry-authentication?source=recommendations&tabs=azure-cli#authentication-options
    adminUserEnabled: true // Single account per registry, not recommended for multiple users . This registry must have the Admin User enabled, or the integration with ACA won’t work from the Azure portal. 
    dataEndpointEnabled: false // data endpoint rule is not supported for the SKU Basic
    /*
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: networkRuleSetCidr // []
        }
      ]
    }
    */
    publicNetworkAccess: 'Enabled'
    zoneRedundancy: 'Disabled'
  }
}

output acrId string = acr.id
output acrName string = acr.name
output acrIdentity string = acr.identity.principalId
output acrType string = acr.type
output acrRegistryUrl string = acr.properties.loginServer

// outputs-should-not-contain-secrets
// output acrRegistryUsr string = acr.listCredentials().username
//output acrRegistryPwd string = acr.listCredentials().passwords[0].value
