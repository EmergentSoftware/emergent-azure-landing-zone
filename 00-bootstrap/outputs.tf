# =============================================================================
# Bootstrap Outputs
# These values are used to configure backend in other Terraform layers
# =============================================================================

output "resource_group_name" {
  description = "Name of the resource group containing state storage"
  value       = module.resource_group.name
}

output "storage_account_name" {
  description = "Name of the storage account for Terraform state"
  value       = module.storage_account.name
}

output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = module.storage_account.resource_id
}

output "containers" {
  description = "Map of all created containers"
  value = {
    for name in var.containers : name => {
      name = module.containers[name].name
      id   = module.containers[name].resource_id
    }
  }
}

output "backend_config_foundation" {
  description = "Backend configuration for 01-foundation layer"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-foundation"].name
    key                  = "foundation.tfstate"
  }
}

output "backend_config_workloads" {
  description = "Backend configuration for workloads"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-workloads"].name
    key                  = "workloads.tfstate"
  }
}

output "backend_config_portal_dev" {
  description = "Backend configuration for portal dev workload"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-portal-dev"].name
    key                  = "portal-dev.tfstate"
  }
}

output "backend_config_portal_prod" {
  description = "Backend configuration for portal prod workload"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-portal-prod"].name
    key                  = "portal-prod.tfstate"
  }
}

# Instructions for using remote backend
output "instructions" {
  description = "Instructions for configuring remote backend in other layers"
  value       = <<-EOT

  ========================================
  Terraform State Storage Setup Complete
  ========================================

  Add this backend configuration to your Terraform layers:

  ### For 01-foundation/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "${module.foundation_container.name}"
      key                  = "foundation.tfstate"
    }
  }

  ### For 02-landing-zones/corp/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "${module.corp_container.name}"
      key                  = "corp.tfstate"
    }
  }

  ### For 03-workloads/portal (dev):

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "${module.portal_dev_container.name}"
      key                  = "portal-dev.tfstate"
    }
  }

  ### For 03-workloads/portal (prod):

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "${module.portal_prod_container.name}"
      key                  = "portal-prod.tfstate"
    }
  }

  ========================================
  Storage Account: ${module.storage_account.name}
  Resource Group:  ${module.resource_group.name}
  Location:        ${var.location}
  ========================================

  EOT
}
