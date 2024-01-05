variable "environment_resource_id" {
  type        = string
  description = "The ID of the Container App Environment to host this Container App."
  nullable    = false
}

variable "max_inactive_revisions" {
  type        = number
  description = "(Optional). Max inactive revisions a Container App can have."
  default     = 2
}

variable "revision_mode" {
  type        = string
  description = "(Required) The revisions operational mode for the Container App. Possible values include `Single` and `Multiple`. In `Single` mode, a single revision is in operation at any given time. In `Multiple` mode, more than one revision can be active at a time and can be configured with load distribution via the `traffic_weight` block in the `ingress` configuration."
  default     = "Single"
}

# variable "service" {
#   type        = string
#   description = "Container App to be a dev Container App Service"
#   default     = ""
# }

variable "template" {
  type = object({
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
  description = <<-EOT

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
EOT
  nullable    = false
}

variable "dapr" {
  type = object({
    appId              = optional(string)
    appPort            = optional(number)
    appProtocol        = optional(string, "http")
    enableApiLogging   = optional(bool, false)
    enabled            = optional(bool, false)
    httpMaxRequestSize = optional(number)
    httpReadBufferSize = optional(number)
    logLevel           = optional(string)
  })
  default     = null
  description = <<-EOT
Dapr properties:

- `appId` - (Required) The Dapr Application Identifier.
- `appPort` - (Optional) The port on which the application is listening. This is the same as the `ingress` port.
- `appProtocol` - (Optional) The protocol for the app. Possible values include `http` and `grpc`. Defaults to `http`.
- `enableApiLogging` - (Optional) Enables Dapr API logging. Defaults to `false`.
- `enabled` - (Optional) Enables or disables Dapr for the application. Defaults to `false`.
- `httpMaxRequestSize` - (Optional) The maximum size of an HTTP request that Dapr will accept in bytes.
- `httpReadBufferSize` - (Optional) The buffer size for reading the request body in bytes.
- `logLevel` - (Optional) The log level for Dapr. Possible values include `trace`, `debug`, `info`, `warn`, `error`, and `fatal`.

EOT
}

variable "ingress" {
  type = object({
    allowInsecure         = optional(bool, false)
    clientCertificateMode = optional(string, "Ignore")
    corsPolicy = optional(object({
      allowCredentials = optional(bool, false)
      allowedHeaders   = optional(list(string))
      allowedMethods   = optional(list(string))
      allowedOrigins   = optional(list(string))
      exposeHeaders    = optional(list(string))
      maxAge           = optional(number)
    }), null)
    customDomains = optional(list(object({
      bindingType   = optional(string)
      certificateId = optional(string)
      name          = optional(string)
    })), null)
    exposedPort = optional(number, 0)
    external    = optional(bool, false)
    ipSecurityRestrictions = optional(list(object({
      action         = optional(string)
      description    = optional(string)
      ipAddressRange = optional(string)
      name           = optional(string)
    })))
    stickySessions = optional(object({
      affinity = optional(string, "none")
    }))
    targetPort = optional(number)
    traffic = optional(list(object({
      label          = optional(string)
      latestRevision = optional(bool, true)
      revisionName   = optional(string)
      weight         = optional(number, 100)
    })))
    transport = optional(string, "Auto")
  })
  default     = null
  description = <<-EOT
This object defines the ingress properties for the container app:

- `allowInsecure` - (Optional) Should this ingress allow insecure connections?
- `clientCertificateMode` - (Optional) The mode for client certificate authentication. Possible values include `optional` and `required`.
- `exposedPort` - (Optional) The exposed port on the container for the Ingress traffic.
- `external` - (Optional) Are connections to this Ingress from outside the Container App Environment enabled? Defaults to `false`.
- `targetPort` - (Required) The target port on the container for the Ingress traffic.
- `transport` - (Optional) The transport method for the Ingress. Possible values are `auto`, `http`, `http2`, and `tcp`. Defaults to `auto`.

---
- `corsPolicy` - (Optional) CORS (Cross-Origin Resource Sharing) policy configuration.
  - `allowCredentials` - (Optional) Indicates whether the browser should include credentials when making a request. Defaults to `false`.
  - `allowedHeaders` - (Optional) List of headers that can be used when making the actual request.
  - `allowedMethods` - (Optional) List of HTTP methods that can be used when making the actual request.
  - `allowedOrigins` - (Optional) List of origins that are allowed to access the resource.
  - `exposeHeaders` - (Optional) List of response headers that can be exposed when making the actual request.
  - `maxAge` - (Optional) The maximum number of seconds the results of a preflight request can be cached.

---
- `customDomains` - (Optional) List of custom domains for the Ingress.
  - `bindingType` - (Optional) The binding type. Possible values include `Disabled` and `SniEnabled`. Defaults to `Disabled`.
  - `certificateId` - (Optional) The ID of the Container App Environment Certificate.
  - `name` - (Optional) The hostname of the Certificate. Must be the CN or a named SAN in the certificate.

---
- `ipSecurityRestrictions` - (Optional) List of IP security restrictions for the Ingress.
  - `action` - (Optional) The action to take when the IP security restriction is triggered. Possible values include `allow` and `deny`.
  - `description` - (Optional) A description for the IP security restriction.
  - `ipAddressRange` - (Optional) The IP address range for the security restriction.
  - `name` - (Optional) The name for the IP security restriction.

---
- `stickySessions` - (Optional) Sticky sessions configuration for the Ingress.
  - `affinity` - (Optional) The affinity type for sticky sessions. Possible values include `None`, `ClientIP`, and `Server`.

---
- `traffic` - (Optional) List of traffic routing configurations for the Ingress.
  - `label` - (Optional) The label to apply to the revision as a name prefix for routing traffic.
  - `latestRevision` - (Optional) This traffic configuration relates to the latest stable Container Revision.
  - `percentage` - (Required) The percentage of traffic which should be sent according to this configuration.
  - `revisionName` - (Optional) The suffix string to which this traffic configuration applies.

EOT
}

variable "registry" {
  type = list(object({
    identity          = optional(string)
    passwordSecretRef = optional(string)
    server            = optional(string)
    username          = optional(string)
  }))
  default     = null
  description = <<-EOT
 - `identity` - (Optional) Resource ID for the User Assigned Managed identity to use when pulling from the Container Registry.
 - `passwordSecretRef` - (Optional) The name of the Secret Reference containing the password value for this user on the Container Registry, `username` must also be supplied.
 - `server` - (Required) The hostname for the Container Registry.
 - `username` - (Optional) The username to use for this Container Registry, `password_secret_name` must also be supplied..
EOT
}

variable "secret" {
  type = set(object({
    identity    = optional(string)
    keyVaultUrl = optional(string)
    name        = string
    value       = string
  }))
  default     = null
  description = <<-EOT

 - `identity` - (Optional) The identity associated with the secret.
 - `keyVaultUrl` - (Optional) The URL of the Azure Key Vault containing the secret. Required when `identity` is specified.
 - `name` - (Required) The Secret name.
 - `value` - (Required) The value for this secret.

EOT
}


variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  default     = null
  description = <<-EOT
 - `create` - (Defaults to 30 minutes) Used when creating the Container App.
 - `delete` - (Defaults to 30 minutes) Used when deleting the Container App.
 - `read` - (Defaults to 5 minutes) Used when retrieving the Container App.
 - `update` - (Defaults to 30 minutes) Used when updating the Container App.
EOT
}

variable "workload_profile_name" {
  type        = string
  description = "Workload profile name to pin for container app execution.  If not set, workload profiles are not used."
  default     = null
}
