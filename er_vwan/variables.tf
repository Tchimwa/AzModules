variable "deploy_ergw" {
  type        = bool
  default     = false
  description = "If yes, will deploy the ExR Gateway"
}

variable "deploy_er_circuit" {
  type        = bool
  default     = false
  description = "If yes, will deploy the ExR Circuit"
}

variable "er_gw_name" {
  type        = string
  default     = ""
  description = "Express Route Gateway name"
}

variable "er_rg_name" {
  type        = string
  description = "Express Route Gateway resource group name"
}

variable "er_location" {
  type        = string
  description = "Express Route location"
}

variable "er_gw_vhub_id" {
  type        = string
  default     = null
  description = "Associated virtual hub"
}

variable "er_gw_scale_units" {
  type        = number
  default     = 1
  description = "ExR scale units - 1U is 2 Gbps"
}

variable "er_port_name" {
  type        = string
  default     = ""
  description = "Express Route Gateway Port name"
}

variable "er_port_bandwidth" {
  type        = number
  default     = 10
  description = "ExR Port bandiwdth"
}

variable "er_port_encapsulation" {
  type        = string
  default     = "QinQ"
  description = "ExR encapsulation"
}

variable "er_peering_location" {
  type        = string
  default     = ""
  description = "Location of the peering circuit from the vendor"
}

variable "er_circuit_name" {
  type        = string
  default     = ""
  description = "ExR Circuit name"
}

variable "er_circuit_bandwidth" {
  type        = number
  default     = 1
  description = "ExR Circuit bandwidth"
}

variable "er_peer_asn" {
  type        = string
  default     = "Standard"
  description = "ExR SKU Tier"
}

variable "er_circuit_family" {
  type        = string
  default     = "MeteredData"
  description = "ExR Circuit Family.unlimited or MeteredData"
}

variable "er_peer_primary_address_prefix" {
  type        = string
  default     = ""
  description = "Address Prefix of the primary link"
}

variable "er_peer_secondary_address_prefix" {
  type        = string
  default     = ""
  description = "Address Prefix of the secondary link"
}

variable "er_peer_vlan_id" {
  type        = string
  default     = null
  description = "ID of the vHUB associated with the ExR circuit"
}
