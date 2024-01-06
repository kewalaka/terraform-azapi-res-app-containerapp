# terraform-azurerm-avm-res-container-apps

This is a repo for Container Apps in the style of Azure Verified Modules (AVM), it is an 'unofficial' example that has been used for learning AVM.

> [!WARNING]
> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

This project uses the AZAPI provider because of support missing within the AzureRM provider for [workload profiles](https://github.com/hashicorp/terraform-provider-azurerm/issues/21747).

Once container apps support stablises in the Azure RM provider, [azapi2azurerm](https://github.com/Azure/azapi2azurerm) can be used to convert this code.

This project includes [examples](./examples/) showing default settings and an example from Microsoft Learn illustrating Dapr.
