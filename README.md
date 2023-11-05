<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-container-apps

This is a repo for Container Apps in the style of Azure Verified Modules (AVM), it is an 'unofficial' example that has been used for learning AVM.

Note this uses the AZAPI provider because of support missing within the AzureRM provider for [workload profiles](https://github.com/hashicorp/terraform-provider-azurerm/issues/21747).

Once required functionality is available within AzureRM, [azapi2azurerm](https://github.com/Azure/azapi2azurerm) can be used to convert this code.

This project includes [examples](./examples/) showing default settings and an example from Microsoft Learn illustrating Dapr.

Things to do:

1. Set up a GitHub repo environment called `test`.
1. Configure environment protection rule to ensure that approval is required before deploying to this environment.
1. Create a user-assigned managed identity in your test subscription.
1. Create a role assignment for the managed identity on your test subscription, use the minimum required role.
1. Configure federated identity credentials on the user assigned managed identity. Use the GitHub environment.
1. Create the following environment secrets on the `test` environment:
   1. AZURE\_CLIENT\_ID
   1. AZURE\_TENANT\_ID
   1. AZURE\_SUBSCRIPTION\_ID

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (1.9.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (1.9.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (3.71.0)

- <a name="provider_random"></a> [random](#provider\_random) (3.5.0)

## Resources

The following resources are used by this module:

- [azapi_resource.container_app](https://registry.terraform.io/providers/Azure/azapi/1.9.0/docs/resources/resource) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_container_app_environment_resource_id"></a> [container\_app\_environment\_resource\_id](#input\_container\_app\_environment\_resource\_id)

Description: Resource ID of environment.

Type: `string`

### <a name="input_container_apps"></a> [container\_apps](#input\_container\_apps)

Description: Specifies the container apps in the managed environment.

Type:

```hcl
list(object({
    name          = string
    revision_mode = optional(string, "Single")

    dapr = optional(object({
      appId              = optional(string)
      appPort            = optional(number)
      appProtocol        = optional(string)
      enableApiLogging   = optional(bool)
      enabled            = optional(bool)
      httpMaxRequestSize = optional(number)
      httpReadBufferSize = optional(number)
      logLevel           = optional(string)
    }))
    ingress = optional(object({
      allowInsecure         = optional(bool)
      clientCertificateMode = optional(string)
      corsPolicy = optional(object({
        allowCredentials = optional(bool)
        allowedHeaders   = optional(list(string))
        allowedMethods   = optional(list(string))
        allowedOrigins   = optional(list(string))
        exposeHeaders    = optional(list(string))
        maxAge           = optional(number)
      }))
      customDomains = optional(list(object({
        bindingType   = optional(string)
        certificateId = optional(string)
        name          = optional(string)
      })))
      exposedPort = optional(number)
      external    = optional(bool)
      ipSecurityRestrictions = optional(list(object({
        action         = optional(string)
        description    = optional(string)
        ipAddressRange = optional(string)
        name           = optional(string)
      })))
      stickySessions = optional(object({
        affinity = optional(string)
      }))
      targetPort = optional(number)
      traffic = optional(list(object({
        label          = optional(string)
        latestRevision = optional(bool)
        revisionName   = optional(string)
        weight         = optional(number)
      })))
      transport = optional(string)
    }))
    maxInactiveRevisions = optional(number)
    registries = optional(list(object({
      identity          = optional(string)
      passwordSecretRef = optional(string)
      server            = optional(string)
      username          = optional(string)
    })))
    secrets = optional(list(object({
      identity    = optional(string)
      keyVaultUrl = optional(string)
      name        = string
      value       = string
    })))
    service = optional(object({
      type = optional(string)
    }))

    template = object({
      containers = list(object({
        args    = optional(list(string))
        command = optional(list(string))
        env = optional(list(object({
          name      = string
          secretRef = optional(string)
          value     = optional(string)
        })))
        image = string
        name  = string
        probes = optional(list(object({
          failureThreshold = optional(number)
          httpGet = optional(object({
            host = optional(string)
            httpHeaders = optional(list(object({
              name  = string
              value = string
            })))
            path   = optional(string)
            port   = optional(number)
            scheme = optional(string)
          }))
          initialDelaySeconds = optional(number)
          periodSeconds       = optional(number)
          successThreshold    = optional(number)
          tcpSocket = optional(object({
            host = optional(string)
            port = optional(number)
          }))
          terminationGracePeriodSeconds = optional(number)
          timeoutSeconds                = optional(number)
          type                          = optional(string)
        })))
        resources = optional(object({
          cpu    = optional(string)
          memory = optional(string)
        }))
        volumeMounts = optional(list(object({
          mountPath  = optional(string)
          subPath    = optional(string)
          volumeName = optional(string)
        })))
      }))
      initContainers = optional(list(object({
        args    = optional(list(string))
        command = optional(list(string))
        env = optional(list(object({
          name      = string
          secretRef = optional(string)
          value     = optional(string)
        })))
        image = string
        name  = string
        resources = optional(object({
          cpu    = optional(string)
          memory = optional(string)
        }))
        volumeMounts = optional(list(object({
          mountPath  = optional(string)
          subPath    = optional(string)
          volumeName = optional(string)
        })))
      })))
      revisionSuffix = optional(string, null)
      scale = optional(object({
        maxReplicas = optional(number)
        minReplicas = optional(number)
        rules = optional(list(object({
          azureQueue = optional(object({
            auth = optional(list(object({
              secretRef        = string
              triggerParameter = string
            })))
            queueLength = optional(number)
            queueName   = optional(string)
          }))
          custom = optional(object({
            auth = optional(list(object({
              secretRef        = string
              triggerParameter = string
            })))
            metadata = optional(map(string))
            type     = optional(string)
          }))
          http = optional(object({
            auth = optional(list(object({
              secretRef        = string
              triggerParameter = string
            })))
            metadata = optional(map(string))
          }))
          name = optional(string)
          tcp = optional(object({
            auth = optional(list(object({
              secretRef        = string
              triggerParameter = string
            })))
            metadata = optional(map(string))
          }))
        })))
      }))
      serviceBinds = optional(list(object({
        name      = string
        serviceId = string
      })))
      volumes = optional(list(object({
        mountOptions = string
        name         = string
        secrets = optional(list(object({
          path      = string
          secretRef = string
        })))
        storageName = string
        storageType = string
      })))
    })
  }))
```

### <a name="input_name"></a> [name](#input\_name)

Description: Name for the resource.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: The resource group where the resources will be deployed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dapr_components"></a> [dapr\_components](#input\_dapr\_components)

Description: Specifies the dapr components in the managed environment.

Type:

```hcl
list(object({
    name          = string
    componentType = string
    version       = string
    ignoreErrors  = optional(bool)
    initTimeout   = string
    secrets = optional(list(object({
      name  = string
      value = any
    })))
    metadata = optional(list(object({
      name      = string
      value     = optional(any)
      secretRef = optional(any)
    })))
    scopes = optional(list(string))
  }))
```

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see <https://aka.ms/avm/telemetryinfo>.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `false`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Custom tags to apply to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_user_identity_resource_id"></a> [user\_identity\_resource\_id](#input\_user\_identity\_resource\_id)

Description: The managed identity definition for this resource.

Type: `string`

Default: `""`

### <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name)

Description: Workload profile name to pin for container app execution.  If not set, workload profiles are not used.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The Container Apps resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->