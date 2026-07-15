# Golden Path: FinOps Budget
# Consumption Budget auf Resource-Group-Scope mit Actual- und Forecast-Alerts.

resource "azurerm_consumption_budget_resource_group" "this" {
  name              = var.name
  resource_group_id = var.resource_group_id
  amount            = var.amount
  time_grain        = "Monthly"

  time_period {
    # Budgets müssen am Monatsersten starten
    start_date = var.start_date
  }

  # Alert bei tatsächlichem Verbrauch
  notification {
    enabled        = true
    threshold      = var.actual_threshold_percent
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.contact_emails
  }

  # Frühwarnung per Forecast
  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.contact_emails
  }
}
