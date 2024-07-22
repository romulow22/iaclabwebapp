output "network_interface_id" {
  value = azurerm_network_interface.my_nic.id
}

output "network_interface_name" {
  value = azurerm_network_interface.my_nic.name
}

output "storage_account_name" {
  value = azurerm_storage_account.my_vm_storage_account.name
}

output "storage_account_primary_blob_endpoint" {
  value = azurerm_storage_account.my_vm_storage_account.primary_blob_endpoint
}

output "virtual_machine_id" {
  value = azurerm_linux_virtual_machine.my_vm.id
}

output "virtual_machine_name" {
  value = azurerm_linux_virtual_machine.my_vm.name
}

output "private_ip_address" {
  value = azurerm_linux_virtual_machine.my_vm.private_ip_address
}

output "public_ip_address" {
  value = azurerm_linux_virtual_machine.my_vm.public_ip_address
}