# ==============================================================================
# Reserved Instance & Savings Plan Management
# ==============================================================================
# Tracks RI and Savings Plan utilization across all subscriptions to ensure
# optimal commitment usage and maximize cost savings (40-72% discount)
# ==============================================================================

locals {
  # Alert when RI/SP utilization drops below this threshold
  ri_utilization_threshold = 0.80 # 80%

  # Subscriptions with production workloads suitable for RIs
  ri_monitored_subscriptions = [
    var.subscription_id,                       # Management
    var.connectivity_subscription_id,          # Connectivity
    var.identity_subscription_id,              # Identity
    var.portals_admin_prod_subscription_id,    # Admin Portal Prod
    var.portals_customer_prod_subscription_id, # Customer Portal Prod
  ]

  ri_tags = merge(var.common_tags, {
    Purpose   = "FinOps - Rate Optimization"
    Component = "Reserved Instances & Savings Plans"
  })
}

# ==============================================================================
# Outputs: RI/SP Monitoring Configuration
# ==============================================================================

output "ri_savings_plan_monitoring" {
  description = "Reserved Instance and Savings Plan tracking configuration"
  value = {
    enabled                 = true
    monitored_subscriptions = length(local.ri_monitored_subscriptions)
    utilization_threshold   = "${local.ri_utilization_threshold * 100}%"

    power_bi_integration = {
      report_name = "FinOps Hub - Rate Optimization"
      data_sources = [
        "Azure Cost Management - Reservation Details",
        "Azure Cost Management - Reservation Recommendations",
        "Azure Cost Management - Reservation Transactions",
        "Azure Cost Management - Reservation Summaries"
      ]
      refresh_frequency = "Daily (automatic)"
    }

    viewing_instructions = <<EOT
========================================
Reserved Instance & Savings Plan Monitoring
========================================

Power BI Dashboard:
-------------------
1. Open FinOps Hub Power BI report
2. Navigate to "Rate Optimization" tab
3. Review key sections:
   • Current Reservations - Active RI/SP inventory
   • Utilization Trends - Daily usage vs capacity
   • Coverage Analysis - % of resources covered by commitments
   • Recommendations - Suggested new purchases
   • Savings Impact - Cost avoidance from RIs/SPs

Target Metrics:
---------------
• RI/SP Utilization: >= 80% (monitored via alerts)
• Coverage Goal: 60-80% of stable production workloads
• Review Frequency: Weekly team review, monthly executive summary

Azure Portal:
-------------
1. Cost Management + Billing → Reservations
2. View utilization trends and recommendations
3. Cost Management → Cost Analysis → Group by: Pricing Model

Typical Savings:
----------------
• 1-Year RI: 40-60% savings vs pay-as-you-go
• 3-Year RI: 60-72% savings vs pay-as-you-go
• Savings Plans: Flexible alternative with similar discounts

Best Practices:
---------------
1. Purchase RIs for stable, predictable workloads (>6 months runtime)
2. Start with 1-year commitments, move to 3-year after validation
3. Monitor utilization weekly to catch scope/size mismatches early
4. Consider Savings Plans for flexible compute (VMs, App Service, Functions)
5. Use scoped RIs (subscription/resource group) for better tracking
6. Set renewal reminders 90 days before expiration

Integration with Workflow:
--------------------------
• Recommendations reviewed weekly in FinOps team meeting
• Purchases follow approval workflow (see FINOPS-RI-APPROVAL-WORKFLOW.md)
• Finance team executes purchases, FinOps tracks utilization
• Alerts notify team of underutilized commitments
• Quarterly optimization: exchange, scope changes, refunds
EOT

    cli_commands = {
      # List all active reservations
      list_all_reservations = "az reservations reservation list --query '[].{Name:name, Quantity:properties.quantity, Status:properties.provisioningState, ExpiryDate:properties.expiryDate}' --output table"

      # Show daily utilization for a specific reservation
      show_daily_utilization = "az consumption reservation summary list --grain daily --reservation-order-id <ORDER_ID> --query '[].{Date:properties.usageDate, Used:properties.usedHours, Reserved:properties.reservedHours, Utilization:properties.utilizedPercentage}' --output table"

      # Get RI purchase recommendations
      get_recommendations_1y = "az consumption reservation recommendation list --scope /subscriptions/<SUBSCRIPTION_ID> --term P1Y --look-back-period Last30Days --output table"
      get_recommendations_3y = "az consumption reservation recommendation list --scope /subscriptions/<SUBSCRIPTION_ID> --term P3Y --look-back-period Last60Days --output table"

      # Calculate potential savings
      calculate_savings = "az consumption reservation recommendation list --scope /subscriptions/<SUBSCRIPTION_ID> --term P1Y --query '[].{ResourceType:properties.resourceType, NetSavings:properties.netSavings, RecommendedQuantity:properties.recommendedQuantity}' --output table"

      # Export reservation transactions for analysis
      export_transactions = "az consumption reservation transaction list --billing-account-id <BILLING_ACCOUNT_ID> --start-date 2025-01-01 --end-date 2025-12-31 --output json > ri-transactions-2025.json"
    }

    utilization_targets = {
      minimum_acceptable    = ">= 80%"
      target_optimal        = ">= 90%"
      coverage_goal_min     = "60% of production workloads"
      coverage_goal_optimal = "80% of stable production workloads"
      review_cadence = {
        operational = "Weekly - FinOps team reviews utilization and recommendations"
        tactical    = "Monthly - Leadership reviews RI portfolio health and ROI"
        strategic   = "Quarterly - Optimize scopes, exchanges, and renewal planning"
      }
    }

    resource_types_supported = {
      virtual_machines = {
        eligible           = true
        typical_savings_1y = "40-60%"
        typical_savings_3y = "60-72%"
        recommendation     = "Best for stable VM workloads (Windows, Linux)"
      }
      sql_database = {
        eligible           = true
        typical_savings_1y = "40-55%"
        typical_savings_3y = "55-65%"
        recommendation     = "vCore model - reserve compute capacity"
      }
      cosmos_db = {
        eligible           = true
        typical_savings_1y = "35-50%"
        typical_savings_3y = "50-65%"
        recommendation     = "Reserve throughput (RU/s) for production databases"
      }
      app_service = {
        eligible           = true
        typical_savings_1y = "40-60%"
        typical_savings_3y = "Not available"
        recommendation     = "Consider Savings Plan for flexibility"
      }
      synapse_analytics = {
        eligible           = true
        typical_savings_1y = "35-50%"
        typical_savings_3y = "55-65%"
        recommendation     = "Reserve compute nodes for dedicated SQL pools"
      }
      storage = {
        eligible           = true
        typical_savings_1y = "30-40%"
        typical_savings_3y = "40-60%"
        recommendation     = "Reserved capacity for blob storage"
      }
    }

    alerting = {
      low_utilization = {
        threshold       = "< 80%"
        notification    = "Infrastructure team via action group"
        check_frequency = "Daily"
        action_required = "Review sizing, scope, or consider exchange/refund"
      }
      expiring_soon = {
        warning_period  = "90 days before expiration"
        notification    = "Finance + FinOps teams"
        action_required = "Evaluate renewal, exchange, or let expire"
      }
    }

    approval_workflow = {
      reference_document = "docs/FINOPS-RI-APPROVAL-WORKFLOW.md"
      approval_thresholds = {
        under_10k = "FinOps Team Lead"
        "10k_50k" = "Director of Engineering + CFO"
        over_50k  = "CTO + CFO"
      }
      slack_channel = "#finops-approvals"
    }
  }
}

output "ri_management_documentation" {
  description = "Links to RI/SP management resources"
  value = {
    microsoft_learn = {
      overview            = "https://learn.microsoft.com/azure/cost-management-billing/reservations/save-compute-costs-reservations"
      manage_reservations = "https://learn.microsoft.com/azure/cost-management-billing/reservations/manage-reserved-vm-instance"
      exchanges_refunds   = "https://learn.microsoft.com/azure/cost-management-billing/reservations/exchange-and-refund-azure-reservations"
      savings_plans       = "https://learn.microsoft.com/azure/cost-management-billing/savings-plan/savings-plan-compute-overview"
    }
    internal_docs = {
      approval_workflow   = "docs/FINOPS-RI-APPROVAL-WORKFLOW.md"
      finops_architecture = "docs/FINOPS-ARCHITECTURE.md"
    }
  }
}
