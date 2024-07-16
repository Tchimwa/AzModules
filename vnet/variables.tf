variable "vnet_name" {
  type        = string
  description = "Name of the global vnet"
}

variable "vnet_vhub_id" {
  type        = string
  description = "ID of the global vhub"
  default     = null
}

variable "vnet_rg_name" {
  type        = string
  description = "Name of the the RG hosting the global vnet"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "Address space of the global vnet"
}

variable "vnet_location" {
  type        = string
  description = "Location of the global vnet"
}

variable "vnet_link_to_vhub" {
  type        = bool
  description = "Need to link the vnet to the vHUB"
  default     = true
}

variable "private_dnszones" {
  type = map(object({
    private_dnszone_name    = string
    private_dnszone_rg_name = string
  }))
  default = {}
}

variable "vnet_dns_servers" {
  type        = list(string)
  description = "List of custom DNS servers attached to the VNET"
  default     = []
}

variable "vnet_ddos_protection_plan" {
  type = object({    
    id     = string
    enable = bool
  })
  default     = null
  description = "VNET DDoS protection Plan"
}

variable "remote_hub_vnet_name" {
  type        = string
  description = "Remote VNET name to peer"
}

variable "remote_hub_vnet_rg_name" {
  type        = string
  description = "Resource Group hosting the remote VNET"
}

variable "remote_hub_vnet_id" {
  type        = string
  description = "Remote VNET ID"
} 

variable "remote_hub_vnet_address_space" {
  type        = list(string)
  description = "Address Space of the remote VNET"
}

# Needs to be discuss with Arun as tags vary from what we see from the portal
variable "vnet_tags" {
  type = object({
    Environment      = string
    ApplicationName  = string
    Region           = string
  })
}
