variable "name" {
  type        = string
  description = "Name for the resource."
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Custom tags to apply to the resource."
  default     = {}
}

variable "user_identity_resource_id" {
  type        = string
  description = "The managed identity definition for this resource."
  default     = ""
}

variable "container_app_environment_resource_id" {
  type        = string
  description = "Resource ID of environment."
}

variable "workload_profile_name" {
  type        = string
  description = "Workload profile name to pin for container app execution.  If not set, workload profiles are not used."
  default     = null
}

variable "container_app" {
  description = "Specifies the container apps in the managed environment."
  type = object({
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
  })
}
