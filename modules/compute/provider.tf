# Provider configuration for standalone module testing
# This file is only used when testing the module independently
provider "azurerm" {
  features {}
  # Updated: skip_provider_registration deprecated in v5; use resource_provider_registrations
  resource_provider_registrations = "none"
}
