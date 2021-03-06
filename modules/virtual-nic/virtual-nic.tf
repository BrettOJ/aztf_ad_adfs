resource "azurerm_network_interface" "vnic" {
  name                = var.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name
  #internal_dns_name_label = var. internal_dns_name_label

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address = var.private_ip_address
  }
}