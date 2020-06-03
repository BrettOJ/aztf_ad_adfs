
resource "azurerm_automation_module" "aa_module" {

  name                    = var.name
  resource_group_name     = var.resource_group_name 
  automation_account_name = var.automation_account_name
  depends_on              = [var.automation_depends_on]

  module_link {
    uri = var.module_link.uri
  }
}

