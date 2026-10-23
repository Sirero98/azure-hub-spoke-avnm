variable "name" {
  description = "Name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for the resources"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the NIC will be attached"
  type        = string
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the admin user"
  type        = string

  validation {
    condition = (
      startswith(var.admin_ssh_public_key, "ssh-rsa ") ||
      startswith(var.admin_ssh_public_key, "ssh-ed25519 ")
    )
    error_message = "admin_ssh_public_key must be an OpenSSH public key (ssh-rsa or ssh-ed25519)."
  }
}

variable "custom_data" {
  description = "Cloud-init script (plain text). Encoded to base64 by the module."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags for the resources"
  type        = map(string)
  default     = {}
}