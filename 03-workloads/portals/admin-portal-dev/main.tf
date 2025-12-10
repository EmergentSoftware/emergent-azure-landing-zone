# =============================================================================
# Admin Portal Dev Workload - Static Website Storage
# This demonstrates deploying a static HTML site using blob storage
# =============================================================================

# =============================================================================
# Static Site Storage Pattern Module
# =============================================================================

module "static_site" {
  source = "../../../shared-modules/pattern-modules/static-site-storage"

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  environment     = var.environment
  location        = var.location
  naming_suffix   = ["portals", "admin", var.workload_name, var.environment]
  purpose         = "Admin Portal Static Site"

  storage_account_tier     = var.storage_account_tier
  storage_replication_type = var.storage_replication_type
  index_document           = var.index_document
  error_404_document       = var.error_404_document

  tags = var.tags
  common_tags = {
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"
  }
}

resource "azurerm_linux_virtual_machine" "my_linux_vm" {
  location            = "eastus"
  name                = "test"
  resource_group_name = "test"
  admin_username      = "testuser"
  admin_password      = "Testpa5s"

  size = "Standard_F16s" # <<<<<<<<<< Try changing this to Standard_F16s_v2 to compare the costs

  tags = {
    Environment = "production"
    Service     = "web-app"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface_ids = [
    "/subscriptions/123/resourceGroups/testrg/providers/Microsoft.Network/networkInterfaces/testnic",
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}
