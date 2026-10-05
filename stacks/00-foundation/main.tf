resource "azurerm_resource_group" "rg" {
  name     = "rg-hubspoke-lab"
  location = "westeurope"
  tags = {
    proyecto = "azure-hub-spoke-avnm",
    entorno  = "lab",
    gestion  = "terraform"
  }
}