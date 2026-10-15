variable "name" {
  description = "Name of the VPN Gateway"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Location of the resource group"
  type        = string
}

variable "gateway_subnet_id" {
  description = "ID of the gateway subnet"
  type        = string

  validation {
    condition     = endswith(var.gateway_subnet_id, "/subnets/GatewaySubnet")
    error_message = "The gateway_subnet_id variable must point to the GatewaySubnet."
  }
}

variable "sku" {
  description = "The SKU of the VPN Gateway. Possible values are: VpnGw1AZ, VpnGw2AZ, VpnGw3AZ, VpnGw4AZ, VpnGw5AZ"
  type        = string
  default     = "VpnGw1AZ"

  validation {
    condition     = endswith(var.sku, "AZ")
    error_message = "The sku variable must be an Availability Zone SKU (e.g., VpnGw1AZ, VpnGw2AZ, etc.)."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}