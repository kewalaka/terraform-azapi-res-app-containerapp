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
  name      = module.naming.container_app_environment.name_unique
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
module "node_app" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                    = "${module.naming.container_app.name_unique}-node"
  resource_group_name     = azurerm_resource_group.this.name
  environment_resource_id = azapi_resource.managed_environment.id

  workload_profile_name = ""
  ingress = {
    external_enabled = false
    target_port      = 3000
  }
  dapr = {
    enabled      = true
    app_id       = "nodeapp"
    app_protocol = "http"
    app_port     = 3000
  }
  template = {
    container = [{
      image  = "dapriosamples/hello-k8s-node:latest"
      name   = "hello-k8s-node"
      cpu    = 0.5
      memory = "1.0Gi"
      env = [{
        name  = "APP_PORT"
        value = 3000
      }]
    }]
    min_replicas = 1
    max_replicas = 1
  }

}

module "python_app" {
  source = "../../"
  # source             = "Azure/avm-<res/ptn>-<name>/azurerm"
  name                    = "${module.naming.container_app.name_unique}-python"
  resource_group_name     = azurerm_resource_group.this.name
  environment_resource_id = azapi_resource.managed_environment.id

  workload_profile_name = ""
  dapr = {
    enabled = true
    app_id  = "pythonapp"
  }
  template = {
    container = [{
      image  = "dapriosamples/hello-k8s-python:latest"
      name   = "hello-k8s-python"
      cpu    = 0.5
      memory = "1.0Gi"
    }]
    min_replicas = 1
    max_replicas = 1
  }

}
