#__******************************************
# Add DSC configurations required for node configuration

module "azure_automation_dsc_configuration_adds" {
    source = "./modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name
    location                    = var.location
    dsc_config                  = local.dsc_config_adds
    automation_depends_on       = [module.azure_automation_account]
}

module "azure_automation_dsc_configuration_adfs" {
    source = "./modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name
    location                    = var.location
    dsc_config                  = local.dsc_config_adfs
    automation_depends_on       = [module.azure_automation_account]
}


#__******************************************
# Add DSC Modules required for node configuration

module "azure-automation-module_psdesiredstate" {
    source = "./modules/azure-automation-module"
    
    name                        = var.az_automation_module_name
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name
    module_link                 = local.module_link_psdesiredstate
    automation_depends_on       = [module.azure_automation_account]

}

module "azure-automation-module_xactive_directory" {
    source = "./modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_xactive_directory
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name
    module_link                 = local.module_link_xactivedirectory
    automation_depends_on       = [module.azure_automation_account]

}

module "azure-automation-module_networkingdsc" {
    source = "./modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_networkingdsc
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name
    module_link                 = local.module_link_networkingdsc
    automation_depends_on       = [module.azure_automation_account]

}
#__******************************************
#Add Azure Automation Variables 

module "azurerm_automation_variable_string_adfsmachinename" {
    source = "./modules/azure-automation-variable-string"

  name                    = local.aa_variable_name
  resource_group_name     = local.ad-ds
  automation_account_name = var.automation_account_name
  value                   = local.adfs_machine_name
  automation_depends_on   = [module.azure_automation_account]

}

#__******************************************
#Add Azure Automation Credentials
module "azure_automation_credential" {
    source = "./modules/azure-automation-credential"

  name                    = var.credential_name
  resource_group_name     = local.ad-ds
  automation_account_name = var.automation_account_name
  username                = var.credential_username
  password                = var.credential_password
  description             = var.credential_desctiption
  automation_depends_on   = [module.azure_automation_account]
}

#__******************************************
# Azure Automantion Node Configurations for each server Node
module "azure_automation_node_config_adds" {
    source = "./modules/azure-automation-dsc-node-conf"

    automation_account_name     = var.automation_account_name
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_adds
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_adds]
} 
module "azure_automation_node_config_adfs" {
    source = "./modules/azure-automation-dsc-node-conf"
    
    automation_account_name     = var.automation_account_name
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_adfs
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_adfs]
} 

#__******************************************
#onboard the VMs into DSC 

module "azure_vm_extension_dsc_adds" {
    source = "./modules/azure-vm-extension-dsc"

    automation_account_name       = var.automation_account_name
    virtual_machine_id            = local.virtual_machine_id_adds
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_adds
    automation_depends_on         = [module.azure_automation_account]

}

module "azure_vm_extension_dsc_adfs" {
    source = "./modules/azure-vm-extension-dsc"

    automation_account_name       = var.automation_account_name
    virtual_machine_id            = local.virtual_machine_id_adfs
    automation_endpoint           = local.automation_endpoint
    automation_key                = local.automation_key
    name                          = local.dsc_config_adfs
    automation_depends_on         = [module.azure_automation_account]

}
