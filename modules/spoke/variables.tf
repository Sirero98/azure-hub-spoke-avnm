variable "name" {
  description = "Name of the VNet"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location for the resources"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = string

  validation {
    condition     = can(cidrhost(var.address_space, 0))
    error_message = "address_space debe ser un CIDR válido, por ejemplo 10.101.0.0/16."
  }
}

variable "workload_subnet_prefix" {
  description = "Prefix for the workload subnet"
  type        = string

  validation {
    condition     = can(cidrhost(var.workload_subnet_prefix, 0))
    error_message = "workload_subnet_prefix debe ser un CIDR válido, por ejemplo 10.101.1.0/24."
  }
}


variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}