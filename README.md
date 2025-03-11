# Azure GitHub Actions OIDC Template

Azure Resource Manager (ARM) template that creates a managed identity with OpenID Connect (OIDC) authentication from GitHub Actions.

## Parameters

| Name | Description | Type | Default |
| - | - | - | - |
| `managedIdentityName` | The name of the managed identity to create. | `string` | |
| `federatedCredentials` | An array of federated credentials to create for the managed identity. | `{ name: string, subject: string }[]` | |
