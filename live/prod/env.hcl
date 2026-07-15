locals {
  env = "prod"

  # Prod: strengeres Budget-Alerting
  budget_amount     = 1
  budget_threshold  = 20
  alert_emails      = ["liban@osman-home.de"]
}
