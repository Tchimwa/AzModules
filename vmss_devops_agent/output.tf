output "vmss_id" {
  description = "The ID of the VM Scale Set"
  value       = azurerm_windows_virtual_machine_scale_set.vmss.id
}

output "load_balancer_internal_ip" {
  description = "The internal IP address of the Load Balancer"
  value       = azurerm_lb.ilb.frontend_ip_configuration[0].private_ip_address
}
