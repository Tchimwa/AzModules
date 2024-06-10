output "id" {
  value       = azurerm_virtual_network.vnet.id
  description = "Virtual Network ID"

  depends_on = [
    azurerm_virtual_hub_connection.vnet_connection,
    azurerm_private_dns_zone_virtual_network_link.vlink
  ]
}

output "name" {
  value       = azurerm_virtual_network.vnet.name
  description = "Virtual Network Name"

  depends_on = [
    azurerm_virtual_hub_connection.vnet_connection,
    azurerm_private_dns_zone_virtual_network_link.vlink
  ]
}