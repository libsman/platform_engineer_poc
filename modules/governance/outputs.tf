output "policy_assignment_ids" {
  description = "IDs of all policy assignments."
  value = [
    azurerm_subscription_policy_assignment.allowed_locations.id,
    azurerm_subscription_policy_assignment.allowed_locations_rg.id,
    azurerm_subscription_policy_assignment.require_env_tag_on_rg.id,
    azurerm_subscription_policy_assignment.inherit_env_tag.id,
  ]
}
