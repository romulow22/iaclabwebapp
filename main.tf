################# LANDING ZONE ######################

# Gerar grupo de recursos 
resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.project}-rg"
}

# Criar Rede Virtual 
resource "azurerm_virtual_network" "myvnet" {
  name                = "${var.project}-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_resource_group.rg]
}

# Criar SubNet para Servidores Backend 
resource "azurerm_subnet" "my_backend_subnet" {
  name                 = "${var.project}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myvnet.name
  address_prefixes     = var.subbackend_address_space

  depends_on = [azurerm_virtual_network.myvnet, azurerm_resource_group.rg]
}


# Criar grupo de seguranca de rede e regra 
resource "azurerm_network_security_group" "my_web_nsg" {
  name                = "${var.project}web-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "myNSGRuleHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["80"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "myNSGRuleSSH"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.rg]
}


# Criar grupo de seguranca de rede e regra 
resource "azurerm_network_security_group" "my_db_nsg" {
  name                = "${var.project}db-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "myNSGRuleSSH"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_ranges    = ["22"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.rg]
}

#################### SSH KEYS ###########################

/**
resource "random_pet" "ssh_key_name" {
  prefix    = "ssh"
  separator = ""
}

resource "azapi_resource_action" "ssh_public_key_gen" {
  type                   = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  resource_id            = azapi_resource.ssh_public_key.id
  action                 = "generateKeyPair"
  method                 = "POST"
  response_export_values = ["publicKey", "privateKey"]
  depends_on             = [azapi_resource.ssh_public_key]
}

resource "azapi_resource" "ssh_public_key" {
  type       = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  name       = random_pet.ssh_key_name.id
  location   = azurerm_resource_group.rg.location
  parent_id  = azurerm_resource_group.rg.id
  depends_on = [random_pet.ssh_key_name, azurerm_resource_group.rg]
}

resource "local_file" "private_key" {
  content    = azapi_resource_action.ssh_public_key_gen.output.privateKey
  filename   = "private_key.pem"
  depends_on = [azapi_resource_action.ssh_public_key_gen]
}

**/


resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content               = tls_private_key.ssh_key.private_key_pem
  filename              = "private_key.pem"
  file_permission       = "0600"
}

resource "local_file" "public_key" {
  content               = tls_private_key.ssh_key.public_key_openssh
  filename              = "public_key.pem"
  file_permission       = "0600"
}


locals {
  nsg_ids = {
    "web" = azurerm_network_security_group.my_web_nsg.id
    "db"  = azurerm_network_security_group.my_db_nsg.id
  }
}

################ VIRTUAL MACHINE #############################
module "vm" {
  source        = "./vmmodule"
  count         = length(var.vms_info)
  vm_name       = "${var.project}${var.vms_info[count.index].name}"
  vm_size       = var.vm_sku
  username      = var.admin_username
  region        = azurerm_resource_group.rg.location
  rg_name       = azurerm_resource_group.rg.name
  subnet_id     = azurerm_subnet.my_backend_subnet.id
  nsg_id        = local.nsg_ids[var.vms_info[count.index].group]
  #ssh_publickey = azapi_resource_action.ssh_public_key_gen.output.publicKey
  ssh_publickey = tls_private_key.ssh_key.public_key_openssh
  #depends_on    = [azapi_resource_action.ssh_public_key_gen, azurerm_network_security_group.my_web_nsg, azurerm_network_security_group.my_db_nsg, azurerm_subnet.my_backend_subnet, azurerm_resource_group.rg]
  depends_on    = [tls_private_key.ssh_key, azurerm_network_security_group.my_web_nsg, azurerm_network_security_group.my_db_nsg, azurerm_subnet.my_backend_subnet, azurerm_resource_group.rg]
}

################ ANSIBLE INVENTORY FILE #############################
resource "local_file" "ansible_inventory" {
  content = templatefile("ansible/ansible_inventory.tpl", {
    web_ips = [for i in range(length(var.vms_info)) : module.vm[i].public_ip_address if var.vms_info[i].group == "web"],
    db_ips  = [for i in range(length(var.vms_info)) : module.vm[i].public_ip_address if var.vms_info[i].group == "db"],
    vm_user = var.admin_username
  })
  filename   = "ansible/ansible_inventory.yml"
  depends_on = [module.vm]
}