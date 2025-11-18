# Provider configuration for standalone module testing
# This file is only used when testing the module independently
provider "azurerm" {
  features {}
  skip_provider_registration = true
}
