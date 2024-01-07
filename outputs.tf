output "id" {
  description = "The ID of the Container App."
  value       = azapi_resource.container_app.id
}

output "name" {
  description = "The name of the Container App."
  value       = azapi_resource.container_app.name
}

output "resource" {
  description = "The Container Apps resource."
  value       = azapi_resource.container_app
}
