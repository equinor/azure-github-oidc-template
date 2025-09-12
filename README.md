# Azure GitHub OIDC Template

[![GitHub License](https://img.shields.io/github/license/equinor/azure-github-oidc-template)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/equinor/azure-github-oidc-template)](https://github.com/equinor/azure-github-oidc-template/releases/latest)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/azure-github-oidc-template/badge)](https://developer.equinor.com/governance/scm-policy/)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fequinor%2Fazure-github-oidc-template%2Fmain%2Fazuredeploy.json)

Azure Resource Manager (ARM) template that configures OpenID Connect (OIDC) authentication from GitHub Actions to Azure:

- Creates a managed identity with the given name in Azure.
- Adds federated credentials for the GitHub OIDC identity provider with the given names and subjects.
- Assigns the given roles at the subscription scope (`Contributor` by default).
- Creates a read-only lock to prevent changes to the managed identity.

## Prerequisites

- Sign up for an [Azure account](https://azure.microsoft.com/en-us/pricing/purchase-options/azure-account).
- Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) version 2.20 or later.

## Usage

### Create managed identity for Azure resources

1. Login to Azure:

   ```console
   az login
   ```

1. Set active subscription:

   ```console
   az account set --name <SUBSCRIPTION_NAME>
   ```

1. Create a deployment at subscription from the template URI:

   ```console
   az deployment sub create --name github-actions-oidc --location northeurope --template-uri https://raw.githubusercontent.com/equinor/azure-github-oidc-template/main/azuredeploy.json --parameters resourceGroupName=<RESOURCE_GROUP_NAME> managedIdentityName=<MANAGED_IDENTITY_NAME> federatedCredentials='[{ "name": "github-federated-identity", "subject": "repo:<GITHUB_REPOSITORY>:environment:development" }]'
   ```

   Requires Azure role `Owner` at subscription.

### Set values for GitHub Actions secrets

1. Create a GitHub Actions workflow and set the following `GITHUB_TOKEN` permissions:

   ```yaml
   permissions:
     id-token: write
   ```

1. Add the following step to authenticate from the GitHub Actions workflow to Azure:

   ```yaml
   - uses: azure/login@v2
     with:
       client-id: ${{ secrets.AZURE_CLIENT_ID }}
       subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
       tenant-id: ${{ secrets.AZURE_TENANT_ID }}
   ```

   Get the values for [secrets](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions) `AZURE_CLIENT_ID`, `AZURE_SUBSCRIPTION_ID` and `AZURE_TENANT_ID` from [outputs](#outputs).

## Parameters

| Name | Description | Type | Default |
| - | - | - | - |
| `resourceGroupName` | The name of the resource group to create. | `string` | |
| `managedIdentityName` | The name of the managed identity to create. | `string` | |
| `federatedCredentials` | An array of federated credentials to add to the managed identity. | `{ "name": string, "subject": string }[]` | `[]` |
| `roleAssignments` | An array of role assignments to create at the subscription scope. | `{ "roleDefinitionId": string, "condition": string? }[]` | <details><summary>Show default</summary>`[{ "roleDefinitionId": "b24988ac-6180-42a0-ab88-20f7382dd24c" }, { "roleDefinitionId": "f58310d9-a9f6-439a-9e8d-f62e7b41a168", "condition": "((!(ActionMatches{'Microsoft.Authorization/roleAssignments/write'})) OR (@Request[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168})) AND ((!(ActionMatches{'Microsoft.Authorization/roleAssignments/delete'})) OR (@Resource[Microsoft.Authorization/roleAssignments:RoleDefinitionId] ForAnyOfAllValues:GuidNotEquals {8e3af657-a8ff-443c-a75c-2fe8c4bcb635, 18d7d88d-d35e-4fb5-a5c3-7773c20a72d9, f58310d9-a9f6-439a-9e8d-f62e7b41a168}))" }]`</details> |

> [!TIP]
> Rather than passing parameters as inline values, create a [parameter file](https://learn.microsoft.com/en-us/azure/azure-resource-manager/templates/parameter-files).

## Outputs

When the deployment succeeds, the following output values are automatically returned in the results of the deployment:

| Name | Description | Type |
| - | - | - |
| `clientId` | The client ID that should be used to authenticate from GitHub Actions to Azure using OIDC. | `string` |
| `subscriptionId` | The subscription ID that should be used to authenticate from GitHub Actions to Azure using OIDC. | `string` |
| `tenantId` | The tenant ID that should be used to authenticate from GitHub Actions to Azure using OIDC. | `string` |

## References

- [Configuring OpenID Connect in Azure - GitHub Docs](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Use GitHub Actions to connect to Azure - Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)

## Contributing

See [contributing guidelines](CONTRIBUTING.md).

## License

This project is licensed under the terms of the [MIT license](LICENSE).
