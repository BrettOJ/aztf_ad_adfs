
#__******************************************
#onboard the VMs into DSC 

module "azure_vm_extension_dsc_adds" {
    source = "../modules/azure-vm-extension-dsc"

    automation_account_name       = data.terraform_remote_state.tfstate-l1.outputs.automation_object.name
    virtual_machine_id            = local.virtual_machine_id_adds
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_adds
    dsc_node_name                 = local.dsc_node_name_adds


}

module "azure_vm_extension_dsc_adfs" {
    source = "../modules/azure-vm-extension-dsc"

    automation_account_name       = data.terraform_remote_state.tfstate-l1.outputs.automation_object.name
    virtual_machine_id            = local.virtual_machine_id_adfs
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_adfs
    dsc_node_name                 = local.dsc_node_name_adfs
    

}

module "azure_vm_extension_dsc_caroot" {
    source = "../modules/azure-vm-extension-dsc"

    automation_account_name       = data.terraform_remote_state.tfstate-l1.outputs.automation_object.name
    virtual_machine_id            = local.virtual_machine_id_caroot
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_caroot
    dsc_node_name                 = local.dsc_node_name_caroot
  

}

module "azure_vm_extension_dsc_casub" {
    source = "../modules/azure-vm-extension-dsc"

    automation_account_name       = data.terraform_remote_state.tfstate-l1.outputs.automation_object.name
    virtual_machine_id            = local.virtual_machine_id_casub
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_casub
    dsc_node_name                 = local.dsc_node_name_casub


}

/*
module "azure_vm_extension_dsc_aadc" {
    source = "../modules/azure-vm-extension-dsc"

    automation_account_name       = data.terraform_remote_state.tfstate-l1.outputs.automation_object.name
    virtual_machine_id            = local.virtual_machine_id_aadc
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_aadc
    dsc_node_name                 = local.dsc_node_name_aadc


}
*/