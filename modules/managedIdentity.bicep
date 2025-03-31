type federatedCredentialType = {
  name: string
  subject: string
}

param managedIdentityName string
param federatedCredentials federatedCredentialType[] = []

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
  dependsOn: [managedIdentity::federatedIdentityCredential] // Lock must be created last
  properties: {
    level: 'ReadOnly'
    notes: 'Prevent changes to OIDC configuration'
  }
}

output clientId string = managedIdentity.properties.clientId
output subscriptionId string = subscription().subscriptionId
output tenantId string = tenant().tenantId
output principalId string = managedIdentity.properties.principalId
