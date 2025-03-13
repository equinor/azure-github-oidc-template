type federatedCredential = {
  name: string
  subject: string
}

@description('The name of the managed identity to create.')
param managedIdentityName string

@description('An array of federated credentials to add to the managed identity.')
param federatedCredentials federatedCredential[] = []

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: resourceGroup().location

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
  properties: {
    level: 'ReadOnly'
    notes: 'Prevent changes to OIDC configuration'
  }
}

@description('The client ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output clientId string = managedIdentity.properties.clientId

@description('The subscription ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output subscriptionId string = subscription().subscriptionId

@description('The tenant ID that should be used to authenticate from GitHub Actions to Azure using OIDC.')
output tenantId string = tenant().tenantId
