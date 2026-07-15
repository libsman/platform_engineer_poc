variable "allowed_locations" {
  description = "List of allowed Azure regions (data residency)."
  type        = list(string)
  default     = ["westeurope", "germanywestcentral", "northeurope"]
}

variable "required_tag" {
  description = "Tag that must be present on every resource group."
  type        = string
  default     = "env"
}
