variable "admin_username" {
  description = "The admin username for the virtual machine."
  type        = string
  default     = "acmedmin"
}

variable "project" {
  description = "The name of the project."
  type        = string
  default     = "piloto"
}

variable "location" {
  type        = string
  default     = "brazilsouth"
  description = "Location of the resources"
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subbackend_address_space" {
  description = "The address space for the backend subnet."
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "vm_sku" {
  description = "SKU for the VM."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vms_info" {
  description = "Configuration for each VM"
  type = list(object({
    name  = string
    group = string
  }))

  default = [
    {
      name  = "VM01"
      group = "web"
    },
    {
      name  = "VM02"
      group = "db"
    }
  ]
}