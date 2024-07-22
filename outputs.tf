output "resource_group_name" {
  value       = azurerm_resource_group.rg.name
  description = "The name of the resource group"
}

output "virtual_network_id" {
  value       = azurerm_virtual_network.myvnet.id
  description = "The ID of the virtual network"
}

output "virtual_network_name" {
  value       = azurerm_virtual_network.myvnet.name
  description = "The name of the virtual network"
}

output "backend_subnet_id" {
  value       = azurerm_subnet.my_backend_subnet.id
  description = "The ID of the backend subnet"
}

output "backend_subnet_address_prefix" {
  value       = azurerm_subnet.my_backend_subnet.address_prefixes
  description = "The address prefix of the backend subnet"
}

output "network_security_group_web_id" {
  value       = azurerm_network_security_group.my_web_nsg.id
  description = "The ID of the network security group"
}

output "network_security_group_db_id" {
  value       = azurerm_network_security_group.my_db_nsg.id
  description = "The ID of the network security group"
}

output "network_security_group_web_name" {
  value       = azurerm_network_security_group.my_web_nsg.name
  description = "The name of the network security group"
}

output "network_security_group_db_name" {
  value       = azurerm_network_security_group.my_db_nsg.name
  description = "The name of the network security group"
}

output "vm_ids" {
  value       = [for vm in module.vm : vm.virtual_machine_id]
  description = "The IDs of the virtual machines"
}

output "private_ip_addresses" {
  value       = [for vm in module.vm : vm.private_ip_address]
  description = "The private IP addresses of the virtual machines"
}

output "public_ip_addresses" {
  value       = [for vm in module.vm : vm.public_ip_address]
  description = "The public IP addresses of the virtual machines"
}



