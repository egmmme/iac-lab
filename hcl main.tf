provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lab_rg" {
  name     = "lab-resource-group"
  location = "East US"
}