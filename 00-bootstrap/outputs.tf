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
      id   = module.containers[name].id
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

output "backend_config_connectivity" {
  description = "Backend configuration for connectivity landing zone"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-connectivity"].name
    key                  = "connectivity.tfstate"
  }
}

output "backend_config_identity" {
  description = "Backend configuration for identity landing zone"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-identity"].name
    key                  = "identity.tfstate"
  }
}

output "backend_config_management" {
  description = "Backend configuration for management landing zone"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = module.containers["tfstate-management"].name
    key                  = "management.tfstate"
  }
}

output "backend_config_workloads" {
  description = "Backend configuration for workloads (deprecated - use specific workload configs)"
  value = {
    resource_group_name  = module.resource_group.name
    storage_account_name = module.storage_account.name
    container_name       = "deprecated-use-specific-workload"
    key                  = "deprecated.tfstate"
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
      container_name       = "tfstate-foundation"
      key                  = "foundation.tfstate"
    }
  }

  ### For 02-landing-zones/connectivity/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "tfstate-connectivity"
      key                  = "connectivity.tfstate"
    }
  }

  ### For 02-landing-zones/identity/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "tfstate-identity"
      key                  = "identity.tfstate"
    }
  }

  ### For 02-landing-zones/management/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "tfstate-management"
      key                  = "management.tfstate"
    }
  }

  ### For 02-landing-zones/workloads/portals-dev/main.tf:

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "tfstate-portal-dev"
      key                  = "portal-dev.tfstate"
    }
  }

  ### For 03-workloads/portal (dev):

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "tfstate-portal-dev"
      key                  = "portal-dev.tfstate"
    }
  }

  ### For 03-workloads/portal (prod):

  terraform {
    backend "azurerm" {
      resource_group_name  = "${module.resource_group.name}"
      storage_account_name = "${module.storage_account.name}"
      container_name       = "tfstate-portal-prod"
      key                  = "portal-prod.tfstate"
    }
  }

  ========================================
  Storage Account: ${module.storage_account.name}
  Resource Group:  ${module.resource_group.name}
  Location:        ${var.location}
  Containers:      ${join(", ", var.containers)}
  ========================================

  EOT
}
