output "virtual_network" {
    value = azurerm_virtual_network.vnet
}

output "subnet_ids_map" {
  value = module.subnets.subnet_ids_map
}

output "nsg_obj" {
  value = module.nsg.nsg_obj
}
