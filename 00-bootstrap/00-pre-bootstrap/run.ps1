# CSP Subscription Creation Test Script
# Prerequisites:
# 1. Run setup-csp-service-principal.ps1 to create the service principal
# 2. Complete manual steps (admin consent + Partner Center Admin Agent role)
# 3. Update AppId and AppSecret below with values from csp-service-principal-credentials.json
# 4. Customer must already have an Azure Plan subscription

.\create-csp-subscriptions.ps1 `
    -CustomerTenantId "000" `
    -PartnerTenantId "0000" `
    -AppId "your-app-id-here" `
    -AppSecret "your-app-secret-here" `
    -SubscriptionsFile "./subscriptions.json"
