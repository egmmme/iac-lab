provider "azurerm" {
  features {}
  subscription_id = "13b98216-b11e-482f-b0a8-af5294c9f076"
}

resource "azurerm_resource_group" "lab_rg" {
  name     = "lab-resource-group"
  location = "East US"
}