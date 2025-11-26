# =============================================================================
# Naming Wrapper Module
# Wraps the Azure Naming module with a pinned commit hash for security
# =============================================================================

locals {
  # Azure region abbreviations
  location_abbreviations = {
    "eastus"          = "eus"
    "eastus2"         = "eus2"
    "westus"          = "wus"
    "westus2"         = "wus2"
    "westus3"         = "wus3"
    "centralus"       = "cus"
    "northcentralus"  = "ncus"
    "southcentralus"  = "scus"
    "westcentralus"   = "wcus"
    "canadacentral"   = "cac"
    "canadaeast"      = "cae"
    "brazilsouth"     = "brs"
    "northeurope"     = "neu"
    "westeurope"      = "weu"
    "uksouth"         = "uks"
    "ukwest"          = "ukw"
    "francecentral"   = "frc"
    "francesouth"     = "frs"
    "germanywestcentral" = "gwc"
    "norwayeast"      = "noe"
    "switzerlandnorth" = "chn"
    "swedencentral"   = "swc"
    "eastasia"        = "eas"
    "southeastasia"   = "seas"
    "australiaeast"   = "aue"
    "australiasoutheast" = "ause"
    "japaneast"       = "jpe"
    "japanwest"       = "jpw"
    "koreacentral"    = "krc"
    "koreasouth"      = "krs"
    "southindia"      = "sin"
    "centralindia"    = "cin"
    "westindia"       = "win"
  }

  # Get location abbreviation or use full name if not in map
  location_abbr = var.location != "" ? lookup(local.location_abbreviations, lower(var.location), lower(var.location)) : ""

  # Build suffix with location abbreviation if location is provided
  computed_suffix = var.location != "" ? concat(var.suffix, [local.location_abbr]) : var.suffix
}

module "naming" {
  source                 = "git::https://github.com/Azure/terraform-azurerm-naming.git?ref=55e932f8edf91c50e6acf0bd62042766b2d2a120"
  suffix                 = local.computed_suffix
  prefix                 = var.prefix
  unique-seed            = var.unique_seed
  unique-length          = var.unique_length
  unique-include-numbers = var.unique_include_numbers
}
