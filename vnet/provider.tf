terraform {

  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = ">= 3.107.0"
      configuration_aliases = [azurerm.vhub_subscription, azurerm.private_dnszone_subscription, azurerm.remote_hub_vnet_subscription]
    }
  }
}
