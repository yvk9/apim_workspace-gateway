terraform {
  required_version = "~> 1.14"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.79"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "~> 2.12"
    }
  }
}
