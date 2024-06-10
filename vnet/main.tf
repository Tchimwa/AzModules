# Virtual Network resource
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  resource_group_name = var.vnet_rg_name
  location            = var.vnet_location
  address_space       = var.vnet_address_space
  dns_servers         = var.vnet_dns_servers
  tags                = var.vnet_tags         # Needs to be discuss with Arun as tags vary from what we see from the portal
  
  dynamic "ddos_protection_plan" {
    for_each = var.vnet_ddos_protection_plan != null ? [var.vnet_ddos_protection_plan] : []
    content {
      id     = ddos_protection_plan.value.id
      enable = ddos_protection_plan.value.enable
    }
  }
}

# Virtual Hub Connection to the VWAN
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection#example-usage

resource "azurerm_virtual_hub_connection" "vnet_connection" {

  count = var.vnet_link_to_vhub ? 1 : 0

  provider                  = azurerm.vhub_subscription
  name                      = var.vnet_name
  virtual_hub_id            = var.vnet_vhub_id
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
  internet_security_enabled = true


}

# Private DNS zone virtual link if needed
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link

resource "azurerm_private_dns_zone_virtual_network_link" "vlink" {

  for_each = { for key, value in var.private_dnszones : key => value }

  provider              = azurerm.private_dnszone_subscription
  name                  = "${azurerm_virtual_network.vnet.name}-vlink"
  resource_group_name   = each.value.private_dnszone_rg_name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  private_dns_zone_name = each.value.private_dnszone_name

}