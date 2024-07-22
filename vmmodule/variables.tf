variable "username" {
  description = "The admin username for the virtual machine"
  type        = string
}

variable "region" {
  description = "The region where the resources will be deployed"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the virtual machine will be deployed"
  type        = string
}

variable "nsg_id" {
  description = "The ID of the network security group associated with the network interface"
  type        = string
}

variable "vm_name" {
  description = "The name of the virtual machine"
  type        = string
}

variable "ssh_publickey" {
  description = "The SSH public key that will be used to access the virtual machine"
  type        = string
}

variable "vm_size" {
  description = "The SKU size of the virtual machine"
  type        = string
}