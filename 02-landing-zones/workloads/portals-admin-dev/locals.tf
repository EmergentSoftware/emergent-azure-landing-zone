# =============================================================================
# Local Variables and Configuration
# =============================================================================

# Load IPAM configuration
locals {
  ipam              = yamldecode(file("${path.module}/../../ipam.yaml"))
  portals_admin_dev = local.ipam["portals-admin-dev"]

  # Common tags applied to all resources in this landing zone
  common_tags = {
    # Landing Zone Identity
    LandingZone     = "portals-admin-dev"
    ManagementGroup = var.management_group_name
    Environment     = "Development"
    Application     = "Admin Portal"

    # Deployment Information
    ManagedBy        = "Terraform"
    DeploymentMethod = "Terraform"
    Repository       = "emergent-azure-landing-zone"

    # IPAM Reference
    IPAM = "Managed via 02-landing-zones/ipam.yaml"
  }

  # Network-specific tags
  network_tags = merge(
    local.common_tags,
    var.tags,
    {
      Purpose = "Network Infrastructure"
    }
  )

  # Monitoring-specific tags
  monitoring_tags = merge(
    local.common_tags,
    var.tags,
    {
      Purpose = "Monitoring and Diagnostics"
    }
  )
}
