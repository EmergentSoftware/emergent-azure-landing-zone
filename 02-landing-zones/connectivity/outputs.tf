output "management_group_id" {
  description = "The ID of the connectivity management group"
  value       = data.azurerm_management_group.connectivity.id
}

output "subscription_association_id" {
  description = "The ID of the subscription association"
  value       = azurerm_management_group_subscription_association.connectivity.id
}

output "subscription_id" {
  description = "The connectivity subscription ID"
  value       = var.subscription_id
}

# Network outputs
output "hub_vnet_id" {
  description = "The ID of the hub virtual network"
  value       = module.hub_vnet.resource_id
}

output "hub_vnet_name" {
  description = "The name of the hub virtual network"
  value       = module.hub_vnet.name
}

output "hub_vnet_address_space" {
  description = "The address space of the hub virtual network"
  value       = module.hub_vnet.address_space
}

output "network_resource_group_name" {
  description = "The name of the network resource group"
  value       = module.network_resource_group.name
}

output "network_resource_group_id" {
  description = "The ID of the network resource group"
  value       = module.network_resource_group.resource_id
}

# Private DNS Zone outputs
output "private_dns_resource_group_name" {
  description = "The name of the private DNS zones resource group"
  value       = module.private_dns_resource_group.name
}

output "private_dns_resource_group_id" {
  description = "The ID of the private DNS zones resource group"
  value       = module.private_dns_resource_group.resource_id
}

output "private_dns_zones" {
  description = "Map of private DNS zone IDs"
  value = {
    static_web_apps    = azurerm_private_dns_zone.static_web_apps.id
    storage_blob       = azurerm_private_dns_zone.storage_blob.id
    storage_file       = azurerm_private_dns_zone.storage_file.id
    storage_table      = azurerm_private_dns_zone.storage_table.id
    storage_queue      = azurerm_private_dns_zone.storage_queue.id
    sql_database       = azurerm_private_dns_zone.sql_database.id
    cosmos_sql         = azurerm_private_dns_zone.cosmos_sql.id
    key_vault          = azurerm_private_dns_zone.key_vault.id
    app_service        = azurerm_private_dns_zone.app_service.id
    container_registry = azurerm_private_dns_zone.container_registry.id
    service_bus        = azurerm_private_dns_zone.service_bus.id
  }
}

