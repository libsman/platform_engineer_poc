# Golden Path: Static Web App (Workload)
# Free SKU — kostenloser Einstiegspunkt für statische Workloads.

resource "azurerm_static_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags
}
