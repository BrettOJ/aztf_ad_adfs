module "public_ip_azfw" {
  source = "../modules/public-ip"

  pip_name                         = var.pip_name
  location                         = var.location
  resource_group_name              = local.ad-ds
  ip_addr                          = local.ip_addr
  tags                             = var.tags

}


module "azure-firewall" {
  source = "../modules/azure-firewall"
  
  name                        = var.azfw_name
  resource_group_name         = local.ad-ds
  location                    = var.location 
  tags                        = var.tags
  subnet_id                   = local.subnet_id_azfw
  public_ip_id                = local.azfw_public_ip_id

}

module "firewall_nat_rule_collection" {
  source = "../modules/azure-firewall-nat-rule"

  
  name                  = var.azure_firewall_collection_name
  azure_firewall_name   = local.azure_fw_name
  resource_group_name   = local.ad-ds
  priority              = local.rule_priority_100
  rule                  = local.nat_rule


  
}
