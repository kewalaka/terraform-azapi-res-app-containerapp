<!-- BEGIN_TF_DOCS -->
# Distributed Application Runtime (Dapr) example

This deploys the two containers used in this [Microsoft Learn tutorial](https://learn.microsoft.com/en-us/azure/container-apps/microservices-dapr?tabs=bash%2Cazure-cli).

```hcl
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
  name                    = module.naming.container_app.name_unique
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
  name                    = module.naming.container_app.name_unique
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (1.9.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (1.9.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.71.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azapi_resource.managed_environment](https://registry.terraform.io/providers/Azure/azapi/1.9.0/docs/resources/resource) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

No optional inputs.

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.4.0

### <a name="module_node_app"></a> [node\_app](#module\_node\_app)

Source: ../../

Version:

### <a name="module_python_app"></a> [python\_app](#module\_python\_app)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->