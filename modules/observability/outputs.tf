output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Log Analytics workspace."
  value       = azurerm_log_analytics_workspace.this.name
}

output "app_insights_id" {
  description = "Resource ID of the Application Insights component."
  value       = azurerm_application_insights.this.id
}

output "application_insights_connection_string" {
  description = "Connection string for the Application Insights component."
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}
