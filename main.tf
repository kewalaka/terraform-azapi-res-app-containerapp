data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "container_app" {
  type = "Microsoft.App/containerApps@2023-05-01"
  body = jsonencode({
    properties = {
      configuration = {
        activeRevisionsMode = var.revision_mode
        dapr                = var.dapr
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
        registries           = var.registry
        secrets              = var.secret
        #service              = var.service
      }
      environmentId       = var.environment_resource_id
      template            = var.template
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
