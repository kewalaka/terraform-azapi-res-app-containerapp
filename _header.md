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

> [!WARNING]
> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

## Background

This project was originally written because the AzAPI provider was missing within the AzureRM provider for [workload profiles](https://github.com/hashicorp/terraform-provider-azurerm/issues/21747).

This can be converted using [azapi2azurerm](https://github.com/Azure/azapi2azurerm) once Container Apps support stablises in the Azure RM provider.

This project includes [examples](./examples/) showing default settings and an example from Microsoft Learn illustrating Dapr.
