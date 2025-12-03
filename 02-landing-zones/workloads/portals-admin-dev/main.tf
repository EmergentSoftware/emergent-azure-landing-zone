# =============================================================================
# Landing Zone Workload Pattern - Portal Admin Dev
# This places the portal admin dev subscription into the acme-portals management group
# and sets up monitoring resources using the landing-zone-workload pattern module
# Deploy this AFTER alz-foundation
# =============================================================================

module "landing_zone" {
  source = "../../../shared-modules/pattern-modules/lz-workload"

  # Subscription and Management Group
  subscription_id       = var.subscription_id
  tenant_id             = var.tenant_id
  management_group_name = var.management_group_name

  # Naming and Tagging
  landing_zone_name = "portals-admin-dev"
  purpose           = "Landing Zone - Portal Admin Dev"
  environment       = var.environment
  location          = var.location
  naming_suffix     = ["portals", "admin"]

  # Monitoring
  create_log_analytics = var.create_log_analytics
  log_retention_days   = var.log_retention_days

  # Networking
  ipam_config_path = "../../ipam.yaml"
  ipam_key         = "portals-admin-dev"

  # Tags - will be merged with pattern module defaults
  tags = var.tags
  common_tags = {
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"
  }
}
