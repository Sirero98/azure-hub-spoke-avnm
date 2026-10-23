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
  vnet_onprem_name  = "vnet-onprem"
  vpngw_onprem_name = "vpngw-onprem"

}