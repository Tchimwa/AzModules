## Express Route Gateway
## Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_gateway

resource "azurerm_express_route_gateway" "er_gw {

    count = var.deploy_ergw ? 1 : 0

    name                = var.er_gw_name
    resource_group_name = var.er_rg_name
    location            = var.er_location
    virtual_hub_id      = var.er_gw_vhub_id
    scale_units         = var.er_gw_scale_units
}

resource "azurerm_express_route_port" "er_port" {
    name                = var.er_port_name
    resource_group_name = var.er_rg_name
    location            = var.er_location
    peering_location    = var.er_peering_location
    bandwidth_in_gbps   = var.er_port_bandwidth
    encapsulation       = var.er_port_encapsulation
}

resource "azurerm_express_route_circuit" "er_circuit" {

    count = var.deploy_er_circuit ? 1 : 0

    name                  = var.er_circuit_name
    resource_group_name   = var.er_rg_name
    location              = var.er_location
    express_route_port_id = azurerm_express_route_port.er_port.id
    bandwidth_in_gbps     = var.er_circuit_bandwidth

  sku {
    tier   = var.er_circuit_sku_tier
    family = var.er_circuit_family
  }
}

resource "azurerm_express_route_circuit_peering" "er_peering" {
  peering_type                  = "AzurePrivatePeering"
  express_route_circuit_name    = azurerm_express_route_circuit.er_circuit[0].name
  resource_group_name           = var.er_rg_name

  peer_asn                      = var.er_peer_asn
  primary_peer_address_prefix   = var.er_peer_primary_address_prefix
  secondary_peer_address_prefix = var.er_peer_secondary_address_prefix
  vlan_id                       = var.er_peer_vlan_id
}

resource "azurerm_express_route_connection" "er_connection" {
  name                             = var.er_connection_name
  express_route_gateway_id         = var.deploy_ergw ? azurerm_express_route_gateway.er_gw[0].id ? var.er_gw_id
  express_route_circuit_peering_id = var.deploy_er_circuit ? azurerm_express_route_circuit_peering.er_peering.id ? var.er_circuit_peering_id
}