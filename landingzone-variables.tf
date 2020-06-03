variable "resource_groups" {
  description = "(Required) Map of the resource groups to create"
}

# Example of resource_groups data structure:
# resource_groups = {
#   apim          = { 
#                   name     = "-apim-demo"
#                   location = "southeastasia" 
#                   },
#   networking    = {    
#                   name     = "-networking-demo"
#                   location = "southeastasia" 
#                   },
#   insights      = { 
#                   name     = "-insights-demo"
#                   location = "southeastasia" 
#                   },
# }

variable "prefix" {
  description = "(Optional) You can use a prefix to add to the list of resource groups you want to create"
}

variable "tags" {
  description = "(Required) tags for the deployment"
}

# Example Tags Variable
#tags = {
  #  environment     = "TEST"
  #  owner           = "BrettOJ"
  #  TECH            = "ADFS-AD"
#}

variable "network_object" {

}

variable "network_object2" {

}

variable "network_object3" {

}
variable "location" {

}

variable "vmname_adds" {
  
}

variable "vmname_adfs" {
  
}

variable "vmname_jh" {
  
}

variable "vmname_adfs-proxy" {

}

variable "vmname_aadc" {
  
}

variable "ad-ds_nic_name" {

}
variable "jh_nic_name" {
  
}
variable "adfs_nic_name" {

}
variable "adfs-proxy_nic_name" {
  
}

variable "pip_name" {

}
variable "azfw_name" {
  
}

variable "azure_firewall_collection_name" {

}


variable "aadc_nic_name"  {

}

variable "peer_name" {

}

variable "automation_account_name" {
  
}

variable "az_automation_module_name" {

}
variable "az_automation_module_name_compconfig" {

  
}
variable "credential_name" {

}
variable "credential_username" {

}

variable "credential_password" {

}
variable "credential_desctiption" {

}

variable "az_automation_module_name_xactive_directory" {

}

variable "az_automation_module_name_networkingdsc" {

}


