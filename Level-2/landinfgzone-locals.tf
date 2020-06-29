locals {

    ad-ds = lookup(lookup(data.terraform_remote_state.tfstate-l1.outputs.resource_groups, "ad-ds", null), "name", null)
   


#Automation DSC configuration and node onboarding
automation_key = data.terraform_remote_state.tfstate-l1.outputs.automation_object.dsc_primary_access_key
automation_endpoint = data.terraform_remote_state.tfstate-l1.outputs.automation_object.dsc_server_endpoint

virtual_machine_id_adds = data.terraform_remote_state.tfstate-l1.outputs.vm_adds_object.id
virtual_machine_id_adfs = data.terraform_remote_state.tfstate-l1.outputs.vm_adfs_object.id
virtual_machine_id_caroot = data.terraform_remote_state.tfstate-l1.outputs.vm_ad-ca_object.id
virtual_machine_id_casub = data.terraform_remote_state.tfstate-l1.outputs.vm_ad-ca-sub_object.id
#virtual_machine_id_aadc = data.terraform_remote_state.tfstate-l1.outputs.vm_aadc_object.id
#virtual_machine_id_adfs_proxy = data.terraform_remote_state.tfstate-l1.outputs.vm_adfs-proxy_object.id
#virtual_machine_id_win10 = data.terraform_remote_state.tfstate-l1.outputs.vm_win10_object.id

dsc_config_adfs   = "ADFSInit"
dsc_config_adds   = "DomainInit"
dsc_config_caroot = "CARootInit"
dsc_config_casub  = "CASubInit"
dsc_config_aadc   = "AADCInit"

dsc_node_name_adds  = "vm-adds"
dsc_node_name_adfs  = "vm-adfs"
dsc_node_name_caroot  = "vm-adca-root" 
dsc_node_name_casub = "vm-adca-sub"
dsc_node_name_aadc = "vm-aadc"

adfs_machine_name = "vm-adfs"
aa_variable_name =  "adfs_machine_name"
}