# Azure GitHub Actions OIDC Template

[![GitHub License](https://img.shields.io/github/license/equinor/azure-github-actions-oidc-template)](LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/equinor/azure-github-actions-oidc-template)](https://github.com/equinor/azure-github-actions-oidc-template/releases/latest)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-%23FE5196?logo=conventionalcommits&logoColor=white)](https://conventionalcommits.org)
[![SCM Compliance](https://scm-compliance-api.radix.equinor.com/repos/equinor/azure-github-actions-oidc-template/badge)](https://developer.equinor.com/governance/scm-policy/)

Azure Resource Manager (ARM) template that creates a managed identity with OpenID Connect (OIDC) authentication from GitHub Actions:

- Creates a managed identity with the specified name.

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

1. Create resource group:

   ```console
   az group create --name <RESOURCE_GROUP_NAME> --location <LOCATION>
   ```

   Requires Azure role `Contributor` at subscription.

1. Create a deployment at resource group from the template URI:

   ```console
   az deployment group create --name github-actions-oidc --resource-group <RESOURCE_GROUP_NAME> --template-uri https://raw.githubusercontent.com/equinor/azure-github-actions-oidc-template/refs/heads/main/azuredeploy.json --parameters managedIdentityName=<MANAGED_IDENTITY_NAME>
   ```

   Requires Azure role `Contributor` at resource group.

## Parameters

| Name | Description | Type | Default |
| - | - | - | - |
| `managedIdentityName` | The name of the managed identity to create. | `string` | |

## References

- [Configuring OpenID Connect in Azure - GitHub Docs](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-azure)
- [Use GitHub Actions to connect to Azure - Microsoft Learn](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure)

## Contributing

See [contributing guidelines](CONTRIBUTING.md).

## License

This project is licensed under the terms of the [MIT license](LICENSE).
