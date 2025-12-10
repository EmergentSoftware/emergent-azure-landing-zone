variable "subscription_id" {
  description = "The management subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
}

variable "management_group_name" {
  description = "Management group name for management (acme-management)"
  type        = string
  default     = "acme-management"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "location" {
  description = "Azure region for shared resources"
  type        = string
  default     = "eastus"
}

# Networking Variables
variable "create_virtual_network" {
  description = "Whether to create a virtual network for this landing zone"
  type        = bool
  default     = true
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "vnet_subnets" {
  description = "Map of subnets to create in the virtual network"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    service_endpoints_with_location = optional(list(object({
      service   = string
      locations = optional(list(string), ["*"])
    })), [])
    delegations = optional(list(object({
      name = string
      service_delegation = object({
        name = string
      })
    })), [])
  }))
  default = {
    management = {
      name             = "subnet-management"
      address_prefixes = ["10.100.1.0/24"]
      service_endpoints_with_location = [
        { service = "Microsoft.Storage" },
        { service = "Microsoft.KeyVault" }
      ]
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.100.2.0/26"]
    }
    devops = {
      name             = "subnet-devops"
      address_prefixes = ["10.100.3.0/24"]
      service_endpoints_with_location = [
        { service = "Microsoft.Storage" },
        { service = "Microsoft.ContainerRegistry" }
      ]
    }
  }
}

variable "vnet_dns_servers" {
  description = "DNS servers configuration for the virtual network"
  type = object({
    dns_servers = list(string)
  })
  default = null
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags to be applied to all resources"
  type        = map(string)
  default = {
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"
  }
}

# =============================================================================
# Azure Optimization Engine Variables
# =============================================================================

variable "enable_azure_optimization_engine" {
  description = "Enable deployment of Azure Optimization Engine for cost optimization"
  type        = bool
  default     = false
}

variable "aoe_deployment_version" {
  description = "Version identifier for AOE deployment (triggers redeployment when changed)"
  type        = string
  default     = "1.0.0"
}

variable "aoe_admin_upn" {
  description = "User Principal Name (email) for AOE SQL Server admin (required if enable_azure_optimization_engine = true)"
  type        = string
  default     = ""
}

variable "aoe_admin_object_id" {
  description = "Azure AD Object ID for AOE SQL Server admin (required if enable_azure_optimization_engine = true)"
  type        = string
  default     = ""
}

variable "log_analytics_workspace_name" {
  description = "Name of existing Log Analytics workspace to reuse for AOE"
  type        = string
  default     = ""
}

variable "log_analytics_resource_group_name" {
  description = "Resource group name of existing Log Analytics workspace"
  type        = string
  default     = ""
}

# =============================================================================
# FinOps Hub Variables (Optional - Advanced Analytics)
# =============================================================================

variable "enable_finops_hub" {
  description = "Enable deployment of FinOps Hub for advanced cost analytics (optional, adds cost)"
  type        = bool
  default     = false
}
