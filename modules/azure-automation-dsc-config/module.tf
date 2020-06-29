resource "azurerm_automation_dsc_configuration" "dsc_config" {
  
  name                    = var.dsc_config
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  location                = var.location
  content_embedded        = "configuration ${var.dsc_config} {}"
  depends_on              = [var.automation_depends_on]
}