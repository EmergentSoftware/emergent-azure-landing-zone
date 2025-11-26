# =============================================================================
# Pre-Bootstrap Outputs
# =============================================================================

output "management_subscription_id" {
  description = "Management subscription ID for bootstrap layer"
  value = var.create_management_subscription ? (
    var.billing_model == "CSP" ?
    jsondecode(azapi_resource.management_subscription_csp[0].output).properties.subscriptionId :
    jsondecode(azapi_resource.management_subscription[0].output).properties.subscriptionId
  ) : var.management_subscription_id
}

output "corp_subscription_ids" {
  description = "Corp landing zone subscription IDs"
  value = var.billing_model == "CSP" ? {
    for k, v in azapi_resource.corp_subscriptions_csp :
    k => jsondecode(v.output).properties.subscriptionId
    } : {
    for k, v in azapi_resource.corp_subscriptions :
    k => jsondecode(v.output).properties.subscriptionId
  }
}

output "online_subscription_ids" {
  description = "Online landing zone subscription IDs"
  value = var.billing_model == "CSP" ? {
    for k, v in azapi_resource.online_subscriptions_csp :
    k => jsondecode(v.output).properties.subscriptionId
    } : {
    for k, v in azapi_resource.online_subscriptions :
    k => jsondecode(v.output).properties.subscriptionId
  }
}

output "all_subscription_ids" {
  description = "All created subscription IDs"
  value = merge(
    {
      management = var.create_management_subscription ? (
        var.billing_model == "CSP" ?
        jsondecode(azapi_resource.management_subscription_csp[0].output).properties.subscriptionId :
        jsondecode(azapi_resource.management_subscription[0].output).properties.subscriptionId
      ) : var.management_subscription_id
    },
    var.billing_model == "CSP" ? {
      for k, v in azapi_resource.corp_subscriptions_csp :
      "corp_${k}" => jsondecode(v.output).properties.subscriptionId
      } : {
      for k, v in azapi_resource.corp_subscriptions :
      "corp_${k}" => jsondecode(v.output).properties.subscriptionId
    },
    var.billing_model == "CSP" ? {
      for k, v in azapi_resource.online_subscriptions_csp :
      "online_${k}" => jsondecode(v.output).properties.subscriptionId
      } : {
      for k, v in azapi_resource.online_subscriptions :
      "online_${k}" => jsondecode(v.output).properties.subscriptionId
    }
  )
}
