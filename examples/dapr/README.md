<!-- BEGIN_TF_DOCS -->
# Distributed Application Runtime (Dapr) example

This deploys the two containers used in this [Microsoft Learn tutorial](https://learn.microsoft.com/en-us/azure/container-apps/microservices-dapr?tabs=bash%2Cazure-cli).

```hcl
terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.9.0"
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
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (1.9.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.7.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (1.9.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.7.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azapi_resource.managed_environment](https://registry.terraform.io/providers/Azure/azapi/1.9.0/docs/resources/resource) (resource)
- [azurerm_resource_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)

<!-- markdownlint-disable MD013 -->
## Required Inputs

No required inputs.

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

## Outputs

No outputs.

## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: 0.3.0

### <a name="module_node-app"></a> [node-app](#module\_node-app)

Source: ../../

Version:

### <a name="module_python-app"></a> [python-app](#module\_python-app)

Source: ../../

Version:

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->