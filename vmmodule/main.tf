# Create public IP
resource "azurerm_public_ip" "my_public_ip" {
  name                = "publicip-${var.vm_name}"
  location            = var.region
  resource_group_name = var.rg_name
  allocation_method   = "Dynamic"
}# Create network interface



resource "azurerm_network_interface" "my_nic" {
  name                = "nic-${var.vm_name}"
  location            = var.region
  resource_group_name = var.rg_name
  
  ip_configuration {
    name                          = "nic-${var.vm_name}-Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.my_public_ip.id
  }
  depends_on = [ azurerm_public_ip.my_public_ip ]
}

# Conecta NSG com VM
resource "azurerm_network_interface_security_group_association" "net_nsg_vm" {
  network_interface_id      = azurerm_network_interface.my_nic.id
  network_security_group_id = var.nsg_id

  depends_on = [ azurerm_network_interface.my_nic ]
}

# Gera texto randomico para storage
resource "random_id" "random_vm_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = var.rg_name
  }
  byte_length = 8
}

# Cria conta storage VM pra diagnosticar boot
resource "azurerm_storage_account" "my_vm_storage_account" {
  name                     = "diagboot${random_id.random_vm_id.hex}"
  location                 = var.region
  resource_group_name      = var.rg_name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [ random_id.random_vm_id ]
}







# Cria VM
resource "azurerm_linux_virtual_machine" "my_vm" {
  name                = var.vm_name
  location            = var.region
  resource_group_name = var.rg_name
  network_interface_ids = [
    azurerm_network_interface.my_nic.id
  ]
  size = var.vm_size
  
  os_disk {
    name              = "${var.vm_name}_OsDisk"
    caching           = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  
  computer_name  = var.vm_name
  admin_username = var.username
  
  admin_ssh_key {
    username   = var.username
    public_key = var.ssh_publickey
  }
  
  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_vm_storage_account.primary_blob_endpoint
  }

  lifecycle {
    ignore_changes = [ tags ]
  }

  depends_on = [
    azurerm_network_interface_security_group_association.net_nsg_vm,
    azurerm_storage_account.my_vm_storage_account
  ]
}