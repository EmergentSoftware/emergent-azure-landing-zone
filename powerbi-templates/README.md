# FinOps Toolkit Power BI Reports

This directory contains Power BI templates for analyzing Azure cost and usage data from FinOps Hub.

## 📊 Available Reports

### Cost Summary
**File:** `CostSummary*.pbit`

Shows a high-level summary of your costs with key metrics and trends.

**Features:**
- Total cost breakdown by subscription, resource group, and service
- Month-over-month cost trends and variance analysis
- Top cost drivers and spending patterns
- Budget vs. actual spend comparison
- Cost distribution by tags (environment, project, cost center)

**Best for:** Executive dashboards, monthly cost reviews, budget tracking

---

### Cost Management
**File:** `CostManagement*.pbit`

Detailed cost analysis with drill-down capabilities for deeper insights.

**Features:**
- Granular cost breakdown by resource, meter, and pricing model
- Amortized vs. actual cost views
- Reserved instance and savings plan utilization
- Chargeback and showback capabilities
- Custom cost allocation and tagging analysis

**Best for:** FinOps practitioners, cost analysts, detailed investigations

---

### Data Ingestion
**File:** `DataIngestion*.pbit`

Monitors the health and performance of your FinOps Hub data pipeline.

**Features:**
- Data ingestion status and completeness
- Export execution history and success rates
- Data freshness and latency metrics
- Pipeline performance and error tracking
- Storage container size and growth trends

**Best for:** Platform administrators, troubleshooting data issues

---

### Governance
**File:** `Governance*.pbit`

Tracks compliance, policies, and resource governance across your Azure environment.

**Features:**
- Resource tagging compliance and coverage
- Policy assignment and compliance status
- Resource organization and naming conventions
- Orphaned and untagged resource identification
- Governance scorecard and recommendations

**Best for:** Cloud governance teams, compliance officers

---

### Rate Optimization
**File:** `RateOptimization*.pbit`

Identifies opportunities to reduce costs through pricing model optimization.

**Features:**
- Reserved instance and savings plan recommendations
- Spot instance usage and potential savings
- Commitment utilization and coverage analysis
- Hybrid benefit eligibility and usage
- License optimization opportunities

**Best for:** Cost optimization initiatives, purchasing decisions

---

### Services
**File:** `Services*.pbit` or `Services_*.pbit`

Service-specific cost analysis for major Azure services.

**Features:**
- Per-service cost breakdown and trends
- Service-specific metrics (compute hours, storage GB, transactions)
- Right-sizing recommendations by service
- Service tier and SKU optimization opportunities
- Cross-service cost correlation

**Best for:** Service owners, workload optimization

---

## 🔗 Connection Configuration

All reports connect to your FinOps Hub storage account:

**Storage URL:**
```
https://<your-finopshub-storage-account>.dfs.core.windows.net/ingestion
```

**Authentication Options:**
- **Organizational Account** (Recommended): Sign in with your Azure AD account
- **Storage Account Key**: Use key from Azure portal or CLI

**Setup Steps:**
1. Open the `.pbit` template file in Power BI Desktop
2. When prompted for parameters, enter the storage URL above
3. Choose authentication method and sign in
4. Wait for data to load from Parquet files
5. Save as `.pbix` file to preserve your settings

---

## 📅 Data Refresh

### Automatic Refresh (Power BI Service)
After publishing to Power BI Service (app.powerbi.com):
- Configure scheduled refresh (e.g., daily at 8 AM)
- Data updates automatically from FinOps Hub
- New costs appear within 24-48 hours of Azure usage

### Manual Refresh (Power BI Desktop)
- Click **Home → Refresh** to reload latest data
- Ensure you're connected to network/VPN
- Refresh takes 1-5 minutes depending on data volume

---

## 🚀 ACME Demo Setup

### Deployed Resources
- **FinOps Hub:** `<your-finopshub-name>`
- **Storage Account:** `<your-finopshub-storage-account>`
- **Resource Group:** `<your-finopshub-resource-group>`
- **Data Factory:** `<your-finopshub-datafactory>`

### Subscriptions Configured
1. Management (`acme-alz-management`)
2. Connectivity (`acme-alz-connectivity`)
3. Identity (`acme-alz-identity`)
4. Portals Admin Dev (`acme-portals-admin-dev`)
5. Portals Admin Prod (`acme-portals-admin-prod`)
6. Portals Customer Dev (`acme-portals-customer-dev`)
7. Portals Customer Prod (`acme-portals-customer-prod`)

### Data Collection Schedule
- **Cost Exports:** Daily at midnight UTC
- **ETL Processing:** Automatically triggered after exports complete
- **Data Availability:** Within 24-48 hours of Azure resource usage

---

## 📖 Documentation

- **FinOps Hub Documentation:** https://aka.ms/finops/hubs
- **Power BI Reports Guide:** https://learn.microsoft.com/en-us/cloud-computing/finops/toolkit/power-bi/reports
- **FinOps Toolkit GitHub:** https://github.com/microsoft/finops-toolkit

---

## 🛠️ Troubleshooting

### "Could not find any data"
- **Cause:** Ingestion container is empty (ETL hasn't run yet)
- **Solution:** Wait for first scheduled export run (midnight UTC) or check Data Factory pipeline status

### "Access Denied"
- **Cause:** Insufficient permissions on storage account
- **Solution:** Use storage account key authentication or request Storage Blob Data Reader role

### "Data is outdated"
- **Cause:** Scheduled refresh not configured or failed
- **Solution:** Manually refresh or check Power BI Service refresh history

### "Missing subscriptions"
- **Cause:** Cost exports not configured for all subscriptions
- **Solution:** Verify `settings.json` in config container includes all subscription scopes

---

## 📝 Notes

- Reports expect data in **FinOps Hub schema** (transformed by ETL pipeline)
- Direct CSV export files won't work - data must be processed through FinOps Hub
- Parquet format provides optimal performance for large datasets
- First-time data load may take several minutes
- Reports are designed for monthly cost analysis (adjust date filters as needed)

---

## 💡 Benefits Over Azure Portal Cost Management

### Cost Summary & Cost Management Reports Advantages

**Cross-Subscription Consolidation**
- Single view of all 7 ACME subscriptions without switching contexts
- Azure portal requires separate views per subscription or management group navigation

**Executive-Ready Visualizations**
- Pre-built dashboards designed for stakeholders and leadership
- Exportable to PowerPoint/PDF for board meetings and executive reporting
- Portal views are interactive-only, harder to share with non-technical audiences

**Historical Trend Analysis**
- 13-month retention with optimized Parquet storage for fast queries
- Portal can become slow with large date ranges
- Better performance for year-over-year comparisons and forecasting

**Custom Branding & Context**
- Add ACME logos, annotations, and business-specific context
- Combine cost data with non-Azure metrics (revenue, headcount, projects)
- Portal is fixed Azure-only presentation

**Chargeback/Showback Automation**
- Tag-based cost allocation across business units and departments
- Automated departmental billing reports with scheduled delivery
- Portal requires manual filtering and CSV exports

**Amortized Cost Views**
- See reserved instance costs spread over usage period
- More accurate budget tracking vs. upfront charges
- Portal shows both but harder to default to amortized view

**Offline Analysis**
- Work with data without portal access or network connectivity
- Share reports with non-Azure users (finance, executives)
- Faster exploration without API latency

**Integration Capabilities**
- Combine with other Power BI datasets (finance, operations, ServiceNow)
- Apply corporate BI standards and governance policies
- Row-level security for multi-tenant views and data isolation

**Value Proposition:** Azure portal is great for ad-hoc investigation, but Power BI is for **operational FinOps processes** and **organizational adoption**.

---

## 🔧 Customization & Expansion Options

### Add Custom Visualizations
- **Carbon Emissions:** Integrate Azure Carbon Optimization data for sustainability metrics
- **Service Health:** Combine with Azure Service Health API for cost-impact correlation
- **Usage Metrics:** Add Azure Monitor metrics (CPU, memory) alongside costs
- **Business KPIs:** Join with revenue, customer count, or transaction volume

### Extend Data Sources
- **AWS/GCP Costs:** Import multi-cloud cost data via FinOps Open Cost and Access Specification (FOCUS)
- **SaaS Spending:** Add Microsoft 365, GitHub, Datadog costs from procurement systems
- **On-Premises:** Include datacenter costs for total IT spend view
- **Third-Party Tools:** Integrate CloudHealth, Apptio, or other FinOps platforms

### Build Custom Reports
- **Department Dashboards:** Create role-specific views (Engineering, Finance, Product)
- **Project Tracking:** Link costs to Jira/Azure DevOps projects and sprints
- **Forecasting Models:** Build predictive analytics with Power BI's AI capabilities
- **Anomaly Detection:** Automated alerts for unusual spending patterns

### Automation Enhancements
- **Email Delivery:** Schedule automated report distribution via Power BI Service
- **Teams/Slack Alerts:** Send notifications when costs exceed thresholds
- **Dataflows:** Create reusable ETL pipelines for complex transformations
- **Power Automate:** Trigger workflows based on cost metrics (e.g., approval routing)

### Advanced Analytics
- **What-If Analysis:** Model cost impact of architecture changes or migrations
- **Optimization Scoring:** Create custom scorecards for FinOps maturity
- **Trend Forecasting:** Use Power BI's forecasting features for budget planning
- **Cohort Analysis:** Track cost evolution of resource groups over time

### Data Enrichment
- **Tagging Policies:** Add governance compliance scores based on tag coverage
- **Resource Metadata:** Enrich with SKU details, region pricing, or service limits
- **Organizational Hierarchy:** Map costs to org chart for accurate chargeback
- **Contract Data:** Include EA/MCA commitment balances and expiration tracking

### Integration Patterns
- **Power Apps:** Build self-service cost inquiry apps for end users
- **Azure Synapse:** For enterprise-scale analytics across petabytes of data
- **Azure Data Explorer:** Real-time cost streaming and anomaly detection
- **Fabric:** Unified analytics platform for OneLake integration

**Getting Started:** Most customizations can be done directly in Power BI Desktop by editing queries, adding calculated columns, or creating new visualizations. For advanced scenarios, consider extending the FinOps Hub ETL pipeline or using Power BI Dataflows.

---

## 🎯 Demo Tips

For presentations and demos:
1. **Pre-load data:** Open reports before demo and refresh
2. **Set filters:** Pre-select relevant date ranges and subscriptions
3. **Bookmark views:** Save custom views for different scenarios
4. **Export key visuals:** Save charts as images for slides
5. **Practice drill-downs:** Know your navigation path through the reports

---

## 📧 Support

For issues with FinOps Hub or Power BI reports:
- **GitHub Issues:** https://github.com/microsoft/finops-toolkit/issues
- **Microsoft Learn:** https://learn.microsoft.com/en-us/cloud-computing/finops/
- **Community Discussions:** https://github.com/microsoft/finops-toolkit/discussions
