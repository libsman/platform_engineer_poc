# Golden Path: Static Web App (Workload)
# Free SKU — 0 € — der Star der Demo ist die Plattform, nicht die App.

resource "azurerm_static_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags
}
