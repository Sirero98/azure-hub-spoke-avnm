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

variable "vms" {
  description = "Test VMs: name => { vnet, subnet }"
  type = map(object({
    vnet   = string
    subnet = string
  }))
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key used for the admin user"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}
