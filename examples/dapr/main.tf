terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.71.0, < 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.9.0"
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

resource "azapi_resource" "managed_environment" {
  name      = replace(azurerm_resource_group.this.name, "rg-", "cae-") # TODO remove workaround pending PR - https://github.com/Azure/terraform-azurerm-naming/pull/103
  location  = azurerm_resource_group.this.location
  parent_id = azurerm_resource_group.this.id
  type      = "Microsoft.App/managedEnvironments@2022-03-01"

  body = jsonencode({
    properties = {
      appLogsConfiguration = {
        destination = "azure-monitor"
      }
    }
  })
}

# This is the module call
module "node-app" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                    = replace(azurerm_resource_group.this.name, "rg-", "ca-nodeapp-") # TODO remove workaround pending PR - https://github.com/Azure/terraform-azurerm-naming/pull/103
  resource_group_name     = azurerm_resource_group.this.name
  environment_resource_id = azapi_resource.managed_environment.id

  workload_profile_name = ""
  ingress = {
    external   = false
    targetPort = 3000
  }
  dapr = {
    enabled     = true
    appId       = "nodeapp"
    appProtocol = "http"
    appPort     = 3000
  }
  template = {
    containers = [{
      image = "dapriosamples/hello-k8s-node:latest"
      name  = "hello-k8s-node"
      env = [{
        name  = "APP_PORT"
        value = 3000
      }]
      resources = {
        cpu    = 0.5
        memory = "1.0Gi"
      }
    }]
    scale = {
      minReplicas = 1
      maxReplicas = 1
    }
  }

}

module "python-app" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                    = replace(azurerm_resource_group.this.name, "rg-", "ca-pythonapp-") # TODO remove workaround pending PR - https://github.com/Azure/terraform-azurerm-naming/pull/103
  resource_group_name     = azurerm_resource_group.this.name
  environment_resource_id = azapi_resource.managed_environment.id

  workload_profile_name = ""
  dapr = {
    enabled = true
    appId   = "pythonapp"
  }
  template = {
    containers = [{
      image = "dapriosamples/hello-k8s-python:latest"
      name  = "hello-k8s-python"
      resources = {
        cpu    = 0.5
        memory = "1.0Gi"
      }
    }]
    scale = {
      minReplicas = 1
      maxReplicas = 1
    }
  }

}
