resource "azurerm_firewall_network_rule_collection" "example" {
  name                = var.name
  azure_firewall_name = var.azure_firewall_name
  resource_group_name = var.resource_group_name
  priority            = var.priority
  action              = var.action
  #depends_on          = [module.azure-firewall]
 

  rule {
    name = var.rule.name 

    source_addresses = var.rule.source_addresses

    destination_ports = var.rule.destination_ports

    destination_addresses = var.rule.destination_addresses

    protocols = var.rule.protocols
  }
}