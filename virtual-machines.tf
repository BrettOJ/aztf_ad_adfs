
module "vnic-ad-ds" {
    source = "./modules/virtual-nic"

    nic_name                        = var.ad-ds_nic_name
    location                        = var.location
    resource_group_name             = local.ad-ds
    subnet_id                       = local.subnet_id_ad-ds
    private_ip_address_allocation   = local.private_ip_address_allocation
    private_ip_address              = local.ad-ds_ip_address

}

module "vnic-adfs" {
    source = "./modules/virtual-nic"

    nic_name                        = var.adfs_nic_name
    location                        = var.location
    resource_group_name             = local.ad-ds
    subnet_id                       = local.subnet_id_adfs
    private_ip_address_allocation   = local.private_ip_address_allocation
    private_ip_address              = local.adfs_ip_address

}

module "vnic-adfs-proxy" {
    source = "./modules/virtual-nic"

    nic_name                        = var.adfs-proxy_nic_name
    location                        = var.location
    resource_group_name             = local.dmz
    subnet_id                       = local.subnet_id_adfs-proxy
    private_ip_address_allocation   = local.private_ip_address_allocation
    private_ip_address              = local.adfs-proxy_ip_address


}

module "vnic-jh" {
    source = "./modules/virtual-nic"

    nic_name                        = var.jh_nic_name
    location                        = var.location
    resource_group_name             = local.dmz
    subnet_id                       = local.subnet_id_jh
    private_ip_address_allocation   = local.private_ip_address_allocation
    private_ip_address              = local.jump_host_ip


}

module "vnic-aadc" {
    source = "./modules/virtual-nic"

    nic_name                        = var.aadc_nic_name
    location                        = var.location
    resource_group_name             = local.ad-ds
    subnet_id                       = local.subnet_id_ad-ds
    private_ip_address_allocation   = local.private_ip_address_allocation
    private_ip_address              = local.aadc_ip


}


module "vm_ad-ds" {
  source = "./modules/virtual-machine"
  
  prefix                      = var.prefix
  vmname                      = var.vmname_adds
  resource_group_name         = local.ad-ds
  location                    = var.location 
  tags                        = var.tags
  # to be enabled for vnext log analytics/diagnostics extension
  # log_analytics_workspace_id  = module.la_test.id
  # diagnostics_map             = module.diags_test.diagnostics_map
  # diagnostics_settings        = local.diagnostics

  primary_network_interface_id= module.vnic-ad-ds.virtual_nic_id
  os                          = local.os
  os_profile                  = local.os_profile
  storage_image_reference     = local.storage_image_reference
  storage_os_disk             = local.storage_os_disk_ad
  vm_size                     = local.vm_size
}

module "vm_aadc" {
  source = "./modules/virtual-machine"
  
  prefix                      = var.prefix
  vmname                      = var.vmname_aadc
  resource_group_name         = local.ad-ds
  location                    = var.location 
  tags                        = var.tags
  # to be enabled for vnext log analytics/diagnostics extension
  # log_analytics_workspace_id  = module.la_test.id
  # diagnostics_map             = module.diags_test.diagnostics_map
  # diagnostics_settings        = local.diagnostics

  primary_network_interface_id= module.vnic-aadc.virtual_nic_id
  os                          = local.os
  os_profile                  = local.os_profile
  storage_image_reference     = local.storage_image_reference
  storage_os_disk             = local.storage_os_disk_aadc
  vm_size                     = local.vm_size
}


module "vm_adfs" {
  source = "./modules/virtual-machine"
  
  prefix                      = var.prefix
  vmname                      = var.vmname_adfs
  resource_group_name         = local.adfs
  location                    = var.location 
  tags                        = var.tags
  # to be enabled for vnext log analytics/diagnostics extension
  # log_analytics_workspace_id  = module.la_test.id
  # diagnostics_map             = module.diags_test.diagnostics_map
  # diagnostics_settings        = local.diagnostics

  primary_network_interface_id= module.vnic-adfs.virtual_nic_id
  os                          = local.os
  os_profile                  = local.os_profile
  storage_image_reference     = local.storage_image_reference
  storage_os_disk             = local.storage_os_disk_adfs
  vm_size                     = local.vm_size
}

module "vm_adfs-proxy" {
  source = "./modules/virtual-machine"
  
  prefix                      = var.prefix
  vmname                      = var.vmname_adfs-proxy
  resource_group_name         = local.adfs
  location                    = var.location 
  tags                        = var.tags
  # to be enabled for vnext log analytics/diagnostics extension
  # log_analytics_workspace_id  = module.la_test.id
  # diagnostics_map             = module.diags_test.diagnostics_map
  # diagnostics_settings        = local.diagnostics

  primary_network_interface_id= module.vnic-adfs-proxy.virtual_nic_id
  os                          = local.os
  os_profile                  = local.os_profile
  storage_image_reference     = local.storage_image_reference
  storage_os_disk             = local.storage_os_disk_adfs-proxy
  vm_size                     = local.vm_size
}

module "vm_jh" {
  source = "./modules/virtual-machine"
  
  prefix                      = var.prefix
  vmname                      = var.vmname_jh
  resource_group_name         = local.dmz
  location                    = var.location 
  tags                        = var.tags
  # to be enabled for vnext log analytics/diagnostics extension
  # log_analytics_workspace_id  = module.la_test.id
  # diagnostics_map             = module.diags_test.diagnostics_map
  # diagnostics_settings        = local.diagnostics

  primary_network_interface_id= module.vnic-jh.virtual_nic_id
  os                          = local.os
  os_profile                  = local.os_profile
  storage_image_reference     = local.storage_image_reference
  storage_os_disk             = local.storage_os_disk_jh
  vm_size                     = local.vm_size
}

