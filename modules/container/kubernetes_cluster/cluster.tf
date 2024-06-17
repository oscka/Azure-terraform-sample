resource "azurerm_kubernetes_cluster" "cluster" {
  # automatic_channel_upgrade = "patch"
  dns_prefix                = var.dns_prefix
  location                  = var.location
  name                      = var.name
  resource_group_name       = var.resource_group_name
  default_node_pool {
    enable_auto_scaling = true
    max_count           = var.max_count
    min_count           = var.min_count
    name                = var.default_nodepool_name
    os_disk_type        = var.os_disk_type
    vm_size             = var.vm_size
    upgrade_settings {
      max_surge = var.upgrade_max_surge
    }
  }
  identity {
    type = "SystemAssigned"
  }
  # maintenance_window_auto_upgrade {
  #   day_of_week = "Sunday"
  #   duration    = 4
  #   frequency   = "Weekly"
  #   interval    = 1
  #   start_time  = "00:00"
  #   utc_offset  = "+00:00"
  # }
  # maintenance_window_node_os {
  #   day_of_week = "Sunday"
  #   duration    = 4
  #   frequency   = "Weekly"

  #   interval   = 1
  #   start_time = "00:00"
  #   utc_offset = "+00:00"
  # }
  # depends_on = [
  #   azurerm_resource_group.res-0,
  # ]
  
}
