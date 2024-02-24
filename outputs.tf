output "id" {
  description = "The ID of the Container App."
  value       = azapi_resource.container_app.id
}

output "name" {
  description = "The name of the Container App."
  value       = azapi_resource.container_app.name
}

output "resource" {
  description = "The Container App resource."
  value = {
    id                  = azapi_resource.container_app.id
    name                = azapi_resource.container_app.name
    location            = azapi_resource.container_app.location
    resource_group_name = data.azurerm_resource_group.rg.name

    container_app_environment_id = jsondecode(azapi_resource.container_app.output).properties.environmentId

    revision_mode                 = jsondecode(azapi_resource.container_app.output).properties.activeRevisionsMode
    workload_profile_name         = try(jsondecode(azapi_resource.container_app.output).properties.workloadProfileName, null)
    custom_domain_verification_id = try(jsondecode(azapi_resource.container_app.output).properties.custom_domain_verification_id, null)

    secret   = local.secrets
    template = local.templates

    #
    #dapr
    #identity
    #ingress
    #registry
    #

    tags = azapi_resource.container_app.tags
  }
}
