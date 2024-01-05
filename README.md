<!-- BEGIN_TF_DOCS -->
# terraform-azurerm-avm-res-container-apps

This is a repo for Container Apps in the style of Azure Verified Modules (AVM), it is an 'unofficial' example that has been used for learning AVM.

> [!WARNING]
> Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

This project uses the AZAPI provider because of support missing within the AzureRM provider for [workload profiles](https://github.com/hashicorp/terraform-provider-azurerm/issues/21747).

Once container apps support stablises in the Azure RM provider, [azapi2azurerm](https://github.com/Azure/azapi2azurerm) can be used to convert this code.

This project includes [examples](./examples/) showing default settings and an example from Microsoft Learn illustrating Dapr.

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.0)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (1.9.0, < 2.0.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>= 3.71.0, < 4.0.0)

- <a name="requirement_random"></a> [random](#requirement\_random) (>= 3.5.0, < 4.0.0)

## Providers

The following providers are used by this module:

- <a name="provider_azapi"></a> [azapi](#provider\_azapi) (1.9.0, < 2.0.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>= 3.71.0, < 4.0.0)

- <a name="provider_random"></a> [random](#provider\_random) (>= 3.5.0, < 4.0.0)

## Resources

The following resources are used by this module:

- [azapi_resource.container_app](https://registry.terraform.io/providers/Azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_resource_group_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [random_id.telem](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_environment_resource_id"></a> [environment\_resource\_id](#input\_environment\_resource\_id)

Description: The ID of the Container App Environment to host this Container App.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Container App.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Required) The name of the resource group in which the Container App Environment is to be created. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_template"></a> [template](#input\_template)

Description:   
Template properties:

- `maxReplicas` - (Optional) The maximum number of replicas for this container.
- `minReplicas` - (Optional) The minimum number of replicas for this container.
- `revisionSuffix` - (Optional) The suffix for the revision. This value must be unique for the lifetime of the Resource. If omitted the service will use a hash function to create one.

---
`containers` block supports the following:
- `args` - (Optional) A list of extra arguments to pass to the container.
- `command` - (Optional) A command to pass to the container to override the default. This is provided as a list of command line elements without spaces.
- `cpu` - (Required) The amount of vCPU to allocate to the container. Possible values include `0.25`, `0.5`, `0.75`, `1.0`, `1.25`, `1.5`, `1.75`, and `2.0`.
- `image` - (Required) The image to use to create the container.
- `memory` - (Required) The amount of memory to allocate to the container. Possible values are `0.5Gi`, `1Gi`, `1.5Gi`, `2Gi`, `2.5Gi`, `3Gi`, `3.5Gi`, and `4Gi`.
- `name` - (Required) The name of the container.
- `probes` - (Optional) List of probes for the container.
  - `failureThreshold` - (Optional) The number of consecutive failures required to consider this probe as failed. Possible values are between `1` and `10`. Defaults to `3`.
  - `httpGet` - (Optional) HTTP probe configuration.
      - `host` - (Optional) The probe hostname. Defaults to the pod IP address. Setting a value for `Host` in `headers` can be used to override this for `HTTP` and `HTTPS` type probes.
      - `httpHeaders` - (Optional) List of HTTP headers for the probe.
        - `name` - (Required) The HTTP Header Name.
        - `value` - (Required) The HTTP Header value.
      - `path` - (Optional) The URI to use for http type probes. Not valid for `TCP` type probes. Defaults to `/`.
      - `port` - (Required) The port number on which to connect. Possible values are between `1` and `65535`.
      - `scheme` - (Optional) The scheme for the probe. Possible values are `HTTP` and `HTTPS`.
  - `initialDelaySeconds` - (Optional) The time in seconds to wait after the container has started before the probe is started.
  - `periodSeconds` - (Optional) How often, in seconds, the probe should run. Possible values are in the range `1`.
  - `successThreshold` - (Optional) The number of consecutive successful responses required to consider this probe as successful. Possible values are between `1` and `10`. Defaults to `3`.
  - `tcpSocket` - (Optional) TCP probe configuration.
      - `host` - (Optional) The host for the TCP probe.
      - `port` - (Optional) The port for the TCP probe.
  - `terminationGracePeriodSeconds` - (Optional) Time in seconds after the probe times out.
  - `timeoutSeconds` - (Optional) Time in seconds after which the probe times out.
  - `type` - (Optional) Type of probe. Possible values are `TCP`, `HTTP`, and `HTTPS`.
- `resources` - (Optional) Resource configuration for the container.
  - `cpu` - (Optional) The amount of CPU to allocate to the container.
  - `memory` - (Optional) The amount of memory to allocate to the container.
- `volumeMounts` - (Optional) List of volume mounts for the container.
  - `mountPath` - (Optional) The path in the container at which to mount this volume.
  - `subPath` - (Optional) Subpath within the volume from which the container's volume should be mounted.
  - `volumeName` - (Optional) The name of the volume to mount.

---
`initContainers` block supports the following:
- `args` - (Optional) A list of extra arguments to pass to the container.
- `command` - (Optional) A command to pass to the container to override the default. This is provided as a list of command line elements without spaces.
- `cpu` - (Required) The amount of vCPU to allocate to the container. Possible values include `0.25`, `0.5`, `0.75`, `1.0`, `1.25`, `1.5`, `1.75`, and `2.0`.
- `image` - (Required) The image to use to create the container.
- `memory` - (Required) The amount of memory to allocate to the container. Possible values are `0.5Gi`, `1Gi`, `1.5Gi`, `2Gi`, `2.5Gi`, `3Gi`, `3.5Gi`, and `4Gi`.
- `name` - (Required) The name of the container.
- `resources` - (Optional) Resource configuration for the container.
  - `cpu` - (Optional) The amount of CPU to allocate to the container.
  - `memory` - (Optional) The amount of memory to allocate to the container.
- `volumeMounts` - (Optional) List of volume mounts for the container.
  - `mountPath` - (Optional) The path in the container at which to mount this volume.
  - `subPath` - (Optional) Subpath within the volume from which the container's volume should be mounted.
  - `volumeName` - (Optional) The name of the volume to mount.

---
`scale` block supports the following:
- `maxReplicas` - (Optional) The maximum number of replicas for this container.
- `minReplicas` - (Optional) The minimum number of replicas for this container.
- `rules` - (Optional) List of scaling rules.
  - `name` - (Optional) The name of the Scaling Rule.
  - `azureQueue` - (Optional) Azure Queue scaling rule configuration.
      - `auth` - (Optional) Authentication configuration for the rule.
        - `secretRef` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
        - `triggerParameter` - (Required) The Trigger Parameter name to use to supply the value retrieved from the `secretRef`.
      - `queueLength` - (Required) The value of the length of the queue to trigger scaling actions.
      - `queueName` - (Required) The name of the Azure Queue.
  - `custom` - (Optional) Custom scaling rule configuration.
      - `auth` - (Optional) Authentication configuration for the rule.
        - `secretRef` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
        - `triggerParameter` - (Required) The Trigger Parameter name to use to supply the value retrieved from the `secretRef`.
      - `metadata` - (Optional) Metadata for the custom scaling rule.
      - `type` - (Optional) The type of the custom scaling rule.
  - `http` - (Optional) HTTP scaling rule configuration.
      - `auth` - (Optional) Authentication configuration for the rule.
        - `secretRef` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
        - `triggerParameter` - (Required) The Trigger Parameter name to use to supply the value retrieved from the `secretRef`.
      - `metadata` - (Optional) Metadata for the HTTP scaling rule.
  - `name` - (Optional) The name of the Scaling Rule.
  - `tcp` - (Optional) TCP scaling rule configuration.
      - `auth` - (Optional) Authentication configuration for the rule.
        - `secretRef` - (Required) The name of the Container App Secret to use for this Scale Rule Authentication.
        - `triggerParameter` - (Required) The Trigger Parameter name to use to supply the value retrieved from the `secretRef`.
      - `metadata` - (Optional) Metadata for the TCP scaling rule.

---
- `serviceBinds` - (Optional) List of service binds.
  - `name` - (Required) The name of the service bind.
  - `serviceId` - (Required) The ID of the service.

---
- `volumes` - (Optional) List of volumes.
  - `mountOptions` - (Required) Mount options for the volume.
  - `name` - (Required) The name of the volume.
  - `secrets` - (Optional) List of secrets for the volume.
      - `path` - (Required) The path for the secret.
      - `secretRef` - (Required) The name of the secret.
  - `storageName` - (Required) The name of the AzureFile storage.
  - `storageType` - (Required) The type of storage volume. Possible values are `AzureFile`, `EmptyDir`, and `Secret`.

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_dapr"></a> [dapr](#input\_dapr)

Description: - `app_id` - (Optional) The Dapr Application Identifier.
- `app_port` - (Optional) The port which the application is listening on. This is the same as the `ingress` port.
- `app_protocol` - (Optional) The protocol for the app. Possible values include `http` and `grpc`. Defaults to `http`.
- `enable_api_logging` - (Optional) Enable API logging. Defaults to `false`.
- `enabled` - (Optional) Enable Dapr for the application. Defaults to `false`.
- `http_max_request_size` - (Optional) The maximum allowed HTTP request size in bytes.
- `http_read_buffer_size` - (Optional) The size of the buffer used for reading the HTTP request body in bytes.
- `log_level` - (Optional) The log level for Dapr. Possible values include "debug", "info", "warn", "error", and "fatal".

Type:

```hcl
object({
    app_id                = optional(string)
    app_port              = optional(number)
    app_protocol          = optional(string, "http")
    enable_api_logging    = optional(bool, false)
    enabled               = optional(bool, false)
    http_max_request_size = optional(number)
    http_read_buffer_size = optional(number)
    log_level             = optional(string)
  })
```

Default: `null`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `false`

### <a name="input_ingress"></a> [ingress](#input\_ingress)

Description: This object defines the ingress properties for the container app:

---
- `allow_insecure_connections` - (Optional) Should this ingress allow insecure connections? Defaults to `false`.
- `client_certificate_mode` - (Optional) The mode for client certificate authentication. Possible values include `optional` and `required`. Defaults to `Ignore`.
- `exposed_port` - (Optional) The exposed port on the container for the Ingress traffic. Defaults to `0`.
- `external_enabled` - (Optional) Are connections to this Ingress from outside the Container App Environment enabled? Defaults to `false`.
- `target_port` - (Required) The target port on the container for the Ingress traffic. Defaults to `Auto`.
- `transport` - (Optional) The transport method for the Ingress. Possible values include `auto`, `http`, `http2`, and `tcp`. Defaults to `Auto`.

---
`cors_policy` block supports the following:
- `allow_credentials` - (Optional) Indicates whether the browser should include credentials when making a request. Defaults to `false`.
- `allowed_headers` - (Optional) List of headers that can be used when making the actual request.
- `allowed_methods` - (Optional) List of HTTP methods that can be used when making the actual request.
- `allowed_origins` - (Optional) List of origins that are allowed to access the resource.
- `expose_headers` - (Optional) List of response headers that can be exposed when making the actual request.
- `max_age` - (Optional) The maximum number of seconds the results of a preflight request can be cached.

---
`custom_domain` block supports the following:
- `certificate_binding_type` - (Optional) The Binding type. Possible values include `Disabled` and `SniEnabled`. Defaults to `Disabled`.
- `certificate_id` - (Optional) The ID of the Container App Environment Certificate.
- `name` - (Optional) The hostname of the Certificate. Must be the CN or a named SAN in the certificate.

---
`ip_restrictions` block supports the following:
- `action` - (Optional) The action to take when the IP security restriction is triggered. Possible values include `allow` and `deny`.
- `description` - (Optional) A description for the IP security restriction.
- `ip_range` - (Optional) The IP address range for the security restriction.
- `name` - (Optional) The name for the IP security restriction.

---
`sticky_sessions` block supports the following:
- `affinity` - (Optional) The affinity type for sticky sessions. Possible values include `None`, `ClientIP`, and `Server`.

---
`traffic_weight` block supports the following:
- `label` - (Optional) The label to apply to the revision as a name prefix for routing traffic.
- `latest_revision` - (Optional) This traffic Weight relates to the latest stable Container Revision.
- `revision_suffix` - (Optional) The suffix string to which this `traffic_weight` applies.
- `percentage` - (Required) The percentage of traffic which should be sent according to this configuration.

Type:

```hcl
object({
    allow_insecure_connections = optional(bool, false)
    client_certificate_mode    = optional(string, "Ignore")
    cors_policy = optional(object({
      allow_credentials = optional(bool, false)
      allowed_headers   = optional(list(string))
      allowed_methods   = optional(list(string))
      allowed_origins   = optional(list(string))
      expose_headers    = optional(list(string))
      max_age           = optional(number)
    }), null)
    custom_domain = optional(list(object({
      certificate_binding_type = optional(string)
      certificate_id           = optional(string)
      name                     = optional(string)
    })), null)
    exposed_port     = optional(number, 0)
    external_enabled = optional(bool, false)
    ip_restrictions = optional(list(object({
      action      = optional(string)
      description = optional(string)
      ip_range    = optional(string)
      name        = optional(string)
    })))
    sticky_sessions = optional(object({
      affinity = optional(string, "none")
    }))
    target_port = optional(number)
    traffic_weight = optional(list(object({
      label           = optional(string)
      latest_revision = optional(bool, true)
      revision_suffix = optional(string)
      percentage      = optional(number, 100)
    })))
    transport = optional(string, "Auto")
  })
```

Default: `null`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.  If null, the location will be inferred from the resource group location.

Type: `string`

Default: `null`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: The lock level to apply to the resource. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`.

Type:

```hcl
object({
    name = optional(string, null)
    kind = optional(string, "None")
  })
```

Default: `{}`

### <a name="input_managed_identities"></a> [managed\_identities](#input\_managed\_identities)

Description: Configurations for managed identities in Azure. This variable allows you to specify both system-assigned and user-assigned managed identities for resources that support identity-based authentication.

- `system_assigned` - (Optional) A boolean flag indicating whether to enable the system-assigned managed identity. Defaults to `false`.
- `user_assigned_resource_ids` - (Optional) A set of user-assigned managed identity resource IDs to be associated with the resource.

Type:

```hcl
object({
    system_assigned            = optional(bool, false)
    user_assigned_resource_ids = optional(set(string), [])
  })
```

Default: `{}`

### <a name="input_max_inactive_revisions"></a> [max\_inactive\_revisions](#input\_max\_inactive\_revisions)

Description: (Optional). Max inactive revisions a Container App can have.

Type: `number`

Default: `2`

### <a name="input_registry"></a> [registry](#input\_registry)

Description:
- `identity` - (Optional) Resource ID for the User Assigned Managed identity to use when pulling from the Container Registry.
- `password_secret_name ` - (Optional) The name of the Secret Reference containing the password value for this user on the Container Registry, `username` must also be supplied.
- `server` - (Optional) The hostname for the Container Registry.
- `username` - (Optional) The username to use for this Container Registry, `password_secret_name` must also be supplied.

Type:

```hcl
list(object({
    identity             = optional(string)
    password_secret_name = optional(string)
    server               = optional(string)
    username             = optional(string)
  }))
```

Default: `null`

### <a name="input_revision_mode"></a> [revision\_mode](#input\_revision\_mode)

Description: (Required) The revisions operational mode for the Container App. Possible values include `Single` and `Multiple`. In `Single` mode, a single revision is in operation at any given time. In `Multiple` mode, more than one revision can be active at a time and can be configured with load distribution via the `traffic_weight` block in the `ingress` configuration.

Type: `string`

Default: `"Single"`

### <a name="input_role_assignments"></a> [role\_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on the Container Registry. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

  - `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
  - `principal_id` - The ID of the principal to assign the role to.
  - `description` - The description of the role assignment.
  - `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
  - `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

  > Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:

```hcl
map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
```

Default: `{}`

### <a name="input_secret"></a> [secret](#input\_secret)

Description:
- `identity` - (Optional) The identity associated with the secret.
- `keyVaultUrl` - (Optional) The URL of the Azure Key Vault containing the secret. Required when `identity` is specified.
- `name` - (Required) The Secret name.
- `value` - (Required) The value for this secret.

Type:

```hcl
set(object({
    identity    = optional(string)
    keyVaultUrl = optional(string)
    name        = string
    value       = string
  }))
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Custom tags to apply to the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: - `create` - (Defaults to 30 minutes) Used when creating the Container App.
- `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
- `read` - (Defaults to 5 minutes) Used when retrieving the Container App.
- `update` - (Defaults to 30 minutes) Used when updating the Container App.

Type:

```hcl
object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
```

Default: `null`

### <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name)

Description: Workload profile name to pin for container app execution.  If not set, workload profiles are not used.

Type: `string`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Container App.

### <a name="output_name"></a> [name](#output\_name)

Description: The name of the Container App.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The Container Apps resource.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->