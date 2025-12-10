# FinOps Hub Architecture & Data Flow

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          AZURE SUBSCRIPTIONS (7)                             │
│  • Management        • Connectivity      • Identity                          │
│  • Admin Dev         • Admin Prod                                            │
│  • Customer Dev      • Customer Prod                                         │
└────────────────┬────────────────────────────────────────────────────────────┘
                 │
                 │ Cost & Usage Data (hourly)
                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      AZURE COST MANAGEMENT API                               │
│  • Generates cost export files (CSV)                                         │
│  • Scheduled daily at midnight UTC                                           │
│  • Includes manifest.json metadata                                           │
└────────────────┬────────────────────────────────────────────────────────────┘
                 │
                 │ Export to Storage
                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│               STORAGE ACCOUNT: <your-finopshub-storage-account>              │
│  Premium BlockBlobStorage (LRS)                                              │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 📦 config/                                                             │  │
│  │  ├── settings.json          ← Hub configuration                       │  │
│  │  │   • 7 subscription scopes                                          │  │
│  │  │   • 13-month retention                                             │  │
│  │  │   • Export schedule                                                │  │
│  │  └── schemas/               ← Data schemas                            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 📦 msexports/                                                          │  │
│  │  ├── subscription1/                                                    │  │
│  │  │   ├── exportName_YYYYMMDD-YYYYMMDD/                                │  │
│  │  │   │   ├── manifest.json  ← Export metadata                         │  │
│  │  │   │   ├── data1.csv                                                │  │
│  │  │   │   ├── data2.csv                                                │  │
│  │  │   │   └── ...                                                      │  │
│  │  ├── subscription2/                                                    │  │
│  │  └── ...                                                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 📦 ingestion/                                                          │  │
│  │  ├── focuscost/             ← Processed Parquet files                 │  │
│  │  │   ├── yyyy=2025/                                                   │  │
│  │  │   │   └── mm=12/                                                   │  │
│  │  │   │       └── *.parquet                                            │  │
│  │  ├── commitmentdiscounts/   ← RI/Savings Plan data                    │  │
│  │  ├── prices/                ← Pricing data                            │  │
│  │  └── recommendations/       ← Optimization recommendations            │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
└────────────────┬────────────────────────────────────────────────────────────┘
                 │
                 │ Event Grid notifications
                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│        DATA FACTORY: acme-finopshub-mkkac1u6-engine-3funlapkpooie           │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 🔄 config_ConfigureExports                                            │  │
│  │  • Triggered: Manual or scheduled                                     │  │
│  │  • Reads: config/settings.json                                        │  │
│  │  • Creates: Cost exports via ARM API for each scope                   │  │
│  │  • Output: Export definitions in Cost Management                      │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                 │                                                             │
│                 │ Triggers next pipeline                                     │
│                 ▼                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 🔄 config_StartExportProcess                                          │  │
│  │  • Triggered: After ConfigureExports completes                        │  │
│  │  • Action: Initiates export execution for all subscriptions           │  │
│  │  • Note: Scheduled exports run automatically at midnight UTC          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                 │                                                             │
│                 │ New files appear in msexports/                              │
│                 ▼                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 🔄 msexports_ExecuteETL                                               │  │
│  │  • Triggered: Storage event (new manifest.json)                       │  │
│  │  • Reads: msexports/*/manifest.json + CSV files                       │  │
│  │  • Transform:                                                          │  │
│  │    1. Parse CSV files                                                 │  │
│  │    2. Convert to FOCUS schema                                         │  │
│  │    3. Normalize columns and data types                                │  │
│  │    4. Apply currency conversions                                      │  │
│  │    5. Partition by year/month                                         │  │
│  │  • Writes: ingestion/focuscost/*.parquet                              │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                 │                                                             │
│                 │ Additional pipelines                                        │
│                 ▼                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ 🔄 Other ETL Pipelines                                                │  │
│  │  • commitmentdiscounts_* → Process RI/Savings Plan data               │  │
│  │  • prices_* → Load pricing information                                │  │
│  │  • recommendations_* → Fetch Azure Advisor data                       │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  🔐 Managed Identity: <your-finopshub-managed-identity-id>                   │
│     • Cost Management Contributor on all 7 subscriptions                     │
│     • Storage Blob Data Contributor on storage account                       │
└────────────────┬────────────────────────────────────────────────────────────┘
                 │
                 │ Parquet files ready
                 ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                          POWER BI DESKTOP / SERVICE                          │
│                                                                               │
│  📊 Connect to: https://<your-storage-account>.dfs.core.windows.net          │
│                 /ingestion                                                    │
│                                                                               │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Reports (*.pbit templates)                                             │  │
│  │  • CostSummary.storage.pbit                                            │  │
│  │  • CostManagement.storage.pbit                                         │  │
│  │  • DataIngestion.storage.pbit                                          │  │
│  │  • Governance.storage.pbit                                             │  │
│  │  • RateOptimization.storage.pbit                                       │  │
│  │  • Services.storage.pbit                                               │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                 │                                                             │
│                 │ DirectQuery or Import mode                                 │
│                 ▼                                                             │
│  ┌───────────────────────────────────────────────────────────────────────┐  │
│  │ Visualizations                                                         │  │
│  │  • Cost trends and forecasting                                         │  │
│  │  • Chargeback/showback reports                                         │  │
│  │  • Optimization recommendations                                        │  │
│  │  • Budget vs. actual tracking                                          │  │
│  └───────────────────────────────────────────────────────────────────────┘  │
│                                                                               │
│  📧 Publish → Power BI Service                                               │
│     • Scheduled refresh (e.g., daily 8 AM)                                   │
│     • Email delivery to stakeholders                                         │
│     • Teams/Slack integration                                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔄 Data Flow Timeline

### **Day 0: Initial Setup**
```
1. Terraform deploys FinOps Hub infrastructure
   ├── Resource group
   ├── Storage account with containers
   ├── Data Factory with pipelines
   └── Managed identity with permissions

2. PowerShell deploys FinOps Hub application
   └── Uploads config/settings.json

3. config_ConfigureExports pipeline runs
   └── Creates cost export definitions in Cost Management API
```

### **Daily: Midnight UTC**
```
1. Azure Cost Management generates exports
   ├── Subscription 1: acme-alz-management
   ├── Subscription 2: acme-alz-connectivity
   ├── Subscription 3: acme-alz-identity
   ├── Subscription 4: acme-portals-admin-dev
   ├── Subscription 5: acme-portals-admin-prod
   ├── Subscription 6: acme-portals-customer-dev
   └── Subscription 7: acme-portals-customer-prod

2. Export files written to msexports/ container
   ├── manifest.json (metadata)
   └── *.csv (cost data)

3. Event Grid detects new manifest.json
   └── Triggers msexports_ExecuteETL pipeline

4. ETL Pipeline processes data
   ├── Read manifest and CSV files
   ├── Transform to FOCUS schema
   ├── Convert to Parquet format
   ├── Partition by year/month
   └── Write to ingestion/ container

5. Power BI Service scheduled refresh
   └── Pulls latest Parquet data from ingestion/
```

### **Latency Expectations**
- **Export Generation:** ~1-2 hours after midnight UTC
- **ETL Processing:** ~30-60 minutes per subscription
- **Power BI Refresh:** 5-15 minutes (depends on data volume)
- **Total Latency:** Cost data from yesterday available by ~3-4 AM UTC

---

## 🔐 Security & Permissions

### **Managed Identity Assignments**
```
Identity: <your-finopshub-managed-identity-id>

Subscriptions (Cost Management Contributor):
├── /subscriptions/<management-subscription-id>     # management
├── /subscriptions/<connectivity-subscription-id>   # connectivity
├── /subscriptions/<identity-subscription-id>       # identity
├── /subscriptions/<admin-dev-subscription-id>      # admin-dev
├── /subscriptions/<admin-prod-subscription-id>     # admin-prod
├── /subscriptions/<customer-dev-subscription-id>   # customer-dev
└── /subscriptions/<customer-prod-subscription-id>   # customer-prod

Storage Account (Storage Blob Data Contributor):
└── <your-finopshub-storage-account>
```

### **Power BI Authentication**
```
Option 1: Organizational Account (Recommended)
├── User: <your-user>@<your-domain>
└── Requires: Storage Blob Data Reader role

Option 2: Storage Account Key
├── Retrieve from Azure Portal or CLI
└── Less secure, use for testing only
```

---

## 📊 Data Schema Evolution

### **1. Raw CSV (msexports/)**
```
Azure Cost Management Export Format:
- BillingAccountId, BillingAccountName
- SubscriptionId, SubscriptionName
- ResourceGroup, ResourceId, ResourceType
- MeterCategory, MeterSubCategory, Meter, MeterRegion
- UsageDateTime, UsageQuantity
- Cost, CostInBillingCurrency
- Tags (JSON string)
```

### **2. FOCUS Parquet (ingestion/focuscost/)**
```
FinOps Open Cost and Usage Specification (FOCUS):
- ChargeCategory, ChargeClass, ChargeFrequency
- ChargeDescription, ChargePeriodStart, ChargePeriodEnd
- BillingAccountId, BillingAccountName
- ServiceName, ServiceCategory
- ResourceId, ResourceName, ResourceType
- Region, AvailabilityZone
- PricingCategory, PricingUnit, PricingQuantity
- BilledCost, EffectiveCost
- Tags (expanded columns)
```

### **3. Power BI Data Model**
```
Optimized for analysis:
- Date dimension (calendar hierarchy)
- Subscription dimension
- Service dimension
- Resource dimension
- Fact table (costs) with aggregations
```

---

## 🚨 Monitoring & Troubleshooting

### **Health Checks**
1. **Data Factory Pipelines**
   ```powershell
   az datafactory pipeline-run query-by-factory \
     --factory-name "<your-finopshub-datafactory>" \
     --resource-group "<your-finopshub-resource-group>" \
     --last-updated-after "2025-12-09T00:00:00Z"
   ```

2. **Export File Presence**
   ```powershell
   az storage blob list \
     --account-name "<your-storage-account>" \
     --container-name "msexports" \
     --query "[?contains(name, 'manifest.json')]"
   ```

3. **Ingestion Data Availability**
   ```powershell
   az storage blob list \
     --account-name "<your-storage-account>" \
     --container-name "ingestion" \
     --prefix "focuscost/"
   ```

### **Common Issues**

| Issue | Cause | Solution |
|-------|-------|----------|
| No exports generated | Permissions missing | Verify Cost Management Contributor role |
| Missing manifest.json | Manual export trigger | Wait for scheduled run at midnight UTC |
| ETL pipeline fails | Malformed manifest | Check Data Factory run logs for details |
| Empty ingestion container | ETL hasn't completed | Monitor pipeline status |
| Power BI can't connect | Authentication failure | Use storage key or verify RBAC role |
| Stale data in reports | Refresh not scheduled | Configure scheduled refresh in Power BI Service |

---

## 🎯 Key Design Decisions

### **Why Premium Storage?**
- **Performance:** Faster I/O for large Parquet files
- **Reliability:** Higher SLA for mission-critical FinOps data
- **Scale:** Handles petabyte-scale cost data efficiently

### **Why Parquet Format?**
- **Compression:** 10x smaller than CSV
- **Performance:** Columnar format optimized for analytics
- **Compatibility:** Native Power BI support

### **Why FOCUS Schema?**
- **Standardization:** Multi-cloud cost data (Azure, AWS, GCP)
- **Future-proof:** Industry standard for FinOps
- **Extensibility:** Easy to add custom fields

### **Why Event-Driven ETL?**
- **Near Real-Time:** Process exports as soon as available
- **Efficiency:** Only process new data, not re-scan entire container
- **Resilience:** Automatic retry on storage events

---

## 📚 References

- **FinOps Hub Documentation:** https://aka.ms/finops/hubs
- **FOCUS Specification:** https://focus.finops.org/
- **Power BI Reports Guide:** https://learn.microsoft.com/cloud-computing/finops/toolkit/power-bi/reports
- **Azure Cost Management API:** https://learn.microsoft.com/azure/cost-management-billing/
- **FinOps Toolkit GitHub:** https://github.com/microsoft/finops-toolkit
