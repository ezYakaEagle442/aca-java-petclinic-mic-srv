@allowed([
  'Owner'
  'Contributor'
  'NetworkContributor'
  'Reader'
])
@description('VNet Built-in role to assign')
param networkRoleType string

@allowed([
  'KeyVaultAdministrator'
  'KeyVaultReader'
  'KeyVaultSecretsUser'  
])
@description('KV Built-in role to assign')
param kvRoleType string

param vnetName string
param subnetName string
param kvName string

@description('The name of the KV RG')
param kvRGName string

@allowed([
  'AcrPull'
  'AcrPush'
])
@description('ACR Built-in role to assign')
param acrRoleType string

param acrName string

param acaCustomersServicePrincipalId string
param acaVetsServicePrincipalId string
param acaVisitsServicePrincipalId string

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: vnetName
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${vnetName}/${subnetName}'
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' existing = {
  name: acrName
}

resource kv 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  name: kvName
  scope: resourceGroup(kvRGName)
}

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

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentCustomersService 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acr.id, acrRoleType , acaCustomersServicePrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaCustomersServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentVetsService 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acr.id, acrRoleType , acaVetsServicePrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaVetsServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

 // acrpull role to assign to the ACA Identity: az role assignment create --assignee $sp_id --role acrpull --scope $acr_registry_id
 resource AcrPullRoleAssignmentVisitsService 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(acr.id, acrRoleType , acaVisitsServicePrincipalId)
  scope: acr
  properties: {
    roleDefinitionId: role[acrRoleType]
    principalId: acaVisitsServicePrincipalId
    principalType: 'ServicePrincipal'
  }
}

// You need Key Vault Administrator permission to be able to see the Keys/Secrets/Certificates in the Azure Portal
/*
resource KVAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(kv.id, kvRoleType , subscription().subscriptionId)
  properties: {
    roleDefinitionId: role[kvRoleType]
    principalId: acaPrincipalId
    principalType: 'ServicePrincipal'
  }
}
*/

// https://github.com/Azure/azure-quickstart-templates/blob/master/modules/Microsoft.ManagedIdentity/user-assigned-identity-role-assignment/1.0/main.bicep
// https://github.com/Azure/bicep/discussions/5276
// Assign ManagedIdentity ID to the "Network contributor" role to ACA VNet
/*resource ACANetworkRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(appSubnet.id, networkRoleType , acaPrincipalId)
  scope: appSubnet
  properties: {
    roleDefinitionId: role[networkRoleType] // subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
    principalId: acaPrincipalId
    principalType: 'ServicePrincipal'
  }
}
*/
