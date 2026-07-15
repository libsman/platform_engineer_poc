variable "name" {
  description = "Name of the budget."
  type        = string
}

variable "resource_group_id" {
  description = "Scope: resource group ID the budget applies to."
  type        = string
}

variable "amount" {
  description = "Monthly budget amount in the billing currency."
  type        = number
  default     = 1
}

variable "start_date" {
  description = "Budget period start (must be first of month, RFC3339, e.g. 2026-07-01T00:00:00Z)."
  type        = string
}

variable "actual_threshold_percent" {
  description = "Alert threshold for actual spend (percent of budget)."
  type        = number
  default     = 50
}

variable "contact_emails" {
  description = "E-mail recipients for budget alerts."
  type        = list(string)
}
