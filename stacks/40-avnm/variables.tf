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

variable "spokes" {
  description = "Spoke name => environment (prod | nonprod)"
  type        = map(string)

  validation {
    condition     = alltrue([for v in values(var.spokes) : contains(["prod", "nonprod"], v)])
    error_message = "All spoke environments must be either 'prod' or 'nonprod'."
  }
}