terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "australiaeast"
}

resource "azurerm_container_app_environment" "this" {
  name                = module.naming.container_app_environment.name_unique
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

# This is the module call
module "container_app" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                    = module.naming.container_app.name_unique
  resource_group_name     = azurerm_resource_group.this.name
  environment_resource_id = azurerm_container_app_environment.this.id

  workload_profile_name = "Consumption"
  ingress = {
    external   = true
    targetPort = 80
  }
  template = {
    containers = [{
      image = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      name  = "containerapps-helloworld"
      resources = {
        cpu    = "0.25"
        memory = "0.5Gi"
      }
    }]
    scale = {
      minReplicas = 1
      maxReplicas = 1
    }
  }
}
