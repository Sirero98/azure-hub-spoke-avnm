locals {
  rg_name = "rg-${var.project}-${var.environment}"
  tags = merge(
    var.tags,
    {
      proyecto = "azure-${var.project}-avnm"
      entorno  = var.environment
      gestion  = "terraform"
    }
  )
  avnm_name     = "avnm-${var.project}"
  vnet_hub_name = "vnet-hub"
  fw_private_ip = cidrhost(data.azurerm_subnet.fw.address_prefixes[0], 4)
  fw_routes = {
    default = "0.0.0.0/0"
    onprem  = "192.168.0.0/16"
  }
}
