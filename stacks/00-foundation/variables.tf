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

variable "hub_address_space" {
  description = "Address space for the hub"
  type        = string
}

variable "hub_subnets" {
  description = "Subnets for the hub"
  type        = map(string)
}

variable "spokes" {
  description = "Map of spoke VNets keyed by spoke name"
  type = map(object({
    address_space   = string
    workload_subnet = string
    env             = string
  }))

  validation {
    condition = alltrue([
      for name, spoke in var.spokes : contains(["prod", "nonprod"], spoke.env)
    ])
    error_message = "El campo env de cada spoke debe ser 'prod' o 'nonprod'."
  }
}