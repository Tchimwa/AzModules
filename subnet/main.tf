# Subnet Resource
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "subnet" {
  name                              = var.subnet_name
  resource_group_name               = var.subnet_rg_name
  virtual_network_name              = var.subnet_vnet_name
  address_prefixes                  = var.subnet_address_prefixes
  service_endpoints                 = var.subnet_service_endpoints
  private_endpoint_network_policies = var.private_endpoint_network_policies
  provider                          = azurerm.vnet_subscription

  dynamic "delegation" {
    for_each = var.subnet_delegations
    content {
      name = delegation.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# NSG to apply to the subnet - There should always be a NSG attached to the subnet
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "nsg" {

  name                = var.subnet_nsg_name
  location            = var.subnet_location
  resource_group_name = var.subnet_rg_name
  tags                = var.subnet_nsg_tags # Needs to be discuss with Arun as tags vary from what we see from the portal

  dynamic "security_rule" {
    for_each = var.subnet_nsg_security_rules
    content {
      name                         = security_rule.value.name
      priority                     = security_rule.value.priority
      direction                    = security_rule.value.direction
      access                       = security_rule.value.access
      protocol                     = security_rule.value.protocol
      source_port_range            = security_rule.value.source_port_range
      destination_port_range       = security_rule.value.destination_port_range
      source_address_prefix        = security_rule.value.source_address_prefix
      source_address_prefixes      = security_rule.value.source_address_prefixes
      destination_address_prefix   = security_rule.value.destination_address_prefix
      destination_address_prefixes = security_rule.value.destination_address_prefixes
    }
  }

}

# NSG and subnet association
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association

resource "azurerm_subnet_network_security_group_association" "nsg_subnet_association" {

  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id

}

# UDR
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table

resource "azurerm_route_table" "udr" {

  count = var.deploy_route_table ? 1 : 0

  name                          = var.subnet_route_table_name
  location                      = var.subnet_location
  resource_group_name           = var.subnet_rg_name
  disable_bgp_route_propagation = false
  tags                          = var.subnet_nsg_tags

  dynamic "route" {
    for_each = var.subnet_routes
    content {
      name                   = route.key
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_type   
      next_hop_in_ip_address = route.value.next_hop_in_ip_address
    }
  }
}

# UDR and Subnet association
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association

resource "azurerm_subnet_route_table_association" "udr_subnet_association" {

  count = var.deploy_route_table ? 1 : 0

  subnet_id      = azurerm_subnet.subnet.id
  route_table_id = azurerm_route_table.udr[0].id
}
