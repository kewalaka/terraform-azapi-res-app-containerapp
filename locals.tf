locals {
  location = var.location != null ? var.location : data.azurerm_resource_group.rg.location
}
