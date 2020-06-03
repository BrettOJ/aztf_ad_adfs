
locals {

mof_file = file("${path.cwd}/modules/azure-automation-dsc-node-conf/mof_files/${var.dsc_config}/localhost.mof")

}


resource "azurerm_automation_dsc_nodeconfiguration" "node_config" {
  name                    = "${var.dsc_config}.localhost"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  depends_on              = [var.nodeconfig_depends_on]
  content_embedded        = local.mof_file
}

