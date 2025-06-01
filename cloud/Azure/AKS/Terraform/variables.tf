variable "location" {
  type    = string
  default = "East US"
}

variable "az_rg_name" {
  type    = string
  default = "ec-kube1-rg"
}

variable "az_kc_name" {
  type    = string
  default = "ec-kube1"
}

variable "az_kc_default_node_pool_name" {
  type    = string
  default = "default"
}

variable "az_kc_identity_type" {
  type    = string
  default = "SystemAssigned"
}

resource "azurerm_resource_group" "az_rg" {
  name     = var.az_rg_name
  location = var.location
}