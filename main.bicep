targetScope = 'subscription'

type federatedCredential = {
  name: string
  subject: string
}

@description('The name of the resource group to create.')
param resourceGroupName string

@description('The name of the managed identity to create.')
param managedIdentityName string

@description('An array of federated credentials to add to the managed identity.')
param federatedCredentials federatedCredential[] = []

@description('An array of roles the created service principal should be allowed to assign to other principals.')
@minLength(1)
param rbacAssignableRoles string[]

var location = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: resourceGroupName
  location: location
}

module servicePrincipal 'modules/managedIdentity.bicep' = {
  name: 'managedIdentity' // TODO: set deployment name
  scope: resourceGroup
  params: {
    managedIdentityName: managedIdentityName
    federatedCredentials: federatedCredentials
  }
}

module rbac 'modules/authorization.bicep' = {
  name: 'authorization' // TODO: set deployment name
  params: {
    principalId: servicePrincipal.outputs.principalId
    rbacAssignableRoles: rbacAssignableRoles
  }
}

@description('The client ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output clientId string = servicePrincipal.outputs.clientId

@description('The subscription ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output subscriptionId string = servicePrincipal.outputs.subscriptionId

@description('The tenant ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output tenantId string = servicePrincipal.outputs.tenantId
