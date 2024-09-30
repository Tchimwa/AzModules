# Create Internal Load Balancer
resource "azurerm_lb" "ilb" {

  count = deploy_ilb : 1 : 0

  name                = var.load_balancer_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"

  frontend_ip_configuration {
    name                 = "${var.load_balancer_name}-Frontend"
    subnet_id            = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Backend Pool for Load Balancer
resource "azurerm_lb_backend_address_pool" "bepool" {

  count = deploy_ilb : 1 : 0

  loadbalancer_id = azurerm_lb.ilb[0].id
  name            = "${var.load_balancer_name}-backend-pool"
}

# Health Probe
resource "azurerm_lb_probe" "http_probe" {

  count = deploy_ilb : 1 : 0

  name                = "http_probe"
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.ilb[0].id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
}

# Load Balancer Rule
resource "azurerm_lb_rule" "lbrule" {

  count = deploy_ilb : 1 : 0

  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.ilb[0].id
  name                           = "http_rule"
  protocol                       = "Tcp"
  frontend_port                  = var.backend_port
  backend_port                   = var.backend_port
  frontend_ip_configuration_name = "${var.load_balancer_name}-Frontend"
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bepool[0].id
  probe_id                       = azurerm_lb_probe.http_probe[0].id
}

# Virtual Machine Scale Set
resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                = var.vmss_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = var.vm_size
  instances           = var.instance_count
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  upgrade_mode        = "Manual"

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.vmss_sku
    version   = "latest"
  }

  network_interface {
    name    = "${var.vmss_name}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.bepool[0].id
      ]
    }
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = file("scripts/vmss-agent.ps1")

  health_probe_id = azurerm_lb_probe.http_probe[0].id
}
