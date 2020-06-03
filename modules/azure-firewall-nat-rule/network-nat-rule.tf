resource "azurerm_firewall_nat_rule_collection" "nat_rule" {
  name                = var.name
  azure_firewall_name = var.azure_firewall_name
  resource_group_name = var.resource_group_name
  priority            = var.priority
  action              = "Dnat"
  


  rule {
    name = var.rule.name 

    source_addresses = var.rule.source_addresses

    destination_ports = var.rule.destination_ports

    destination_addresses = var.rule.destination_addresses

    translated_port = var.rule.translated_port

    translated_address =  var.rule.translated_address

    protocols = var.rule.protocols
  }
}