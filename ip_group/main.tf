resource "azurerm_ip_group" "ip_group" {
  name                = var.ip_group_name
  location            = var.ip_group_location
  resource_group_name = var.ip_group_rg_name
}

resource "azurerm_ip_group_cidr" "cidr" {
  for_each    = var.ip_group_cidrs
  
  cidr        = each.value.cidr  
  ip_group_id = azurerm_ip_group.ip_group.id
     
}