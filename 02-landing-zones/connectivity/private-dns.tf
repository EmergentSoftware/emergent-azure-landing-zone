# =============================================================================
# Private DNS Zones for Azure Private Link Services
# Centralized in Connectivity subscription for hub-and-spoke architecture
# =============================================================================

# Resource Group for Private DNS Zones
module "private_dns_resource_group" {
  source = "../../shared-modules/resource-group"

  name     = "${module.naming.resource_group.name}-privatedns"
  location = var.location
  tags = merge(
    local.common_tags,
    {
      Purpose = "Private DNS Zones"
    }
  )
}

# =============================================================================
# Azure Static Web Apps Private DNS Zone
# =============================================================================
resource "azurerm_private_dns_zone" "static_web_apps" {
  name                = "privatelink.azurestaticapps.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Static Web Apps"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "static_web_apps_hub" {
  name                  = "link-hub-static-web-apps"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.static_web_apps.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure Storage Private DNS Zones
# =============================================================================
resource "azurerm_private_dns_zone" "storage_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Storage - Blob"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_blob_hub" {
  name                  = "link-hub-storage-blob"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_blob.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "storage_file" {
  name                = "privatelink.file.core.windows.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Storage - File"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_file_hub" {
  name                  = "link-hub-storage-file"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_file.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "storage_table" {
  name                = "privatelink.table.core.windows.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Storage - Table"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_table_hub" {
  name                  = "link-hub-storage-table"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_table.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

resource "azurerm_private_dns_zone" "storage_queue" {
  name                = "privatelink.queue.core.windows.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Storage - Queue"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "storage_queue_hub" {
  name                  = "link-hub-storage-queue"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.storage_queue.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure SQL Database Private DNS Zone
# =============================================================================
resource "azurerm_private_dns_zone" "sql_database" {
  name                = "privatelink.database.windows.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure SQL Database"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_database_hub" {
  name                  = "link-hub-sql-database"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_database.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure Cosmos DB Private DNS Zones
# =============================================================================
resource "azurerm_private_dns_zone" "cosmos_sql" {
  name                = "privatelink.documents.azure.com"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Cosmos DB - SQL"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "cosmos_sql_hub" {
  name                  = "link-hub-cosmos-sql"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.cosmos_sql.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure Key Vault Private DNS Zone
# =============================================================================
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Key Vault"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_hub" {
  name                  = "link-hub-key-vault"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure App Service / Web Apps Private DNS Zone
# =============================================================================
resource "azurerm_private_dns_zone" "app_service" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure App Service"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "app_service_hub" {
  name                  = "link-hub-app-service"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.app_service.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure Container Registry Private DNS Zone
# =============================================================================
resource "azurerm_private_dns_zone" "container_registry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Container Registry"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry_hub" {
  name                  = "link-hub-container-registry"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.container_registry.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

# =============================================================================
# Azure Service Bus / Event Hub Private DNS Zone
# Note: Service Bus and Event Hub share the same private DNS zone
# =============================================================================
resource "azurerm_private_dns_zone" "service_bus" {
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = module.private_dns_resource_group.name

  tags = merge(
    local.common_tags,
    {
      Service = "Azure Service Bus / Event Hub"
    }
  )
}

resource "azurerm_private_dns_zone_virtual_network_link" "service_bus_hub" {
  name                  = "link-hub-service-bus"
  resource_group_name   = module.private_dns_resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.service_bus.name
  virtual_network_id    = module.hub_vnet.resource_id
  registration_enabled  = false

  tags = local.common_tags
}

