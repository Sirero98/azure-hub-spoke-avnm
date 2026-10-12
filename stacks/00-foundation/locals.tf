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
  monitoring_workspace_name = "law-${var.project}-${var.environment}"
}