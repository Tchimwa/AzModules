variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy the resources"
  type        = string
}

variable "vmss_name" {
  description = "The name of the Virtual Machine Scale Set"
  type        = string
}

variable "instance_count" {
  description = "The number of instances in the VMSS"
  type        = number
  default     = 2
}

variable "vm_size" {
  description = "The size of the Virtual Machines"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "The admin username for the VM instances"
  type        = string
}

variable "admin_password" {
  description = "The admin password for the VM instances"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "The ID of the subnet within the VNet where the VMSS will be deployed"
  type        = string
}

variable "custom_data" {
  description = "The custom script to install the Azure DevOps agent"
  type        = string
}

variable "load_balancer_name" {
  description = "The name of the Internal Load Balancer"
  type        = string
}

variable "backend_port" {
  description = "The backend port for the Internal Load Balancer"
  type        = number
  default     = 80
}

# Devops agent

variable "devops_url" {
    description = "URL of the Azure DevOps platform"
    type        = string
}

variable "devops_token" {
    description = "Token used for the deployment"
    type        = string
    sensitive   = true
}

variable "devops_agent_pool_name" {
    description = "Azure devOps agent pool name"
    type        = string












































    ]]]]]]]]]]
}