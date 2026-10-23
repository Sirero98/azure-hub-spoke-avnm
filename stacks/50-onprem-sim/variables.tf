variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Location for the resources"
  type        = string

  validation {
    condition     = contains(["westeurope", "northeurope"], var.location)
    error_message = "Location must be either 'westeurope' or 'northeurope'."
  }
}

variable "project" {
  description = "Project name for the resources"
  type        = string
}

variable "environment" {
  description = "Environment for the resources"
  type        = string
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}

variable "onprem_address_space" {
  description = "Address space for the onprem"
  type        = string
}

variable "onprem_subnets" {
  description = "Subnets for the onprem"
  type        = map(string)
}

variable "azure_address_spaces" {
  description = "Azure address spaces reachable from on-prem (hub + spokes)"
  type        = list(string)

  validation {
    condition     = alltrue([for c in var.azure_address_spaces : can(cidrhost(c, 0))])
    error_message = "All azure_address_spaces must be valid CIDRs (e.g. 10.101.0.0/16)."
  }
}