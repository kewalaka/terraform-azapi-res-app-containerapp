data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azapi_resource" "container_app" {
  for_each                  = { for app in var.container_apps : app.name => app }
  type                      = "Microsoft.App/containerApps@2023-05-01"
  schema_validation_enabled = false
  name                      = var.name
  parent_id                 = data.azurerm_resource_group.rg.id
  location                  = local.location
  tags                      = var.tags
  # identity {
  #   type         = var.user_identity_resource_id == "" ? "SystemAssigned" : "SystemAssigned, UserAssigned"
  #   identity_ids = var.user_identity_resource_id == "" ? [] : [var.user_identity_resource_id]
  # }

  body = jsonencode({
    properties = {
      configuration = {
        activeRevisionsMode  = try(each.value.revision_mode, "Single")
        dapr                 = try(each.value.dapr, null)
        ingress              = try(each.value.ingress, null)
        maxInactiveRevisions = try(each.value.maxInactiveRevisions, null)
        registries           = try(each.value.registries, null)
        secrets              = try(each.value.secrets, null)
        service              = try(each.value.service, null)
      }
      environmentId       = var.container_app_environment_resource_id
      template            = each.value.template
      workloadProfileName = var.workload_profile_name
    }
  })

  response_export_values = ["identity"]
}

# resource "azurerm_management_lock" "this" {
#   count      = var.lock.kind != "None" ? 1 : 0
#   name       = coalesce(var.lock.name, "lock-${var.name}")
#   scope      = azapi_resource.container_app.id
#   lock_level = var.lock.kind
# }

# resource "azurerm_role_assignment" "this" {
#   for_each                               = var.role_assignments
#   scope                                  = azapi_resource.container_app.id
#   role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
#   role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
#   principal_id                           = each.value.principal_id
#   condition                              = each.value.condition
#   condition_version                      = each.value.condition_version
#   skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
#   delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
# }
