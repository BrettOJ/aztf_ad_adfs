
variable "location" {
  description = "(Required) Location of the Azure Firewall to be created"  
}

variable "automation_account_name" {
  description = "(Required) Tags of the Azure Firewall to be created"  
}

variable "resource_group_name" {
  description = "(Required) Resource Group of the Azure Firewall to be created"  
}

variable "nodeconfig_depends_on" {
  type    = any
  default = null
}

variable "dsc_config" {

}

variable  "dsc_node_name" {

}