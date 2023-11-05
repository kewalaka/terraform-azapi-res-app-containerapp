locals {
  location                           = var.location != null ? var.location : data.azurerm_resource_group.rg.location
  role_definition_resource_substring = "/providers/Microsoft.Authorization/roleDefinitions"
}
