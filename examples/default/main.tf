terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.3.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "australiaeast"
}

resource "azurerm_container_app_environment" "this" {
  name                = replace(azurerm_resource_group.this.name, "rg-", "cae-") # TODO remove workaround pending PR - https://github.com/Azure/terraform-azurerm-naming/pull/103
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
module "container_app" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                                  = replace(azurerm_resource_group.this.name, "rg-", "ca-")
  resource_group_name                   = azurerm_resource_group.this.name
  container_app_environment_resource_id = azurerm_container_app_environment.this.id

  workload_profile_name = "Consumption"
  container_apps = [{
    name = "helloworld"
    configuration = {
      ingress = {
        external = true
      }
    }
    template = {
      containers = [{
        image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
        name  = "containerapps-helloworld"
        resources = {
          cpu    = 0.25
          memory = "0.5Gi"
        }
      }]
      scale = {
        minReplicas = 1
        maxReplicas = 1
      }
    }
    }
  ]
}