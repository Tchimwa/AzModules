variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "subnet_vnet_name" {
  description = "virtual network name hosting the subnet"
  type        = string
}

variable "subnet_address_prefixes" {
  description = "Address Prefixes allocated to the subnet"
  type        = list(string)
}

variable "subnet_rg_name"{
  description = "Resource group name hosting the subnet"
  type        = string
}

variable "subnet_location" {
  description = "Virtual Network location"
  type        = string
}

variable "subnet_nsg_name"{
  description = "Name of the NSG associated to the subnet"
  type        = string
}

variable "subnet_service_endpoints" {
  description = "Service endpoints to associate with the subnet"
  type        = set(string)
  default     = []
}

variable "subnet_delegations" {
  description = "Map of the services delegated to this subnet"
  default     = {}

  type  = map(object({
    name         = string
    service_name = string
    actions      = list(string)
  }))
}

variable "private_endpoint_network_policies" {
  description = "Network Polictions to apply on the Private Endpoints hosted on the subnet"
  type        = string
  default     = "NetworkSecurityGroupEnabled"
}

variable "subnet_nsg_security_rules" {
  type = map(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = string
    destination_port_range       = string
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = {}
  description = "Map of the NSG rules to implement on the subnet"
}

# Needs to be discuss with Arun as tags vary from what we see from the portal
variable "subnet_nsg_tags" {
  type = object({
    Environment     = string
    ApplicationName = string
    Region          = string
  })
}

variable "deploy_route_table" {
  type        = bool
  default     = false
  description = "Deploying the UDR on the subnet"

}

variable "subnet_route_table_name" {
  type        = string
  description = "UDR Name"
}

variable "subnet_routes" {
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional (string)
  }))
}

