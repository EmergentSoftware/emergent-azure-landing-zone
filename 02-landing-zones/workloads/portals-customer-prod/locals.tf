# =============================================================================
# Local Variables and Configuration
# =============================================================================

# Common tags from the landing zone pattern module
locals {
  # Merge pattern module tags with workload-specific tags
  common_tags = merge(
    module.landing_zone.common_tags,
    {
      Application = "Customer Portal"
    }
  )
}
