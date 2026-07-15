output "id" {
  description = "Resource ID of the Static Web App."
  value       = azurerm_static_web_app.this.id
}

output "name" {
  description = "Name of the Static Web App."
  value       = azurerm_static_web_app.this.name
}

output "default_host_name" {
  description = "Default hostname of the Static Web App."
  value       = azurerm_static_web_app.this.default_host_name
}
