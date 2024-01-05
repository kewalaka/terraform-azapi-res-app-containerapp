data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "container_app" {
  type = "Microsoft.App/containerApps@2023-05-01"
  body = jsonencode({
    properties = {
      configuration = {
        activeRevisionsMode  = var.revision_mode
        dapr                 = var.dapr
        ingress              = var.ingress
        maxInactiveRevisions = var.max_inactive_revisions
        #registries           = var.registry
        #secrets              = var.secret
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
