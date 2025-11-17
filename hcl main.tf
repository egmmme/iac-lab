terraform {
  # Uncomment this block after creating a storage account for remote state
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatexxxxx"  # Must be globally unique
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = "13b98216-b11e-482f-b0a8-af5294c9f076"
}

resource "azurerm_resource_group" "lab_rg" {
  name     = "lab-resource-group"
  location = "East US"
}