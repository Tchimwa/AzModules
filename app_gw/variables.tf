variable "app_gw_rg_name" {
  description = "Name of the RG hosting the Application Gateway"
  default     = ""
  type        = string
}

variable "app_gw_location" {
  description = "The location/region of the App GW"
  default     = ""
  type        = string
}

variable "app_gw_pip" {
  description = "Name of the RG hosting the Application Gateway"
  default     = ""
  type        = string
}

variable "app_gw_zones" {
  description = "A collection of availability zones to spread the Application Gateway over."
  type        = list(string)
  default     = [] #["1", "2", "3"]
}

variable "app_gw_umi" {
  description = "User-managed Identity name"
  default     = ""
  type        = string
}

variable "app_gw_keyvault_id" {
  description = "The ID of the Keyvault that will keep the certificates used by the AppGW"
  default     = null
  type        = string
}

variable "app_gw_subnet_id" {
  type        = string
  description = "ID of the subnet hosting the application Gateway"
  default     = null
}

variable "app_gw_name" {
  description = "The name of the application gateway"
  default     = ""
}

variable "app_gw_enable_http2" {
  description = "Is HTTP2 enabled on the application gateway resource?"
  default     = false
  type        = bool
}

variable "app_gw_sku" {
  description = "The sku pricing model of v1 and v2"
  type = object({
    name     = string
    tier     = string
    capacity = optional(number)
  })
}

variable "app_gw_autoscale_configuration" {
  description = "Minimum or Maximum capacity for autoscaling. Accepted values are for Minimum in the range 0 to 100 and for Maximum in the range 2 to 125"
  type = object({
    min_capacity = number
    max_capacity = optional(number)
  })
  default = null
}

variable "app_gw_frontend_ip_configurations" {
  type = list(object({    
    name = string
    private_ip_address = optional(string)
  }))
  default = []
  description = "Frontend IP configurations"
}

variable "app_gw_frontend_ports" {
  type = list(object({
    name = string
    port = number
  }))
  default = []
  description = "Frontend ports"
}

variable "app_gw_backend_address_pools" {
  description = "List of backend address pools"
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "app_gw_backend_http_settings" {
  description = "List of backend HTTP settings."
  type = list(object({
    name                                = string
    cookie_based_affinity               = string
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    port                                = number	
    enable_https                        = bool
    probe_name                          = optional(string)
    request_timeout                     = number
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    trusted_root_certificate_names      = optional(list(string))    
  }))
}

variable "app_gw_http_listeners" {
  description = "List of HTTP/HTTPS listeners and SSL Certificate name is required"
  type = list(object({
    name                 = string
    feip_name            = string
    port_name            = string
    host_name            = optional(string)
    host_names           = optional(list(string))
    require_sni          = optional(bool)
    ssl_certificate_name = optional(string)
    ssl_profile_name     = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))
}

variable "app_gw_request_routing_rules" {
  description = "List of Request routing rules to be used for listeners."
  type = list(object({
    name                        = string
    priority                    = number
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
  }))
  default = []
}

variable "app_gw_trusted_root_certificates" {
  description = "Trusted root certificates to allow the backend with Azure Application Gateway"
  type = list(object({
    name = string
    data = string
  }))
  default = []
}

variable "app_gw_ssl_policy" {
  description = "Application Gateway SSL configuration"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string)
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = null
}

variable "app_gw_ssl_certificates" {
  description = "List of SSL certificates data for Application gateway"
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default = []
}

variable "app_gw_health_probes" {
  description = "List of Health probes used to test backend pools health."
  type = list(object({
    name                                      = string
    host                                      = string
    interval                                  = number
    path                                      = string
    timeout                                   = number
    unhealthy_threshold                       = number
    pick_host_name_from_backend_http_settings = optional(bool)
    minimum_servers                           = optional(number)
    match = optional(object({
      body        = optional(string)
      status_code = optional(list(string))
    }))
  }))
  default = []
}

variable "app_gw_url_path_maps" {
  description = "List of URL path maps associated to path-based rules."
  type = list(object({
    name                                = string
    default_backend_http_settings_name  = optional(string)
    default_backend_address_pool_name   = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    path_rules = list(object({
      name                        = string
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      paths                       = list(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
    }))
  }))
  default = []
}

variable "app_gw_redirect_configuration" {
  description = "list of maps for redirect configurations"
  type        = list(map(string))
  default     = []
}

variable "app_gw_custom_error_configuration" {
  description = "Global level custom error configuration for application gateway"
  type        = list(map(string))
  default     = []
}

variable "app_gw_rewrite_rule_set" {
  description = "List of rewrite rule set including rewrite rules"
  type        = any
  default     = []
}

variable "app_gw_tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}