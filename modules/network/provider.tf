# Provider configuration for standalone module testing
# This file is only used when testing the module independently
provider "azurerm" {
  features {}
  resource_provider_registrations = "none"
}
