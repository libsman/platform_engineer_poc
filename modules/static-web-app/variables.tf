variable "name" {
  description = "Name of the Static Web App."
  type        = string
}

variable "resource_group_name" {
  description = "Target resource group."
  type        = string
}

variable "location" {
  description = "Azure region (Static Web Apps: westeurope, eastus2, centralus, eastasia, westus2)."
  type        = string
  default     = "westeurope"
}

variable "tags" {
  description = "Governance tags."
  type        = map(string)
}
