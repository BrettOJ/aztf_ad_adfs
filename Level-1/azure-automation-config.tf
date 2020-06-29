#__******************************************
# Add DSC configurations required for node configuration

module "azure_automation_dsc_configuration_adds" {
    source = "../modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    location                    = var.location
    dsc_config                  = local.dsc_config_adds
    automation_depends_on       = [module.azure_automation_account]
}

module "azure_automation_dsc_configuration_adfs" {
    source = "../modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    location                    = var.location
    dsc_config                  = local.dsc_config_adfs
    automation_depends_on       = [module.azure_automation_account]
}

module "azure_automation_dsc_configuration_caroot" {
    source = "../modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    location                    = var.location
    dsc_config                  = local.dsc_config_caroot
    automation_depends_on       = [module.azure_automation_account]
}

module "azure_automation_dsc_configuration_casub" {
    source = "../modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    location                    = var.location
    dsc_config                  = local.dsc_config_casub
    automation_depends_on       = [module.azure_automation_account]
}

module "azure_automation_dsc_configuration_aadc" {
    source = "../modules/azure-automation-dsc-config"

    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    location                    = var.location
    dsc_config                  = local.dsc_config_aadc
    automation_depends_on       = [module.azure_automation_account]
    
}

#__******************************************
# Add DSC Modules required for node configuration

module "azure-automation-module_psdesiredstate" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_psdesiredstate
    automation_depends_on       = [module.azure_automation_account]

}

module "azure-automation-module_xactive_directory" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_xactive_directory
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_xactivedirectory
    automation_depends_on       = [module.azure_automation_account] 
}

module "azure-automation-module_networkingdsc" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_networkingdsc
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_networkingdsc
    automation_depends_on       = [module.azure_automation_account]
}

module "azure-automation-module_xcomputermanagement" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_xcomputermanagement
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_xcomputermanagement
    automation_depends_on       = [module.azure_automation_account]
}

module "azure-automation-module_xpendingreboot" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_xpendingreboot
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_xpendingreboot
    automation_depends_on       = [module.azure_automation_account]
}

module "azure-automation-module_xadcsdeployment" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_xadcsdeployment
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_xadcsdeployment
    automation_depends_on       = [module.azure_automation_account]
}

module "azure-automation-module_xdnsserver" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_xdnsserver
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_xdnsserver
    automation_depends_on       = [module.azure_automation_account]
}

module "azure-automation-module_certificatedsc" {
    source = "../modules/azure-automation-module"
    
    name                        = var.az_automation_module_name_certificatedsc
    resource_group_name         = local.ad-ds
    automation_account_name     = var.automation_account_name 
    module_link                 = local.module_link_certificatedsc
    automation_depends_on       = [module.azure_automation_account]
}


#__******************************************
#Add Azure Automation Variables 

module "azurerm_automation_variable_string_adfsmachinename" {
    source = "../modules/azure-automation-variable-string"

  name                    = local.aa_variable_name
  resource_group_name     = local.ad-ds
  automation_account_name = var.automation_account_name 
  value                   = local.adfs_machine_name
  automation_depends_on       = [module.azure_automation_account]

}

#__******************************************
#Add Azure Automation Credentials
module "azure_automation_credential" {
    source = "../modules/azure-automation-credential"

  name                    = var.credential_name
  resource_group_name     = local.ad-ds
  automation_account_name = var.automation_account_name 
  username                = var.credential_username
  password                = var.credential_password
  description             = var.credential_desctiption
  automation_depends_on       = [module.azure_automation_account]
}

#__******************************************
# Azure Automantion Node Configurations for each server Node
module "azure_automation_node_config_adds" {
    source = "../modules/azure-automation-dsc-node-conf"

    automation_account_name     = var.automation_account_name 
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_adds
    dsc_node_name               = local.dsc_node_name_adds
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_adds]
} 
module "azure_automation_node_config_adfs" {
    source = "../modules/azure-automation-dsc-node-conf"
    
    automation_account_name     = var.automation_account_name 
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_adfs
    dsc_node_name               = local.dsc_node_name_adfs
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_adfs]
} 

module "azure_automation_node_config_caroot" {
    source = "../modules/azure-automation-dsc-node-conf"
    
    automation_account_name     = var.automation_account_name 
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_caroot
    dsc_node_name               = local.dsc_node_name_caroot
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_caroot]
} 

module "azure_automation_node_config_casub" {
    source = "../modules/azure-automation-dsc-node-conf"
    
    automation_account_name     = var.automation_account_name 
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_casub
    dsc_node_name               = local.dsc_node_name_casub
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_casub]
} 


module "azure_automation_node_config_aadc" {
    source = "../modules/azure-automation-dsc-node-conf"
    
    automation_account_name     = var.automation_account_name 
    resource_group_name         = local.ad-ds
    location                    = var.location
    dsc_config                  = local.dsc_config_aadc
    dsc_node_name               = local.dsc_node_name_aadc
    nodeconfig_depends_on       = [module.azure_automation_dsc_configuration_aadc]
} 
