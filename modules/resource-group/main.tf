# Golden Path: Resource Group
# Erzwingt Governance-Tags bereits auf Modul-Ebene (Shift-Left),
# zusätzlich zur Azure-Policy-Enforcement-Ebene (Defense in Depth).

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}
