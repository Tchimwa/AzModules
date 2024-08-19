resource "azurerm_storage_account" "storage_account" {

  name                              = var.storagacc_name
  resource_group_name               = var.storagacc_resource_group_name
  location                          = var.storagacc_location
  account_tier                      = var.storagacc_tier
  account_replication_type          = var.storagacc_replication_type
  account_kind                      = var.storagacc_account_kind
  allow_nested_items_to_be_public   = var.storagacc_allow_blob_public_access
  min_tls_version                   = var.storagacc_min_tls_version
  infrastructure_encryption_enabled = var.storagacc_infrastructure_encryption_enabled
  is_hns_enabled                    = var.storagacc_is_hns_enabled
  sftp_enabled                      = var.storagacc_is_hns_enabled ? var.storagacc_is_sftp_enabled : false

  dynamic "identity" {
    for_each = var.storagacc_identity[*]
    iterator = identity_iterator
    content {
      type = identity_iterator.value.type
    }
  }

  dynamic "custom_domain" {
    for_each = var.storagacc_custom_domain[*]
    iterator = custom_domain_iterator
    content {
      name          = custom_domain_iterator.value.name
      use_subdomain = custom_domain_iterator.value.use_subdomain
    }
  }

}

resource "azurerm_role_assignment" "role_assignment" {

  for_each = var.storagacc_roles

  scope                = local.storagacc_id
  role_definition_name = each.value.role_definition_name
  role_definition_id   = each.value.role_definition_id
  principal_id         = each.value.principal_id

}

resource "azurerm_storage_container" "containers" {

  for_each = { for k, v in var.storagacc_containers : k => v }

  name                  = each.key
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = each.value.access_type
  
}

resource "azurerm_storage_share" "sa_shares" {

  for_each = var.storagacc_shares

  name                 = each.value.name
  access_tier          = "TransactionOptimized"
  quota                = 5120
  storage_account_name = azurerm_storage_account.storage_account.name

  depends_on = [
    azurerm_storage_container.containers
  ]
  
}

## Networking ##################################################################################

resource "azurerm_storage_account_network_rules" "network_rules" {

  storage_account_id         = azurerm_storage_account.storage_account.id
  default_action             = var.storagacc_secure_in_vnet ? "Deny" : "Allow"
  bypass                     = ["AzureServices"]
  ip_rules                   = length(var.storagacc_vnet_ip_whitelist) > 0 ? var.storagacc_vnet_ip_whitelist : null
  virtual_network_subnet_ids = length(var.storagacc_vnet_subnet_ids) > 0 ? var.storagacc_vnet_subnet_ids : null

  depends_on = [
    time_sleep.deploy_network_rules
  ]
  
}

resource "azurerm_private_endpoint" "private_endpoint" {

  for_each = {
    for name, storagacc_private_endpoint in var.storagacc_private_endpoints : name => storagacc_private_endpoint
    if(storagacc_private_endpoint.subresource_name == "blob" && var.storagacc_secure_in_vnet)
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = var.storagacc_location
  subnet_id           = each.value.subnet_id

  private_dns_zone_group {
    name                 = each.value.private_dnszone_group
    private_dns_zone_ids = [each.value.private_dnszone_id]
  }

  private_service_connection {
    name                           = "${each.value.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = local.storagacc_id
    subresource_names              = [each.value.subresource_name]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }

  depends_on = [
    azurerm_storage_account_network_rules.network_rules
  ]

}

resource "azurerm_private_endpoint" "private_endpoint_table" {

  for_each = {
    for name, storagacc_private_endpoint in var.storagacc_private_endpoints : name => storagacc_private_endpoint
    if(storagacc_private_endpoint.subresource_name == "table" && var.storagacc_secure_in_vnet)
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = var.storagacc_location
  subnet_id           = each.value.subnet_id

  private_dns_zone_group {
    name                 = each.value.private_dnszone_group
    private_dns_zone_ids = [each.value.private_dnszone_id]
  }

  private_service_connection {
    name                           = "${each.value.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = local.storagacc_id
    subresource_names              = [each.value.subresource_name]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }

  depends_on = [
      azurerm_private_endpoint.private_endpoint
  ]

}

resource "azurerm_private_endpoint" "private_endpoint_file" {

  for_each = {
    for name, storagacc_private_endpoint in var.storagacc_private_endpoints : name => storagacc_private_endpoint
    if(storagacc_private_endpoint.subresource_name == "file" && var.storagacc_secure_in_vnet)
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = var.storagacc_location
  subnet_id           = each.value.subnet_id

  private_dns_zone_group {
    name                 = each.value.private_dnszone_group
    private_dns_zone_ids = [each.value.private_dnszone_id]
  }

  private_service_connection {
    name                           = "${each.value.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = local.storagacc_id
    subresource_names              = [each.value.subresource_name]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }
  
  depends_on = [
    azurerm_private_endpoint.private_endpoint_table
  ]

}

resource "azurerm_private_endpoint" "private_endpoint_queue" {

  for_each = {
    for name, storagacc_private_endpoint in var.storagacc_private_endpoints : name => storagacc_private_endpoint
    if(storagacc_private_endpoint.subresource_name == "queue" && var.storagacc_secure_in_vnet)
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = var.storagacc_location
  subnet_id           = each.value.subnet_id

  private_dns_zone_group {
    name                 = each.value.private_dnszone_group
    private_dns_zone_ids = [each.value.private_dnszone_id]
  }

  private_service_connection {
    name                           = "${each.value.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = local.storagacc_id
    subresource_names              = [each.value.subresource_name]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }

  depends_on = [
    azurerm_private_endpoint.private_endpoint_file
  ]

}

resource "azurerm_private_endpoint" "private_endpoint_dfs" {

  for_each = {
    for name, storagacc_private_endpoint in var.storagacc_private_endpoints : name => storagacc_private_endpoint
    if(storagacc_private_endpoint.subresource_name == "dfs" && var.storagacc_secure_in_vnet)
  }

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = var.storagacc_location
  subnet_id           = each.value.subnet_id

  private_dns_zone_group {
    name                 = each.value.private_dnszone_group
    private_dns_zone_ids = [each.value.private_dnszone_id]
  }

  private_service_connection {
    name                           = "${each.value.name}-connection"
    is_manual_connection           = false
    private_connection_resource_id = local.storagacc_id
    subresource_names              = [each.value.subresource_name]
  }

  provisioner "local-exec" {
    command = "az resource wait --updated --ids ${self.subnet_id}"
  }

  depends_on = [
    azurerm_private_endpoint.private_endpoint_queue
  ]

}
