@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

@allowed([
  'AcrPull'
  'AcrPush'
])
@description('ACR Built-in role to assign')
param acrRoleType string = 'AcrPull'

// https://docs.microsoft.com/en-us/rest/api/containerregistry/registries/check-name-availability
@description('The name of the ACR, must be UNIQUE. The name must contain only alphanumeric characters, be globally unique, and between 5 and 50 characters in length.')
param acrName string = 'acr${appName}' // ==> $acr_registry_name.azurecr.io

param acaCustomersServicePrincipalId string
param acaVetsServicePrincipalId string
param acaVisitsServicePrincipalId string
param acaApiGatewayPrincipalId string
param acaAdminServerPrincipalId string
param acaConfigServerPrincipalId string
// param acaDiscoveryServerPrincipalId string


/*
param vnetName string
param subnetName string

@allowed([
  'Owner'
  'Contributor'
  'NetworkContributor'
  'Reader'
])
@description('VNet Built-in role to assign')
param networkRoleType string
*/


// https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var role = {
  Owner: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  Contributor: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
  Reader: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7'
  NetworkContributor: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
  AcrPull: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
  KeyVaultAdministrator: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483'
  KeyVaultReader: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/21090545-7ca7-4776-b22c-e363652d74d2'
  KeyVaultSecretsUser: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6'
}

resource acr 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' existing = {
  name: acrName
}
 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentCustomersService 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, acrRoleType , acaCustomersServicePrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaCustomersServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

output CustomersServiceUpdatedOn string = AcrPullRoleAssignmentCustomersService.properties.updatedOn
output CustomersServiceRoleAssignmentId string = AcrPullRoleAssignmentCustomersService.id
output CustomersServiceRoleAssignmentName string = AcrPullRoleAssignmentCustomersService.name

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentVetsService 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, acrRoleType , acaVetsServicePrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaVetsServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

output VetsServiceUpdatedOn string = AcrPullRoleAssignmentVetsService.properties.updatedOn
output VetsServiceRoleAssignmentId string = AcrPullRoleAssignmentVetsService.id
output VetsServiceRoleAssignmentName string = AcrPullRoleAssignmentVetsService.name

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentVisitsService 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, acrRoleType , acaVisitsServicePrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaVisitsServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

output VisitsServiceUpdatedOn string = AcrPullRoleAssignmentVisitsService.properties.updatedOn
output VisitsServiceRoleAssignmentId string = AcrPullRoleAssignmentVisitsService.id
output VisitsServiceRoleAssignmentName string = AcrPullRoleAssignmentVisitsService.name

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentConfigServer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, acrRoleType , acaConfigServerPrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaConfigServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output ConfigServerUpdatedOn string = AcrPullRoleAssignmentConfigServer.properties.updatedOn
output ConfigServerRoleAssignmentId string = AcrPullRoleAssignmentConfigServer.id
output ConfigServerRoleAssignmentName string = AcrPullRoleAssignmentConfigServer.name

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentAdminServer 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, acrRoleType , acaAdminServerPrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaAdminServerPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output AdminServerUpdatedOn string = AcrPullRoleAssignmentAdminServer.properties.updatedOn
output AdminServerRoleAssignmentId string = AcrPullRoleAssignmentAdminServer.id
output AdminServerRoleAssignmentName string = AcrPullRoleAssignmentAdminServer.name

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentacaApiGateway 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, acrRoleType , acaApiGatewayPrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaApiGatewayPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output ApiGatewayUpdatedOn string = AcrPullRoleAssignmentacaApiGateway.properties.updatedOn
output ApiGatewayRoleAssignmentId string = AcrPullRoleAssignmentacaApiGateway.id
output ApiGatewayRoleAssignmentName string = AcrPullRoleAssignmentacaApiGateway.name



/*
/!\ TO BE FIXED: should apply only when deployToVNet=true
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetName}/${subnetName}'
}

*/


// https://github.com/Azure/azure-quickstart-templates/blob/master/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/main.bicep
// https://github.com/Azure/bicep/discussions/5276
// Assign ManagedIdentity ID to the "Network contributor" role to ACA VNet
/*resource ACANetworkRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(appSubnet.id, networkRoleType , acaPrincipalId)
  scope: appSubnet
  properties: {
    roleDefinitionId: role[networkRoleType] // subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: acaPrincipalId
    principalType: 'ServicePrincipal'
  }
}
*/
