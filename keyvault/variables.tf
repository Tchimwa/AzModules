variable "keyvault_name" {
  type        = string
  description = "Keyvault name"
}

variable "keyvault_location" {
  type        = string
  description = "Keyvault location"
}

variable "keyvault_resource_group_name" {
  type        = string
  description = "Keyvault Resource Group name"
}

variable "keyvault_sku_name" {
  type        = string
  description = "Keyvault SKU name"
}

variable "keyvault_purge_protection_enabled" {
  type        = bool
  description = "Keyvault purge protection enabled"
  default     = true
}

variable "keyvault_enable_rbac_authorization" {
  type        = bool
  description = "Enable managing permissions using RBAC policies"
  default     = false
}

variable "keyvault_soft_delete_retention_days" {
  type        = number
  description = "Keyvault soft delete retention days"
  default     = 7
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID"
}

variable "keyvault_roles" {
  type = map(object({
    role_definition_name = string,
    role_definition_id   = string,
    principal_id         = string
  }))
  default     = {}
  description = "RBAC roles to assign to keyvault"
}

## Networking #####################################################################################

variable "deploy_keyvault_private_endpoint" {
  type        = bool
  description = "If true, Keyvault will be secured in a private VNET"
  default     = false
}

variable "keyvault_pe_name" {
    type = string
    description = "KV Private Endpoint name"
}

variable "keyvault_pe_subnet_id" {
    type = string
    description = "ID of the subnet hosting the KV PE"
}

variable "keyvault_private_dnszone_id" {
    type = string
    description = "KV Private DNS Zone ID"
}

variable "keyvault_vnet_ip_whitelist" {
  type        = list(string)
  description = "IP addresses to whitelist for Keyvault"
  default     = []
}
