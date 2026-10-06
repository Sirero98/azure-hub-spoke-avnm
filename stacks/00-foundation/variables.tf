variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Location for the resources"
  type        = string
  default     = "westeurope"

  validation {
    condition     = contains(["westeurope", "northeurope"], var.location)
    error_message = "Location must be either 'westeurope' or 'northeurope'."
  }
}

variable "project" {
  description = "Project name for the resources"
  type        = string
  default     = "hubspoke"
}

variable "environment" {
  description = "Environment for the resources"
  type        = string
  default     = "lab"
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}

variable "hub_address_space" {
  description = "Address space for the hub"
  type        = string
}

variable "hub_subnets" {
  description = "Subnets for the hub"
  type        = map(string)
}