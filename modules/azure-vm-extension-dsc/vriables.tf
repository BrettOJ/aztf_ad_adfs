variable "automation_account_name" {

}

variable "automation_depends_on" {
  type    = any
  default = null
}

variable "virtual_machine_id" {
  
}

variable "automation_endpoint" {
  default = ""
  description = "Azure Automation azurerm_automation_account endpoint URL"
}

variable "automation_key" {
  default = ""
 description = "Azure Automation azurerm_automation_account access key"
}

variable "name" {

}