targetScope = 'subscription'

type roleAssignmentType = {
  roleDefinitionId: string
  condition: string?
}

param principalId string
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
