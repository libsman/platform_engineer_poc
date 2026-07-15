variable "name" {
  description = "Name of the resource group."
  type        = string

  validation {
    condition     = can(regex("^rg-[a-z0-9-]+$", var.name))
    error_message = "Resource group names must follow the naming convention 'rg-<project>-<env>' (lowercase)."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Tags for the resource group. Governance tags are mandatory."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["env", "owner", "cost_center", "managed_by"] : contains(keys(var.tags), key)
    ])
    error_message = "Tags must include the governance keys: env, owner, cost_center, managed_by."
  }
}
