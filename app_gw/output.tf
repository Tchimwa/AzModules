output "appgw_frontend_ip" {
    value = azurerm_public_ip.appgw_pip.ip_address
    description = "Appgw frontend IP address"  
}