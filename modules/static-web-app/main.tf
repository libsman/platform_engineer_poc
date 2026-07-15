# Golden Path: Static Web App (Workload)
# Free SKU — kostenloser Einstiegspunkt für statische Workloads.

resource "azurerm_static_web_app" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = "Free"
  sku_size            = "Free"
  tags                = var.tags

  lifecycle {
    # Wird vom Content-Deployment (SWA deploy action) gesetzt —
    # gehört zur App-Auslieferung, nicht zur Infrastruktur.
    ignore_changes = [repository_url, repository_branch]
  }
}
