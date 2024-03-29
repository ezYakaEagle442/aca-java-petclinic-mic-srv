// https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(resourceGroup().id, subscription().id)}'

@description('The Identity location')
param location string = resourceGroup().location

@description('The Identity Tags. See https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#apply-an-object')
param tags object = {
  Environment: 'Dev'
  Dept: 'IT'
  Scope: 'EU'
  CostCenter: '442'
  Owner: 'Petclinic'
}

///////////////////////////////////
// Resource names

// id-<app or service name>-<environment>-<region name>-<###>
// ex: id-appcn-keda-prod-eastus2-001

@description('The admin-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param adminServerAppIdentityName string = 'id-aca-${appName}-petclinic-admin-server-dev-${location}-101'

@description('The config-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param configServerAppIdentityName string = 'id-aca-${appName}-petclinic-config-server-dev-${location}-101'

@description('The discovery-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param discoveryServerAppIdentityName string = 'id-aca-${appName}-petclinic-discovery-server-dev-${location}-101'

@description('The api-gateway Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param apiGatewayAppIdentityName string = 'id-aca-${appName}-petclinic-api-gateway-dev-${location}-101'

@description('The customers-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param customersServiceAppIdentityName string = 'id-aca-${appName}-petclinic-customers-service-dev-${location}-101'

@description('The vets-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param vetsServiceAppIdentityName string = 'id-aca-${appName}-petclinic-vets-service-dev-${location}-101'

@description('The visits-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param visitsServiceAppIdentityName string = 'id-aca-${appName}-petclinic-visits-service-dev-${location}-101'

///////////////////////////////////
// New resources

resource adminServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: adminServerAppIdentityName
  location: location
  tags: tags
}
output adminServerIdentityId string = adminServerIdentity.id
output adminServerPrincipalId string = adminServerIdentity.properties.principalId
output adminServerClientId string = adminServerIdentity.properties.clientId

resource configServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: configServerAppIdentityName
  location: location
  tags: tags
}
output configServerIdentityId string = configServerIdentity.id
output configServerPrincipalId string = configServerIdentity.properties.principalId
output configServerClientId string = configServerIdentity.properties.clientId


resource discoveryServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: discoveryServerAppIdentityName
  location: location
  tags: tags
}
output discoveryServerIdentityId string = discoveryServerIdentity.id
output discoveryServerPrincipalId string = discoveryServerIdentity.properties.principalId
output discoveryServerClientId string = discoveryServerIdentity.properties.clientId

resource apiGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: apiGatewayAppIdentityName
  location: location
  tags: tags
}
output apiGatewayIdentityId string = apiGatewayIdentity.id
output apiGatewayPrincipalId string = apiGatewayIdentity.properties.principalId
output apiGatewayClientId string = apiGatewayIdentity.properties.clientId

resource customersServicedentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: customersServiceAppIdentityName
  location: location
  tags: tags
}
output customersServiceIdentityId string = customersServicedentity.id
output customersServicePrincipalId string = customersServicedentity.properties.principalId
output customersServiceClientId string = customersServicedentity.properties.clientId

resource vetsServiceIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: vetsServiceAppIdentityName
  location: location
  tags: tags
}
output vetsServiceIdentityId string = vetsServiceIdentity.id
output vetsServicePrincipalId string = vetsServiceIdentity.properties.principalId
output vetsServiceClientId string = vetsServiceIdentity.properties.clientId

resource visitsServiceIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: visitsServiceAppIdentityName
  location: location
  tags: tags
}
output visitsServiceIdentityId string = visitsServiceIdentity.id
output visitsServicePrincipalId string = visitsServiceIdentity.properties.principalId
output visitsServiceClientId string = visitsServiceIdentity.properties.clientId
