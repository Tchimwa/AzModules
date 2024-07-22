# Keyvault
# Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault

resource "azurerm_key_vault" "keyvault" {

  name                            = var.keyvault_name
  location                        = var.keyvault_location
  resource_group_name             = var.keyvault_resource_group_name
  sku_name                        = var.keyvault_sku_name
  tenant_id                       = var.tenant_id
  soft_delete_retention_days      = var.keyvault_soft_delete_retention_days
  purge_protection_enabled        = var.keyvault_purge_protection_enabled
  enabled_for_disk_encryption     = true
  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  public_network_access_enabled   = var.deploy_keyvault_private_endpoint ? false : true
  enable_rbac_authorization       = var.keyvault_enable_rbac_authorization

  network_acls {
    default_action = var.deploy_keyvault_private_endpoint ? "Deny" : "Allow"
    bypass         = "AzureServices"
    ip_rules       = length(var.keyvault_vnet_ip_whitelist) > 0 ? var.keyvault_vnet_ip_whitelist : null
  }

}

# Private endpoint

resource "azurerm_private_endpoint" "private_endpoint" {

  count = var.deploy_keyvault_private_endpoint ? 1 : 0

  name                = var.keyvault_pe_name
  location            = azurerm_key_vault.keyvault.location
  resource_group_name = azurerm_key_vault.keyvault.resource_group_name
  subnet_id           = var.keyvault_pe_subnet_id

  private_dns_zone_group {
    name                 = "${azurerm_key_vault.keyvault.name}-dns-group"
    private_dns_zone_ids = [var.keyvault_private_dnszone_id]
  }

  private_service_connection {
    name                           = "${azurerm_key_vault.keyvault.name}-pvt-svc-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.keyvault.id
    subresource_names              = ["vault"]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }

}