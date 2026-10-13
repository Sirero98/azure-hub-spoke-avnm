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

variable "ip_groups" {
  description = "IP Groups: name => list of CIDRs"
  type        = map(list(string))

  validation {
    condition = alltrue([
      for c in flatten(values(var.ip_groups)) : can(cidrhost(c, 0))
    ])
    error_message = "All CIDRs in ip_groups must be valid (e.g. 10.101.0.0/16)."
  }
}