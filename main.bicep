type federatedCredential = {
  name: string
  subject: string
}

@description('The name of the managed identity to create.')
param managedIdentityName string

@description('An array of federated credentials to create for the managed identity.')
@minLength(1)
param federatedCredentials federatedCredential[]

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: resourceGroup().location

  resource federatedIdentityCredential 'federatedIdentityCredentials' = [
    for fic in federatedCredentials: {
      name: fic.name
      properties: {
        issuer: 'https://token.actions.githubusercontent.com'
        subject: fic.subject
        audiences: ['api://AzureADTokenExchange']
      }
    }
  ]
}
