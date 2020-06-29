resource "azurerm_automation_variable_string" "automation_variable_string" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  automation_account_name = var.automation_account_name
  value                   = var.value
  depends_on              = [var.automation_depends_on]
}
