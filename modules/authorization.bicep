targetScope = 'subscription'

param principalId string
param allowedRoleIds string[]

var subscriptionId = subscription().id

var contributorRoleDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'b24988ac-6180-42a0-ab88-20f7382dd24c'
)

resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscriptionId, principalId, contributorRoleDefinitionId)
  properties: {
    description: 'Allow service principal to manage all resources'
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinitionId
  }
}

var rbacAdminRoleDefinitionId = resourceId(
  'Microsoft.Authorization/roleDefinitions',
  'f58310d9-a9f6-439a-9e8d-f62e7b41a168'
)

var allowedRoleIdsString = join(allowedRoleIds, ', ')

resource rbacAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscriptionId, principalId, rbacAdminRoleDefinitionId)
  properties: {
    description: 'Allow service principal to assign selected roles'
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: rbacAdminRoleDefinitionId
    condition: '((!(ActionMatches{\'Microsoft.Authorization/roleAssignments/write\'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${allowedRoleIdsString}})) AND ((!(ActionMatches{\'Microsoft.Authorization/roleAssignments/delete\'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAnyValues:GuidEquals {${allowedRoleIdsString}}))'
    conditionVersion: '2.0'
  }
}
