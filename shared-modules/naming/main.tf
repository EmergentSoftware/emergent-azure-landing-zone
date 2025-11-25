# =============================================================================
# Naming Wrapper Module
# Wraps the Azure Naming module with a pinned commit hash for security
# =============================================================================

module "naming" {
  source                 = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=55e932f8edf91c50e6acf0bd62042766b2d2a120"
  suffix                 = var.suffix
  prefix                 = var.prefix
  unique-seed            = var.unique_seed
  unique-length          = var.unique_length
  unique-include-numbers = var.unique_include_numbers
}
