targetScope = 'subscription'

@description('A UNIQUE name')
@maxLength(21)
param appName string = 'petcli${uniqueString(deployment().location)}'

param location string = deployment().location
param rgName string  = 'rg-${appName}'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  location: location
  name: rgName
}

output rgId string = rg.id
output rgName string = rg.name
