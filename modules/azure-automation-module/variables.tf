variable "name" {

}

variable "automation_account_name" {
  description = "(Required) Tags of the Azure Firewall to be created"  
}

variable "resource_group_name" {
  description = "(Required) Resource Group of the Azure Firewall to be created"  
}

variable "module_link" {
    
}
variable "automation_depends_on" {
  type    = any
  default = null
}

