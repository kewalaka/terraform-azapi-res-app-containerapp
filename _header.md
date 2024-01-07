# terraform-azapi-res-container-apps

This is a repo for Container Apps ***in the style of*** Azure Verified Modules (AVM), for official AVM modules, please see <https://aka.ms/AVM>.

Whilst this uses the AzApi provider, a key design pattern is to standardarise the variable definition so it is as close to the existing AzureRM resource as possible (augmenting as needed to support parameters that are currently not supported by the AzureRM provider).

Currently implemented parameters cover;

- dapr
- container
- ingress
- probes (liveness, readiness & startup)
- secrets
- registries

Note this uses the AZAPI provider because of support missing within the AzureRM provider for [workload profiles](https://github.com/hashicorp/terraform-provider-azurerm/issues/21747).

## Background

This project was originally written because the AzAPI provider was missing within the AzureRM provider for [workload profiles](https://github.com/hashicorp/terraform-provider-azurerm/issues/21747).

This can be converted using [azapi2azurerm](https://github.com/Azure/azapi2azurerm) once Container Apps support stablises in the Azure RM provider.

This project includes [examples](./examples/) showing default settings and an example from Microsoft Learn illustrating Dapr.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE_CLIENT_ID
   1. AZURE_TENANT_ID
   1. AZURE_SUBSCRIPTION_ID
