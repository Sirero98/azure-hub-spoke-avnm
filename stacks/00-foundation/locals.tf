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
  law_name = "law-${var.project}-${var.environment}"
  kv_name  = "kv-${var.project}-${var.environment}-${random_string.kv_suffix.result}"
}
