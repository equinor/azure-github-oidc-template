// Assigns subscription roles to the service principal of the given object ID.

targetScope = 'subscription'

param principalId string

// Contributor
var contributorDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b24988ac-6180-42a0-ab88-20f7382dd24c'
)

resource contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, contributorDefinitionId)
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorDefinitionId
  }
}

// Role Based Access Control Administrator
var rbacAdministratorDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
)

resource rbacAdministrator 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId, 'roleDefinitionId')
  properties: {
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: rbacAdministratorDefinitionId
    condition: '' // TODO: prevent assignment of privileged roles.
    conditionVersion: '2.0'
  }
}
