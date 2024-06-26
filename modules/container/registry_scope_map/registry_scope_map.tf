resource "azurerm_container_registry_scope_map" "res-3" {
  actions                 = var.actions
  container_registry_name = var.container_registry_name
  description             = "Can pull any repository of the registry"
  name                    = var.name
  resource_group_name     = var.resource_group_name
}