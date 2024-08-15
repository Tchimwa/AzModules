# Public IP 
## Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "appgw_pip" {
  name                = var.app_gw_pip
  resource_group_name = var.app_gw_rg_name
  location            = var.app_gw_location
  zones               = var.app_gw_zones
  allocation_method   = "Static"
  sku                 = "Standard"
}

# User Managed Identity to pull the certificate from the Keyvault
## Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity

resource "azurerm_user_assigned_identity" "appgw_umi" {
  name                = var.app_gw_umi
  resource_group_name = var.app_gw_rg_name
  location            = var.app_gw_location
}

# Keyvault Access policy for the UMI
## Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment

resource "azurerm_role_assignment" "role_assignment_umi" {

  scope                = var.app_gw_keyvault_id
  role_definition_name = "Key Vault Secrets User"
  role_definition_id   = null
  principal_id         = azurerm_user_assigned_identity.appgw_umi.principal_id

}

#resource "azurerm_key_vault_access_policy" "umi_kv_policy" {
#  key_vault_id = var.app_gw_keyvault_id
#  tenant_id    = var.app_gw_tenant_id
#  object_id    = azurerm_user_assigned_identity.appgw_umi.principal_id
#  
#  key_permissions = [
#    "get", "list",
#  ]  
#  secret_permissions = [
#    "get", "list",
#  ]
#  certificate_permissions = [ 
#    "get", "list" ]
#}

# Application Gateway 
## Reference: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_gateway

resource "azurerm_application_gateway" "appgw" {
  name                = var.app_gw_name
  resource_group_name = var.app_gw_rg_name
  location            = var.app_gw_location
  enable_http2        = var.app_gw_enable_http2
  zones               = var.app_gw_zones
  tags                = var.app_gw_tags

  sku {
    name     = var.app_gw_sku.name
    tier     = var.app_gw_sku.tier
    capacity = var.autoscale_configuration == null ? var.app_gw_sku.capacity : null
  }

  identity {
    type = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.appgw_umi.id]
  }

  gateway_ip_configuration {
    name      = "${var.app_gw_name}-gwip"
    subnet_id = var.app_gw_subnet_id
  }

  dynamic "autoscale_configuration" {
    for_each = var.app_gw_autoscale_configuration != null ? [var.app_gw_autoscale_configuration] : []
    content {
      min_capacity = lookup(autoscale_configuration.value, "min_capacity", 2)
      max_capacity = lookup(autoscale_configuration.value, "max_capacity", 10)
    }
  }
  
  dynamic "frontend_ip_configuration " { 
    for_each = var.app_gw_frontend_ip_configurations
    content {
    name                          = frontend_ip_configuration.value.name
    public_ip_address_id          = azurerm_public_ip.appgw_pip.id
    private_ip_address            = frontend_ip_configuration.value.private_ip_address != null ? frontend_ip_configuration.value.private_ip_address : null
    private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address != null ? "Static" : null
    subnet_id                     = frontend_ip_configuration.value.private_ip_address != null ? var.app_gw_subnet_id : null
    }
  }

  dynamic "frontend_port" {
    for_each = var.app_gw_frontend_ports
    content {
        name = frontend_port.value.name
        port = frontend_port.value.port
    }
  }

  dynamic "backend_address_pool" {
    for_each = var.app_gw_backend_address_pools
    content {
      name         = backend_address_pool.value.name
      fqdns        = backend_address_pool.value.fqdns
      ip_addresses = backend_address_pool.value.ip_addresses
    }
  }

  dynamic "backend_http_settings" {
    for_each = var.app_gw_backend_http_settings
    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = lookup(backend_http_settings.value, "cookie_based_affinity", "Disabled")
      affinity_cookie_name                = lookup(backend_http_settings.value, "affinity_cookie_name", null)
      path                                = lookup(backend_http_settings.value, "path", "/")
      port                                = backend_http_settings.value.port
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      protocol                            = backend_http_settings.value.enable_https ? "Https" : "Http"
      request_timeout                     = lookup(backend_http_settings.value, "request_timeout", 30)
      host_name                           = backend_http_settings.value.pick_host_name_from_backend_address == false ? lookup(backend_http_settings.value, "host_name") : null
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)
      trusted_root_certificate_names      = lookup(backend_http_settings.value, "trusted_root_certificate_names", null)

    }
  }

  dynamic "http_listener" {
    for_each = var.app_gw_http_listeners
    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.feip_name
      frontend_port_name             = http_listener.value.port_name
      host_name                      = lookup(http_listener.value, "host_name", null)
      host_names                     = lookup(http_listener.value, "host_names", null)
      protocol                       = http_listener.value.ssl_certificate_name == null ? "Http" : "Https"
      require_sni                    = http_listener.value.ssl_certificate_name != null ? http_listener.value.require_sni : null
      ssl_certificate_name           = http_listener.value.ssl_certificate_name
      ssl_profile_name               = http_listener.value.ssl_profile_name

      dynamic "custom_error_configuration" {
        for_each = http_listener.value.custom_error_configuration != null ? lookup(http_listener.value, "custom_error_configuration", {}) : []
        content {
          custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
          status_code           = lookup(custom_error_configuration.value, "status_code", null)
        }
      }
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.app_gw_request_routing_rules
    content {
      name                        = request_routing_rule.value.name
      priority                    = request_routing_rule.value.priority
      rule_type                   = lookup(request_routing_rule.value, "rule_type", "Basic")
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = request_routing_rule.value.redirect_configuration_name == null ? request_routing_rule.value.backend_address_pool_name : null
      backend_http_settings_name  = request_routing_rule.value.redirect_configuration_name == null ? request_routing_rule.value.backend_http_settings_name : null
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
    }
  }  

  dynamic "trusted_root_certificate" {
    for_each = var.app_gw_trusted_root_certificates
    content {
      name = trusted_root_certificate.value.name
      data = filebase64(trusted_root_certificate.value.data)
    }
  }

  # SSL Policy for Application Gateway (Optional)
  ## https://learn.microsoft.com/en-us/azure/application-gateway/application-gateway-ssl-policy-overview#predefined-tls-policy

  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []
    content {
      disabled_protocols   = var.ssl_policy.policy_type == null || var.ssl_policy.policy_name == null ? var.ssl_policy.disabled_protocols : null
      policy_type          = lookup(var.ssl_policy, "policy_type", "Predefined")
      policy_name          = var.ssl_policy.policy_type == "Predefined" ? var.ssl_policy.policy_name : null
      cipher_suites        = var.ssl_policy.policy_type == "Custom" ? var.ssl_policy.cipher_suites : null
      min_protocol_version = var.ssl_policy.policy_type == "Custom" ? var.ssl_policy.min_protocol_version : null
    }
  }

  dynamic "ssl_certificate" {
    for_each = var.app_gw_ssl_certificates
    content {
      name                = ssl_certificate.value.name
      data                = ssl_certificate.value.key_vault_secret_id == null ? filebase64(ssl_certificate.value.data) : null
      password            = ssl_certificate.value.key_vault_secret_id == null ? ssl_certificate.value.password : null
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  dynamic "probe" {
    for_each = var.app_gw_health_probes
    content {
      name                                      = probe.value.name
      port                                      = probe.value.port
      protocol                                  = probe.value.protocol
      host                                      = probe.value.pick_host_name_from_backend_http_settings ? null : lookup(probe.value, "host", "127.0.0.1")
      interval                                  = lookup(probe.value, "interval", 30)
      path                                      = lookup(probe.value, "path", "/")
      timeout                                   = lookup(probe.value, "timeout", 30)
      unhealthy_threshold                       = lookup(probe.value, "unhealthy_threshold", 3)
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
      minimum_servers                           = lookup(probe.value, "minimum_servers", 0)
    }
  }

  dynamic "url_path_map" {
    for_each = var.app_gw_url_path_maps
    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = url_path_map.value.default_redirect_configuration_name == null ? url_path_map.value.default_backend_address_pool_name : null
      default_backend_http_settings_name  = url_path_map.value.default_redirect_configuration_name == null ? url_path_map.value.default_backend_http_settings_name : null
      default_redirect_configuration_name = lookup(url_path_map.value, "default_redirect_configuration_name", null)
      default_rewrite_rule_set_name       = lookup(url_path_map.value, "default_rewrite_rule_set_name", null)

      dynamic "path_rule" {
        for_each = lookup(url_path_map.value, "path_rules")
        content {
          name                        = path_rule.value.name
          backend_address_pool_name   = path_rule.value.backend_address_pool_name
          backend_http_settings_name  = path_rule.value.backend_http_settings_name
          paths                       = flatten(path_rule.value.paths)
          redirect_configuration_name = lookup(path_rule.value, "redirect_configuration_name", null)
          rewrite_rule_set_name       = lookup(path_rule.value, "rewrite_rule_set_name", null)
        }
      }
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.app_gw_redirect_configuration
    content {
      name                 = lookup(redirect_configuration.value, "name", null)
      redirect_type        = lookup(redirect_configuration.value, "redirect_type", "Permanent")
      target_listener_name = lookup(redirect_configuration.value, "target_listener_name", null)
      target_url           = lookup(redirect_configuration.value, "target_url", null)
      include_path         = lookup(redirect_configuration.value, "include_path", "true")
      include_query_string = lookup(redirect_configuration.value, "include_query_string", "true")
    }
  }

  dynamic "custom_error_configuration" {
    for_each = var.app_gw_custom_error_configuration
    content {
      custom_error_page_url = lookup(custom_error_configuration.value, "custom_error_page_url", null)
      status_code           = lookup(custom_error_configuration.value, "status_code", null)
    }
  }

  dynamic "rewrite_rule_set" {
    for_each = var.app_gw_rewrite_rule_set
    content {
      name = var.app_gw_rewrite_rule_set.name

      dynamic "rewrite_rule" {
        for_each = lookup(var.app_gw_rewrite_rule_set, "rewrite_rules", [])
        content {
          name          = rewrite_rule.value.name
          rule_sequence = rewrite_rule.value.rule_sequence

          dynamic "condition" {
            for_each = lookup(rewrite_rule_set.value, "condition", [])
            content {
              variable    = condition.value.variable
              pattern     = condition.value.pattern
              ignore_case = condition.value.ignore_case
              negate      = condition.value.negate
            }
          }

          dynamic "request_header_configuration" {
            for_each = lookup(rewrite_rule.value, "request_header_configuration", [])
            content {
              header_name  = request_header_configuration.value.header_name
              header_value = request_header_configuration.value.header_value
            }
          }

          dynamic "response_header_configuration" {
            for_each = lookup(rewrite_rule.value, "response_header_configuration", [])
            content {
              header_name  = response_header_configuration.value.header_name
              header_value = response_header_configuration.value.header_value
            }
          }

          dynamic "url" {
            for_each = lookup(rewrite_rule.value, "url", [])
            content {
              path         = url.value.path
              query_string = url.value.query_string
              reroute      = url.value.reroute
            }
          }
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

