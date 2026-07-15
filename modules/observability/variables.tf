variable "workspace_name" {
  description = "Name of the Log Analytics workspace."
  type        = string
}

variable "app_insights_name" {
  description = "Name of the Application Insights component."
  type        = string
}

variable "resource_group_name" {
  description = "Target resource group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "retention_in_days" {
  description = "Log retention in days (31 = free tier for Analytics logs)."
  type        = number
  default     = 31
}

variable "daily_quota_gb" {
  description = "Hard daily ingestion cap in GB (FinOps guard rail)."
  type        = number
  default     = 0.5
}

variable "tags" {
  description = "Governance tags."
  type        = map(string)
}
