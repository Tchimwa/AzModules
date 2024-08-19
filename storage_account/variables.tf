variable "storagacc_name" {
  type        = string
  description = "(Required) Storage Account name"
}

variable "storagacc_location" {
  type        = string
  description = "(Required) Storage Account location"
}

variable "storagacc_resource_group_name" {
  type        = string
  description = "(Required) Storage Account Resource Group name"
}

variable "storagacc_tier" {
  type        = string
  description = "(Required) Storage Account Tier"
}

variable "storagacc_replication_type" {
  type        = string
  description = "(Required) Storage Account Replication Type"
}

variable "storagacc_account_kind" {
  type        = string
  description = "(Required) Storage Account kind"
}

variable "storagacc_allow_blob_public_access" {
  type        = string
  description = "(Required) Storage Account kind"
}

variable "storagacc_min_tls_version" {
  type        = string
  description = "(Required) Storage Account Minimum Tls Version"
}

# Optional

variable "storagacc_roles" {
  type = map(object({
    role_definition_name = string,
    role_definition_id   = string,
    principal_id         = string,
  }))
  default     = {}
  description = "RBAC roles to assign"
}

variable "storagacc_infrastructure_encryption_enabled" {
  type        = bool
  description = "(Optional) Storage Account infrastructure encryption enabled"
  default     = false
}

variable "storagacc_containers" {
  type = map(object({
    access_type = string # Container, Blob, private
  }))
  description = "(Optional) Storage Account containers"
  default     = {}
}

variable "storagacc_adls_gen2_filesystems" {
  type = map(object({
    access_type = string
  }))
  description = "(Optional) Storage Account ADLS Gen2 filesystems"
  default     = {}
}
variable "storagacc_shares" {
  type = map(object({
    name = string
  }))
  description = "(Optional) Storage Account shares"
  default     = {}
}

variable "storagacc_identity" {
  type = object({
    type = string
  })
  description = "(Optional) Storage Account identity"
  default     = null
}

variable "storagacc_custom_domain" {
  type = object({
    name          = string
    use_subdomain = bool
  })
  description = "(Optional) Storage Account Custom Domain"
  default     = null
}

variable "storagacc_is_hns_enabled" {
  type        = bool
  description = <<EOF
    (Optional) Is Hierarchical Namespace enabled? 
    This can be used with Azure Data Lake Storage Gen 2 
    (see https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-quickstart-create-account/ for more information). 
    Changing this forces a new resource to be created.
  EOF
  default     = false
}

variable "storagacc_is_sftp_enabled" {
  type        = bool
  description = <<EOF
    Only supported if storagacc_is_hns_enabled is set to "true".
  EOF
  default = false
}


## Networking #####################################################################################

variable "storagacc_secure_in_vnet" {
  type        = bool
  description = "If true, resource will be secured in a private VNET"
  default     = false
}

variable "storagacc_private_endpoints" {
  type = map(object({
    name                  = string
    subnet_id             = string
    subresource_name      = string
    resource_group_name   = optional(string)
    private_dnszone_id    = string
    private_dnszone_group = string
  }))
  description = "(Optional) Storage Account private endpoints"
  default     = {}
}

variable "storagacc_vnet_ip_whitelist" {
  type        = list(string)
  description = "IP addresses to whitelist for Storage Account"
  default     = []
}

variable "storagacc_vnet_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to whitelist for Storage Account"
  default     = []
}
