type federatedCredentialType = {
  name: string
  subject: string
}

@description('The name of the managed identity to create.')
param managedIdentityName string

@description('An array of federated credentials to add to the managed identity.')
param federatedCredentials federatedCredentialType[] = []

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: resourceGroup().location

  // Parallel write operations to federated identity credential resources is currently not supported.
  @batchSize(1)
  resource federatedIdentityCredential 'federatedIdentityCredentials' = [
    for fic in federatedCredentials: {
      name: fic.name
      properties: {
        issuer: 'https://token.actions.githubusercontent.com' // GitHub OIDC identity provider URL
        subject: fic.subject
        audiences: ['api://AzureADTokenExchange']
      }
    }
  ]
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = {
  name: 'OIDC'
  scope: managedIdentity
  dependsOn: [managedIdentity::federatedIdentityCredential] // Lock must be created last
  properties: {
    level: 'ReadOnly'
    notes: 'Prevent changes to OIDC configuration'
  }
}

@description('The client ID of the created managed identity.')
output clientId string = managedIdentity.properties.clientId

@description('The object (principal) ID of the created managed identity.')
output principalId string = managedIdentity.properties.principalId
