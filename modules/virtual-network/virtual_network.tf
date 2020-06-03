
resource "azurerm_virtual_network" "vnet" {
  name                = var.network_object.vnet.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.network_object.vnet.address_space
  dns_servers         = var.network_object.vnet.dns


}

module "nsg" {
  source                    = "./nsg"

  resource_group_name       = var.resource_group_name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  subnets                   = var.network_object.subnets
  tags                      = var.tags
  location                  = var.location

}


module "subnets" {
  source                = "./subnet"

  resource_group_name   = var.resource_group_name
  virtual_network_name  = azurerm_virtual_network.vnet.name
  subnets               = var.network_object.subnets
  tags                  = var.tags
  location              = var.location
}
