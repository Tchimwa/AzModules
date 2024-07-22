output "id" {
  value      = azurerm_key_vault.keyvault.id
  sensitive  = false
}

output "name" {
  value      = azurerm_key_vault.keyvault.name
  sensitive  = false
}

output "uri" {
  value      = azurerm_key_vault.keyvault.vault_uri
  sensitive  = false
}