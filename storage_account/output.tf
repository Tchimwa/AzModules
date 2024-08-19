output "id" {
  value = local.storagacc_id
}

output "name" {
  value = local.storagacc_name
}

output "container_names" {
  value = azurerm_storage_container.containers
}

output "primary_access_key" {
  value = azurerm_storage_account.storage_account.primary_access_key
}

output "primary_connection_string" {
  value = local.storagacc_primary_connection_string
}

output "primary_blob_host" {
  value = azurerm_storage_account.storage_account.primary_blob_endpoint
}