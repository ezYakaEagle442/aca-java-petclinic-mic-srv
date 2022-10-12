// https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming

@description('The Identity location')
param location string = resourceGroup().location

@description('The Identity Tags. See https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#apply-an-object')
param tags object = {
  'Environment': 'Dev'
  'Dept': 'IT'
  'Scope': 'EU'
  'CostCenter': '442'
  'Owner': 'Petclinic'
}

///////////////////////////////////
// Resource names

// id-<app or service name>-<environment>-<region name>-<###>
// ex: id-appcn-keda-prod-eastus2-001

@description('The admin-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param adminServerAppIdentityName string = 'id-aca-petclinic-admin-server-dev-westeurope-101'

@description('The config-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param configServerAppIdentityName string = 'id-aca-petclinic-config-server-dev-westeurope-101'

@description('The discovery-server Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param discoveryServerAppIdentityName string = 'id-aca-petclinic-discovery-server-dev-westeurope-101'

@description('The api-gateway Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param apiGatewayAppIdentityName string = 'id-aca-petclinic-api-gateway-dev-westeurope-101'

@description('The customers-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param customersServiceAppIdentityName string = 'id-aca-petclinic-customers-service-dev-westeurope-101'

@description('The vets-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param vetsServiceAppIdentityName string = 'id-aca-petclinic-vets-service-dev-westeurope-101'

@description('The visits-service Identity name, see Character limit: 3-128 Valid characters: Alphanumerics, hyphens, and underscores')
param visitsServiceAppIdentityName string = 'id-aca-petclinic-visits-service-dev-westeurope-101'

///////////////////////////////////
// New resources

// https://learn.microsoft.com/en-us/azure/templates/microsoft.managedidentity/userassignedidentities?pivots=deployment-language-bicep
resource adminServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: adminServerAppIdentityName
  location: location
  tags: tags
}
output adminServerIdentityId string = adminServerIdentity.id
output adminServerPrincipalId string = adminServerIdentity.properties.principalId

resource configServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: configServerAppIdentityName
  location: location
  tags: tags
}
output configServerIdentityId string = configServerIdentity.id
output configServerPrincipalId string = configServerIdentity.properties.principalId

resource discoveryServerIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: discoveryServerAppIdentityName
  location: location
  tags: tags
}
output discoveryServerIdentityId string = discoveryServerIdentity.id
output discoveryServerPrincipalId string = discoveryServerIdentity.properties.principalId

resource apiGatewayIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: apiGatewayAppIdentityName
  location: location
  tags: tags
}
output apiGatewayIdentityId string = apiGatewayIdentity.id
output apiGatewayPrincipalId string = apiGatewayIdentity.properties.principalId

resource customersServicedentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: customersServiceAppIdentityName
  location: location
  tags: tags
}
output customersServiceIdentityId string = customersServicedentity.id
output customersServicePrincipalId string = customersServicedentity.properties.principalId

resource vetsServiceAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: vetsServiceAppIdentityName
  location: location
  tags: tags
}
output vetsServiceAppIdentityId string = vetsServiceAppIdentity.id
output vetsServicePrincipalId string = vetsServiceAppIdentity.properties.principalId

resource visitsServiceIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: visitsServiceAppIdentityName
  location: location
  tags: tags
}
output visitsServiceIdentityId string = visitsServiceIdentity.id
output visitsServicePrincipalId string = visitsServiceIdentity.properties.principalId
