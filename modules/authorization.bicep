targetScope = 'subscription'

type roleAssignmentType = {
  roleDefinitionId: string
  condition: string?
}

@description('The object (principal) ID of the service principal to create role assignments for.')
param principalId string

@description('An array of role assignments to create at the subscription scrope.')
param roleAssignments roleAssignmentType[] = []

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for assignment in roleAssignments: {
    name: guid(subscription().id, principalId, assignment.roleDefinitionId)
    properties: {
      principalId: principalId
      principalType: 'ServicePrincipal'
      roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', assignment.roleDefinitionId)
      condition: assignment.?condition
      conditionVersion: assignment.?condition != null ? '2.0' : null
    }
  }
]
