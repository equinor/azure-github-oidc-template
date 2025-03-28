targetScope = 'subscription'

param principalId string
param rbacAssignableRoles string[]

var subscriptionId = subscription().id

// Contributor
var contributorDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b24988ac-6180-42a0-ab88-20f7382dd24c'
)

resource contributor 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscriptionId, principalId, contributorDefinitionId)
  properties: {
    description: 'Allow service principal to manage all resources'
    principalType: 'ServicePrincipal'
    principalId: principalId
    roleDefinitionId: contributorDefinitionId
  }
}

// Role Based Access Control Administrator
var rbacAdministratorDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
)

var allowedRoles = join(rbacAssignableRoles, ', ')

resource rbacAdministrator 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscriptionId, principalId, rbacAdministratorDefinitionId)
  properties: {
    description: 'Allow service principal to assign selected roles'
    principalType: 'ServicePrincipal'
    principalId: principalId
    roleDefinitionId: rbacAdministratorDefinitionId
    condition: '((!(ActionMatches{\'Microsoft.Authorization/roleAssignments/write\'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${allowedRoles}})) AND ((!(ActionMatches{\'Microsoft.Authorization/roleAssignments/delete\'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${allowedRoles}}))'
    conditionVersion: '2.0'
  }
}
