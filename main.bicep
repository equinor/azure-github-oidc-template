@description('The name of the managed identity to create.')
param managedIdentityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: resourceGroup().location
}
