# Web Application Workload using Azure Verified Modules

This example workload demonstrates deploying a production-ready web application using Azure Verified Modules (AVM) that complies with Azure Landing Zone policies.

## Architecture

This deployment uses the following AVM modules:

- **Resource Group**: `Azure/avm-res-resources-resourcegroup/azurerm`
- **App Service Plan**: `Azure/avm-res-web-serverfarm/azurerm`
- **Web App**: `Azure/avm-res-web-site/azurerm`
- **Application Insights**: `Azure/avm-res-insights-component/azurerm`

## Resources Created

```
Resource Group
├── App Service Plan (Linux/Windows)
├── Web App
│   ├── System-assigned Managed Identity
│   ├── HTTPS enforced
│   ├── TLS 1.2 minimum
│   └── Diagnostic Settings
└── Application Insights (optional)
```

## Compliance Features

The web app is configured to comply with ALZ policies:

- ✅ **HTTPS Only**: Enforced at web app level
- ✅ **TLS 1.2+**: Minimum TLS version configured
- ✅ **Managed Identity**: System-assigned identity enabled
- ✅ **Diagnostic Logging**: Connected to Log Analytics
- ✅ **Monitoring**: Application Insights integration
- ✅ **Security**: Run from package deployment

## Prerequisites

1. Azure Landing Zone foundation deployed (`../alz-foundation`)
2. Valid Azure subscription assigned to appropriate management group
3. (Optional) Log Analytics workspace for diagnostics
4. Terraform >= 1.3.0

## Deployment

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your configuration:

```hcl
subscription_id = "your-subscription-id"
workload_name   = "myapp"
environment     = "dev"
location        = "eastus"

app_service_os_type  = "Linux"
app_service_sku_name = "B1"

enable_application_insights = true
log_analytics_workspace_id  = "/subscriptions/.../workspaces/..."
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Plan Deployment

```bash
terraform plan
```

### 4. Deploy

```bash
terraform apply
```

Deployment takes approximately 5-10 minutes.

### 5. Verify

```bash
# Get the web app URL
terraform output web_app_url

# Check the web app status
az webapp show --name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --query "{name:name, state:state, httpsOnly:httpsOnly}" -o table
```

## Configuration Options

### App Service Plan SKUs

| SKU | Tier | vCPUs | RAM | Use Case |
|-----|------|-------|-----|----------|
| B1 | Basic | 1 | 1.75 GB | Dev/Test |
| S1 | Standard | 1 | 1.75 GB | Production (small) |
| P1v2 | Premium v2 | 1 | 3.5 GB | Production (medium) |
| P2v2 | Premium v2 | 2 | 7 GB | Production (large) |

### Operating System

- **Linux**: Lower cost, supports containers
- **Windows**: .NET Framework support

### Application Settings

Add custom app settings via `app_settings` variable:

```hcl
app_settings = {
  "ASPNETCORE_ENVIRONMENT" = "Production"
  "ConnectionStrings__Default" = "..."
  "APPINSIGHTS_INSTRUMENTATIONKEY" = "..."
}
```

## Deploying Your Application

### Option 1: ZIP Deploy

```bash
# Build your app
npm run build  # or dotnet publish

# Create deployment package
zip -r app.zip .

# Deploy
az webapp deployment source config-zip \
  --resource-group $(terraform output -raw resource_group_name) \
  --name $(terraform output -raw web_app_name) \
  --src app.zip
```

### Option 2: GitHub Actions

```yaml
name: Deploy to Azure Web App

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Azure Web App
        uses: azure/webapps-deploy@v2
        with:
          app-name: ${{ secrets.AZURE_WEBAPP_NAME }}
          publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
```

### Option 3: Container Deploy

For Linux App Service:

```bash
# Build and push container
docker build -t myregistry.azurecr.io/myapp:latest .
docker push myregistry.azurecr.io/myapp:latest

# Configure web app
az webapp config container set \
  --name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --docker-custom-image-name myregistry.azurecr.io/myapp:latest
```

## Monitoring

### Application Insights

If enabled, Application Insights provides:

- Request/response metrics
- Dependency tracking
- Exception monitoring
- Live metrics stream
- Application map

Access the instrumentation key:

```bash
terraform output application_insights_instrumentation_key
```

### Diagnostic Logs

Logs are sent to Log Analytics workspace (if configured):

- HTTP logs
- Application logs
- Deployment logs
- Platform logs

Query logs in Log Analytics:

```kusto
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| project TimeGenerated, CsHost, CsUriStem, ScStatus, TimeTaken
| order by TimeGenerated desc
```

## Security Best Practices

### Managed Identity Usage

The web app has a system-assigned managed identity. Use it to access Azure services:

```csharp
// C# example - Access Key Vault
var client = new SecretClient(
    new Uri("https://mykeyvault.vault.azure.net/"),
    new DefaultAzureCredential()
);
```

```javascript
// Node.js example - Access Storage
const { DefaultAzureCredential } = require("@azure/identity");
const { BlobServiceClient } = require("@azure/storage-blob");

const credential = new DefaultAzureCredential();
const blobServiceClient = new BlobServiceClient(
  "https://mystorageaccount.blob.core.windows.net",
  credential
);
```

### Network Security

For production workloads, consider:

1. **Virtual Network Integration**: Connect to corp network
2. **Private Endpoints**: Disable public access
3. **IP Restrictions**: Limit inbound traffic
4. **Service Endpoints**: Secure outbound connections

## Scaling

### Manual Scaling

```bash
# Scale out instances
az appservice plan update \
  --name $(terraform output -raw app_service_plan_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --number-of-workers 3
```

### Auto-scaling

Add auto-scale rules via Terraform or Portal based on:
- CPU percentage
- Memory percentage
- HTTP queue length
- Custom metrics

## Cost Optimization

- Use **B1** tier for dev/test ($13/month)
- Use **S1** tier for small production ($70/month)
- Enable **auto-scaling** to scale down during low usage
- Use **deployment slots** for zero-downtime deployments
- Configure **App Service Plan** sharing for multiple apps

## Cleanup

```bash
terraform destroy
```

## Integration with ALZ

Deploy this workload to a subscription under:

- **Landing Zones/Corp**: Internal applications (recommended)
- **Landing Zones/Online**: Public-facing applications
- **Sandbox**: Development/testing

The configuration complies with policies enforced at each level.

## Troubleshooting

### Issue: Deployment fails with SKU error

**Solution**: Check the selected SKU is available in your region:

```bash
az appservice list-locations --sku B1
```

### Issue: App won't start

**Solution**: Check application logs:

```bash
az webapp log tail \
  --name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name)
```

### Issue: HTTPS redirect not working

**Solution**: Verify HTTPS only setting:

```bash
az webapp show \
  --name $(terraform output -raw web_app_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --query httpsOnly
```

## Additional Resources

- [Azure Verified Modules](https://aka.ms/avm)
- [App Service Documentation](https://docs.microsoft.com/azure/app-service/)
- [Application Insights](https://docs.microsoft.com/azure/azure-monitor/app/app-insights-overview)
- [Managed Identities](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/)

## Support

For AVM module issues, see the respective GitHub repositories:
- [Resource Group Module](https://github.com/Azure/terraform-azurerm-avm-res-resources-resourcegroup)
- [App Service Plan Module](https://github.com/Azure/terraform-azurerm-avm-res-web-serverfarm)
- [Web App Module](https://github.com/Azure/terraform-azurerm-avm-res-web-site)
- [Application Insights Module](https://github.com/Azure/terraform-azurerm-avm-res-insights-component)
