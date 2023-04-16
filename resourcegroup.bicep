targetScope = 'subscription'

param rgName string = 'contoso'
param location string = 'northeurope'

resource resource 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: rgName
  location: location
}
