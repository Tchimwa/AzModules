locals {
  storagacc_id                        = azurerm_storage_account.storage_account.id
  storagacc_name                      = azurerm_storage_account.storage_account.name
  storagacc_rg_name                   = azurerm_storage_account.storage_account.resource_group_name
  storagacc_primary_connection_string = azurerm_storage_account.storage_account.primary_connection_string
}