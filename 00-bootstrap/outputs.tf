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

output "foundation_container_name" {
  description = "Container name for foundation layer state"
  value       = module.foundation_container.name
}

output "landing_zones_container_name" {
  description = "Container name for landing zones layer state"
  value       = module.landing_zones_container.name
}

output "workloads_container_name" {
  description = "Container name for workloads layer state"
  value       = module.workloads_container.name
}

output "primary_access_key" {
  description = "Primary access key for the storage account (sensitive)"
  value       = module.storage_account.resource.primary_access_key
  sensitive   = true
}

output "backend_config_foundation" {
  description = "Backend configuration for 01-foundation layer"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.foundation_container.name
    key                  = "foundation.tfstate"
  }
}

output "backend_config_landing_zones" {
  description = "Backend configuration for 02-landing-zones layer"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.landing_zones_container.name
    key                  = "landing-zones.tfstate"
  }
}

output "backend_config_workloads" {
  description = "Backend configuration for 03-workloads layer"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.workloads_container.name
    key                  = "workloads.tfstate"
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

  ### For 02-landing-zones/*/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "${module.landing_zones_container.name}"
      key                  = "corp.tfstate"  # or "online.tfstate"
    }
  }

  ### For 03-workloads/*/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "${module.workloads_container.name}"
      key                  = "web-app.tfstate"  # or other workload name
    }
  }

  ========================================
  Storage Account: ${module.storage_account.name}
  Resource Group:  ${module.resource_group.name}
  Location:        ${module.resource_group.resource.location}
  ========================================

  EOT
}
