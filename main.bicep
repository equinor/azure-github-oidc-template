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
  {
    roleDefinitionId: 'f58310d9-a9f6-439a-9e8d-f62e7b41a168' // Role Based Access Control Administrator, with condition to prevent privilege escalation
    condition: '''((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168})) AND ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}))'''
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

@description('The object (principal) ID of the created managed identity.')
output principalId string = managedIdentity.outputs.principalId

@description('The subscription ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output subscriptionId string = subscription().subscriptionId

@description('The tenant ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output tenantId string = tenant().tenantId
