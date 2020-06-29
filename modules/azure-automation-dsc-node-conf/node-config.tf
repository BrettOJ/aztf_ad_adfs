
locals {

mof_file = file("${path.cwd}/mof_files/${var.dsc_config}/${var.dsc_node_name}.mof")

}


resource "azurerm_automation_dsc_nodeconfiguration" "node_config" {
  name                    = "${var.dsc_config}.${var.dsc_node_name}"
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  depends_on              = [var.nodeconfig_depends_on]
  content_embedded        = local.mof_file
}

