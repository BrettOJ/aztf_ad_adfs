output "id" {
  description = "Output the object ID"
  value                 = azurerm_automation_account.automation_account.id
}

output "name" {
  description = "Output the object name"
  value                 =  azurerm_automation_account.automation_account.name
}

output "automation_object" {
  description = "Output the full object"
  value                 =  azurerm_automation_account.automation_account
}