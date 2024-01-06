data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "container_app" {
  type = "Microsoft.App/containerApps@2023-05-01"
  body = jsonencode({
    properties = {
      configuration = {
        activeRevisionsMode = var.revision_mode
        dapr = var.dapr != null ? {
          appId              = var.dapr.app_id
          appPort            = var.dapr.app_port
          appProtocol        = var.dapr.app_protocol
          enableApiLogging   = var.dapr.enable_api_logging
          enabled            = var.dapr.enabled
          httpMaxRequestSize = var.dapr.http_max_request_size
          httpReadBufferSize = var.dapr.http_read_buffer_size
          logLevel           = var.dapr.log_level
        } : null
        ingress = var.ingress != null ? {
          allowInsecure         = var.ingress.allow_insecure_connections
          clientCertificateMode = var.ingress.client_certificate_mode
          exposedPort           = var.ingress.exposed_port
          external              = var.ingress.external_enabled
          targetPort            = var.ingress.target_port
          transport             = var.ingress.transport
          corsPolicy = var.ingress.cors_policy != null ? {
            allowCredentials = var.ingress.cors_policy.allow_credentials
            allowedHeaders   = var.ingress.cors_policy.allowed_headers
            allowedMethods   = var.ingress.cors_policy.allowed_methods
            allowedOrigins   = var.ingress.cors_policy.allowed_origins
            exposeHeaders    = var.ingress.cors_policy.expose_headers
            maxAge           = var.ingress.cors_policy.max_age
          } : null
          customDomains = var.ingress.custom_domain != null ? {
            bindingType   = var.ingress.custom_domain.certificate_binding_type
            certificateId = var.ingress.custom_domain.certificate_id
            name          = var.ingress.custom_domain.name
          } : null
          ipSecurityRestrictions = var.ingress.ip_restrictions != null ? {
            action         = var.ingress.ip_restrictions.action
            description    = var.ingress.ip_restrictions.description
            ipAddressRange = var.ingress.ip_restrictions.ip_range
            name           = var.ingress.ip_restrictions.name
          } : null
          stickySessions = var.ingress.sticky_sessions != null ? {
            affinity = var.ingress.sticky_sessions.affinity
          } : null
          traffic = var.ingress.traffic_weight != null ? {
            label          = var.ingress.traffic_weight.label
            latestRevision = var.ingress.traffic_weight.latest_revision
            revisionName   = var.ingress.traffic_weight.revision_suffix
            weight         = var.ingress.traffic_weight.percentage
          } : null
        } : null
        maxInactiveRevisions = var.max_inactive_revisions
        registries = var.registry != null ? [
          for reg in var.registry : {
            identity          = reg.identity
            passwordSecretRef = reg.password_secret_name
            server            = reg.server
            username          = reg.username
          }
        ] : null
        secrets = var.secret != null ? [
          for s in var.secret : {
            identity    = s.identity
            keyVaultUrl = s.key_vault_secret_id
            name        = s.name
            value       = s.value
          }
        ] : null
        #service              = var.service
      }
      environmentId = var.environment_resource_id
      template = {
        containers = [
          for cont in var.template.container : {
            args    = cont.args
            command = cont.command
            env = cont.env != null ? [
              for e in cont.env : {
                name      = e.name
                secretRef = e.secret_name
                value     = e.value
              }
            ] : null
            image = cont.image
            name  = cont.name
            probes = setunion(
              [
                for liveness_probe in try(cont.liveness_probe, []) : {
                  failureThreshold    = liveness_probe.failure_count_threshold
                  initialDelaySeconds = liveness_probe.initial_delay
                  periodSeconds       = liveness_probe.interval_seconds
                  timeoutSeconds      = liveness_probe.timeout
                  type                = "Liveness"
                  httpGet = liveness_probe.transport == "HTTP" || liveness_probe.transport == "HTTPS" ? {
                    host   = liveness_probe.host
                    path   = liveness_probe.path
                    port   = liveness_probe.port
                    scheme = liveness_probe.transport
                    httpHeaders = liveness_probe.header != null ? [
                      for header in liveness_probe.header : {
                        name  = header.name
                        value = header.value
                      }
                    ] : null
                  } : null
                  tcpSocket = liveness_probe.transport == "TCP" ? {
                    host = liveness_probe.host
                    port = liveness_probe.port
                  } : null
              }],
              [
                for readiness_probe in try(cont.readiness_probe, []) : {
                  failureThreshold    = readiness_probe.failure_count_threshold
                  initialDelaySeconds = readiness_probe.initial_delay
                  periodSeconds       = readiness_probe.interval_seconds
                  successThreshold    = readiness_probe.success_count_threshold
                  timeoutSeconds      = readiness_probe.timeout
                  type                = "Readiness"
                  httpGet = readiness_probe.transport == "HTTP" || readiness_probe.transport == "HTTPS" ? {
                    host   = readiness_probe.host
                    path   = readiness_probe.path
                    port   = readiness_probe.port
                    scheme = readiness_probe.transport
                    httpHeaders = readiness_probe.header != null ? [
                      for header in readiness_probe.header : {
                        name  = header.name
                        value = header.value
                      }
                    ] : null
                  } : null
                  tcpSocket = readiness_probe.transport == "TCP" ? {
                    host = readiness_probe.host
                    port = readiness_probe.port
                  } : null
              }],
              [
                for startup_probe in try(cont.startup_probe, []) : {
                  failureThreshold    = startup_probe.failure_count_threshold
                  initialDelaySeconds = startup_probe.initial_delay
                  periodSeconds       = startup_probe.interval_seconds
                  timeoutSeconds      = startup_probe.timeout
                  type                = "startup"
                  httpGet = startup_probe.transport == "HTTP" || startup_probe.transport == "HTTPS" ? {
                    host   = startup_probe.host
                    path   = startup_probe.path
                    port   = startup_probe.port
                    scheme = startup_probe.transport
                    httpHeaders = startup_probe.header != null ? [
                      for header in startup_probe.header : {
                        name  = header.name
                        value = header.value
                      }
                    ] : null
                  } : null
                  tcpSocket = startup_probe.transport == "TCP" ? {
                    host = startup_probe.host
                    port = startup_probe.port
                  } : null
              }]
            )
            resources = {
              cpu    = cont.cpu
              memory = cont.memory
            }
            volumeMounts = cont.volume_mounts != null ? [
              for vm in cont.volume_mounts : {
                mountPath  = vm.path
                subPath    = vm.sub_path
                volumeName = vm.name
              }
            ] : null
          }

        ]
        revisionSuffix = var.template.revision_suffix
        scale = {
          minReplicas = var.template.min_replicas
          maxReplicas = var.template.max_replicas
        }
      }
      workloadProfileName = var.workload_profile_name
    }
  })
  location                  = local.location
  name                      = var.name
  parent_id                 = data.azurerm_resource_group.rg.id
  response_export_values    = ["identity"]
  schema_validation_enabled = false
  tags                      = var.tags

  dynamic "identity" {
    for_each = var.managed_identities != null ? { this = var.managed_identities } : {}
    content {
      type         = identity.value.system_assigned && length(identity.value.user_assigned_resource_ids) > 0 ? "SystemAssigned, UserAssigned" : length(identity.value.user_assigned_resource_ids) > 0 ? "UserAssigned" : "SystemAssigned"
      identity_ids = identity.value.user_assigned_resource_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}

resource "azurerm_management_lock" "this" {
  count = var.lock.kind != "None" ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.name}")
  scope      = azapi_resource.container_app.id
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.container_app.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
