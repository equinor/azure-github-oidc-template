targetScope = 'subscription'

type federatedCredentialType = {
  name: string
  subject: string
}

type roleAssignmentType = {
  roleDefinitionId: string
  condition: string?
}

@description('The name of the resource group to create.')
param resourceGroupName string

@description('The name of the managed identity to create.')
param managedIdentityName string

@description('An array of federated credentials to add to the managed identity.')
param federatedCredentials federatedCredentialType[] = []

@description('An array of role assignments to create at the subscription scope.')
param roleAssignments roleAssignmentType[] = [
  {
    roleDefinitionId: 'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  }
]

var location = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
}

module managedIdentity 'modules/managedIdentity.bicep' = {
  name: 'managedIdentity'
  scope: resourceGroup
  params: {
    managedIdentityName: managedIdentityName
    federatedCredentials: federatedCredentials
  }
}

module authorization 'modules/authorization.bicep' = {
  name: 'authorization'
  params: {
    principalId: managedIdentity.outputs.principalId
    roleAssignments: roleAssignments
  }
}

@description('The client ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output clientId string = managedIdentity.outputs.clientId

@description('The subscription ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output subscriptionId string = subscription().subscriptionId

@description('The tenant ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output tenantId string = tenant().tenantId
