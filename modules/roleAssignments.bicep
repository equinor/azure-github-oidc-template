targetScope = 'subscription'

param principalId string

var roleDefinitionIds = [
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  'f58310d9-a9f6-439a-9e8d-f62e7b41a168' // Role Based Access Control Administrator
]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for roleDefinitionId in roleDefinitionIds: {
    name: guid(subscription().id, principalId, roleDefinitionId)
    scope: subscription()
    properties: {
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
      condition: '' // TODO: prevent assignment of privileged roles
      conditionVersion: '2.0'
    }
  }
]
