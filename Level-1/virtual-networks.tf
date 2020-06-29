


module "virtual_network_dmz" {
    source = "../modules/virtual-network"

    location = var.location
    resource_group_name = local.ad-ds
    network_object = var.network_object
    tags = var.tags
}

module "virtual_network_ad_spoke" {
    source = "../modules/virtual-network"

    location = var.location
    resource_group_name = local.ad-ds
    network_object = var.network_object2
    tags = var.tags
}


module "virtual_network_adfs_spoke" {
    source = "../modules/virtual-network"

    location = var.location
    resource_group_name = local.ad-ds
    network_object = var.network_object3
    tags = var.tags
}

module "virtual_network_win10_spoke" {
    source = "../modules/virtual-network"

    location = var.location
    resource_group_name = local.ad-ds
    network_object = var.network_object4
    tags = var.tags
}


## Add vNet Peering
module "vnet_peer_adfs_adds" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_adfs_adds"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_adfs_spoke.virtual_network.name
  remote_virtual_network_id = module.virtual_network_ad_spoke.virtual_network.id

}

module "vnet_peer_adds_adfs" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_adds_adfs" 
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_ad_spoke.virtual_network.name
  remote_virtual_network_id = module.virtual_network_adfs_spoke.virtual_network.id

}


module "vnet_peer_jh_adfs" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_jh_adfs"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_dmz.virtual_network.name
  remote_virtual_network_id = module.virtual_network_adfs_spoke.virtual_network.id

}

module "vnet_peer_adfs_jh" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_adfs_jh"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_adfs_spoke.virtual_network.name
  remote_virtual_network_id = module.virtual_network_dmz.virtual_network.id

}

module "vnet_peer_jh_adds" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_jh_adds"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_dmz.virtual_network.name
  remote_virtual_network_id = module.virtual_network_ad_spoke.virtual_network.id

}

module "vnet_peer_adds_jh" {

  source = "../modules/virtual-network-peering"

  name                      = "vnet_peer_adds_jh"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_ad_spoke.virtual_network.name
  remote_virtual_network_id = module.virtual_network_dmz.virtual_network.id

} 

module "vnet_peer_jh_win10" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_jh_win10"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_dmz.virtual_network.name
  remote_virtual_network_id = module.virtual_network_win10_spoke.virtual_network.id

}

module "vnet_peer_win10_jh" {

  source = "../modules/virtual-network-peering"
  
  name                      = "vnet_peer_win10_jh"
  resource_group_name       = local.ad-ds
  virtual_network_name      = module.virtual_network_win10_spoke.virtual_network.name
  remote_virtual_network_id = module.virtual_network_dmz.virtual_network.id

} 

module "nsg_assc_dmz" {

  source =  "../modules/network-nsg-association"

  subnet_id                 = local.subnet_id_dmz
  network_security_group_id = local.nsg_id_dmz
}

module "nsg_assc_ad-ds" {

  source =  "../modules/network-nsg-association"

  subnet_id                 = local.subnet_id_ad-ds
  network_security_group_id = local.nsg_id_ad-ds
}

module "nsg_assc_adfs" {

  source =  "../modules/network-nsg-association"

  subnet_id                 = local.subnet_id_adfs
  network_security_group_id = local.nsg_id_adfs
}

module "nsg_assc_win10" {

  source =  "../modules/network-nsg-association"

  subnet_id                 = local.subnet_id_win10
  network_security_group_id = local.nsg_id_win10
}