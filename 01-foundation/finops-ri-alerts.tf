# ==============================================================================
# Reserved Instance Utilization Alerts
# ==============================================================================
# Configuration and guidance for setting up Azure Monitor alerts for low RI/SP 
# utilization using Log Analytics queries and Cost Management data integration
# ==============================================================================

# Note: RI utilization monitoring integrates with FinOps Hub Log Analytics workspace
# Cost data is automatically exported and includes reservation details

# ==============================================================================
# Alert Configuration Outputs
# ==============================================================================

output "ri_alert_configuration" {
  description = "RI utilization alert configuration guidance"
  value = {
    overview = "Configure Azure Monitor alerts to track Reserved Instance and Savings Plan utilization"

    prerequisites = {
      finops_hub_deployed     = "FinOps Hub must be deployed (exports cost data to Log Analytics)"
      cost_export_configured  = "Cost Management export running daily"
      log_analytics_workspace = "Uses FinOps Hub Log Analytics workspace"
    }

    alert_types = {
      low_utilization = {
        purpose            = "Alerts when RI utilization falls below 80% over 7-day period"
        query_type         = "Log Analytics Scheduled Query"
        check_frequency    = "Daily"
        severity           = "Warning (2)"
        action_group       = "Infrastructure team"
        threshold          = "< 80% utilization"
        recommended_action = "Review RI sizing, scope (subscription/resource group), or consider exchange/refund"
      }

      expiring_soon = {
        purpose            = "Alerts for RIs expiring within 30 days"
        query_type         = "Log Analytics Scheduled Query"
        check_frequency    = "Weekly"
        severity           = "Error (1)"
        action_group       = "Finance + FinOps teams"
        threshold          = "30 days before expiration"
        recommended_action = "Evaluate renewal: check utilization history, confirm workload continuity, approve renewal"
      }

      coverage_low = {
        purpose            = "Alerts when RI coverage drops below target (60%)"
        query_type         = "Log Analytics Scheduled Query"
        check_frequency    = "Weekly"
        severity           = "Informational (4)"
        action_group       = "FinOps team"
        threshold          = "< 60% of eligible resources covered"
        recommended_action = "Review Azure Advisor recommendations for new RI purchases"
      }
    }

    log_analytics_queries = {
      ri_low_utilization = {
        name        = "RI Utilization Below 80%"
        description = "Identifies Reserved Instances with utilization below threshold"
        kql_query   = <<-QUERY
// Find Reserved Instances with utilization below 80%
AzureCost_CL
| where ReservationId_s != "" and ReservationName_s != ""
| where TimeGenerated >= ago(7d)
| summarize 
    TotalCost = sum(CostInBillingCurrency_d),
    ReservedHours = sum(Quantity_d),
    UsageCount = count()
  by ReservationId_s, ReservationName_s, MeterCategory_s, bin(TimeGenerated, 1d)
| extend UtilizationPercent = (UsageCount / ReservedHours) * 100
| where UtilizationPercent < 80
| project 
    Date = TimeGenerated,
    ReservationName = ReservationName_s,
    Category = MeterCategory_s,
    UtilizationPercent,
    DailyCost = TotalCost,
    Alert = "RI utilization below 80% - Review sizing or scope"
| order by Date desc, UtilizationPercent asc
QUERY
      }

      ri_coverage_analysis = {
        name        = "RI Coverage Analysis"
        description = "Calculates RI coverage and potential savings opportunities"
        kql_query   = <<-QUERY
// Calculate RI coverage percentage by subscription and resource type
AzureCost_CL
| where TimeGenerated >= ago(30d)
| where MeterCategory_s in ("Virtual Machines", "SQL Database", "Cosmos DB", "App Service")
| summarize 
    TotalCost = sum(CostInBillingCurrency_d),
    RICost = sumif(CostInBillingCurrency_d, PricingModel_s == "Reservation"),
    PayAsYouGoCost = sumif(CostInBillingCurrency_d, PricingModel_s == "OnDemand")
  by SubscriptionName_s, MeterCategory_s
| extend 
    RICoveragePercent = round((RICost / TotalCost) * 100, 2),
    PotentialSavings = PayAsYouGoCost * 0.50
| project 
    Subscription = SubscriptionName_s,
    ResourceType = MeterCategory_s,
    RICoveragePercent,
    MonthlyRICost = round(RICost, 2),
    MonthlyPayAsYouGo = round(PayAsYouGoCost, 2),
    PotentialMonthlySavings = round(PotentialSavings, 2)
| order by PotentialMonthlySavings desc
QUERY
      }

      ri_expiring_soon = {
        name        = "Reservations Expiring Soon"
        description = "Lists RIs expiring within 90 days requiring renewal decisions"
        kql_query   = <<-QUERY
// List reservations expiring in the next 90 days
AzureCost_CL
| where ReservationId_s != ""
| where TimeGenerated >= ago(1d)
| extend ExpirationDate = todatetime(ReservationEndDate_s)
| where ExpirationDate <= now() + 90d
| summarize 
    TotalCost = sum(CostInBillingCurrency_d),
    AvgDailyCost = avg(CostInBillingCurrency_d)
  by ReservationName_s, ReservationId_s, ExpirationDate, MeterCategory_s
| extend 
    DaysUntilExpiration = datetime_diff('day', ExpirationDate, now()),
    AnnualCost = AvgDailyCost * 365
| project 
    ReservationName = ReservationName_s,
    ResourceType = MeterCategory_s,
    ExpirationDate,
    DaysUntilExpiration,
    EstimatedAnnualCost = round(AnnualCost, 2),
    Action = case(
      DaysUntilExpiration <= 30, "URGENT: Decide on renewal",
      DaysUntilExpiration <= 60, "Start renewal evaluation",
      "Review utilization trends"
    )
| order by DaysUntilExpiration asc
QUERY
      }
    }

    setup_instructions = <<EOT
To set up RI utilization alerts:

1. Azure Portal → Monitor → Alerts → Alert Rules → Create
2. Scope: Select FinOps Hub Log Analytics workspace
3. Condition: Add new signal → Log (query alert)
4. Paste one of the KQL queries from the 'log_analytics_queries' output
5. Set threshold and evaluation frequency
6. Action: Add action group (Infrastructure team)
7. Alert details: Name, severity, description
8. Create alert rule

Alternative: Use Azure CLI
---------------------------
az monitor scheduled-query create \
  --name "ri-utilization-alert" \
  --resource-group rg-cost-monitoring-eastus \
  --scopes "/subscriptions/<SUB_ID>/resourceGroups/rg-cost-monitoring-eastus/providers/Microsoft.OperationalInsights/workspaces/<WORKSPACE_NAME>" \
  --condition "count > 0" \
  --condition-query "<PASTE_KQL_QUERY>" \
  --evaluation-frequency "P1D" \
  --window-size "P7D" \
  --severity 2 \
  --action-group "/subscriptions/<SUB_ID>/resourceGroups/rg-cost-monitoring-eastus/providers/Microsoft.Insights/actionGroups/ag-cost-alerts-infrastructure"

Monitoring Dashboard:
---------------------
• Power BI: FinOps Hub → Rate Optimization tab
• Azure Portal: Cost Management → Reservations
• Log Analytics: Run queries manually for ad-hoc analysis
EOT

    integration_points = {
      finops_hub        = "Uses FinOps Hub Log Analytics workspace and Cost Management exports"
      action_groups     = "Leverages existing action groups (infrastructure, it_operations)"
      power_bi          = "RI trends visible in Rate Optimization workbook"
      approval_workflow = "Alerts link to docs/FINOPS-RI-APPROVAL-WORKFLOW.md"
    }

    documentation = {
      azure_docs        = "https://learn.microsoft.com/azure/cost-management-billing/reservations/manage-reserved-vm-instance"
      alert_setup       = "https://learn.microsoft.com/azure/azure-monitor/alerts/alerts-log"
      kql_reference     = "https://learn.microsoft.com/azure/data-explorer/kusto/query/"
      internal_workflow = "docs/FINOPS-RI-APPROVAL-WORKFLOW.md"
    }
  }
}
