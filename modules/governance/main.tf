# Golden Path: Governance (Policy-as-Code)
# Built-in Azure Policies, per Code auf Subscription-Scope zugewiesen.
# 1. Allowed locations  -> Datenresidenz (EU only)
# 2. Require tag on RGs -> Kostentransparenz / FinOps
# 3. Audit untagged resources -> Compliance-Sichtbarkeit im Portal

data "azurerm_subscription" "current" {}

# --- Allowed locations (Deny) ---------------------------------------------
resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations"
  display_name         = "Allowed locations (EU only)"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  description          = "Deny deployments outside approved EU regions. Managed by Terraform."

  parameters = jsonencode({
    listOfAllowedLocations = { value = var.allowed_locations }
  })
}

# --- Require env tag on resource groups (Deny) -----------------------------
resource "azurerm_subscription_policy_assignment" "require_env_tag_on_rg" {
  name                 = "require-env-tag-rg"
  display_name         = "Require '${var.required_tag}' tag on resource groups"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025"
  description          = "Deny resource groups without the '${var.required_tag}' tag. Managed by Terraform."

  parameters = jsonencode({
    tagName = { value = var.required_tag }
  })
}

# --- Inherit env tag from resource group (Modify) ---------------------------
resource "azurerm_subscription_policy_assignment" "inherit_env_tag" {
  name                 = "inherit-env-tag"
  display_name         = "Inherit '${var.required_tag}' tag from resource group"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/cd3aa116-8754-49c9-a813-ad46512ece54"
  description          = "Auto-remediate: resources inherit the '${var.required_tag}' tag from their RG. Managed by Terraform."
  location             = var.allowed_locations[0]

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode({
    tagName = { value = var.required_tag }
  })
}

# Modify-Policies brauchen eine Managed Identity mit Contributor-Rechten
resource "azurerm_role_assignment" "inherit_env_tag_remediation" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Tag Contributor"
  principal_id         = azurerm_subscription_policy_assignment.inherit_env_tag.identity[0].principal_id
}
