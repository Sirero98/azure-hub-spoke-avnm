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
  vnet_hub_name    = "vnet-hub"
  law_name         = "law-${var.project}-${var.environment}"
  pip_fw_name      = "pip-fw-hub"
  pip_fw_mgmt_name = "pip-fw-hub-mgmt"
  fw_policy_name   = "fwpol-hub"
  fw_name          = "fw-hub"
}