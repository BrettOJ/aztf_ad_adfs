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
variable "network_object4" {

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

variable "vmname_adca" {

}

variable "vmname_adca-sub" {

}

variable "vmname_win10" {

}

variable "ad-ds_nic_name" {

}
variable "jh_nic_name" {
  
}
variable "adfs_nic_name" {

}
variable "adfs-proxy_nic_name" {
  
}

variable "aadc_nic_name"  {

}

variable "ad-ca_nic_name" {

}

variable "ad-ca-sub_nic_name" {

}

variable "win10_nic_name" {

}

variable "pip_name" {

}
variable "azfw_name" {
  
}

variable "azure_firewall_collection_name" {

}

variable "peer_name" {

}

variable "automation_account_name" {
  
}

variable "az_automation_module_name_xactive_directory" {

}

variable "az_automation_module_name_networkingdsc" {

}

   
variable "az_automation_module_name_xpendingreboot" {

}

variable "az_automation_module_name_xcomputermanagement" {

}

variable "az_automation_module_name_xadcsdeployment" {
  
}
variable "az_automation_module_name_xdnsserver" {
  
}
variable "az_automation_module_name" {

}
variable "az_automation_module_name_compconfig" {

  
}
variable "az_automation_module_name_certificatedsc" {
  
}

variable "credential_name" {

}
variable "credential_username" {

}

variable "credential_password" {

}
variable "credential_desctiption" {

}

