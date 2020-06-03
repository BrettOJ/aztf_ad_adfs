locals {
  dsc_mode             = "ApplyAndAutoCorrect"

}
  
#NOTE: Node data must already exist - otherwise the extension will fail with 'No NodeConfiguration was found for the agent.'
resource "azurerm_virtual_machine_extension" "dsc_extension" {
  name                          = "Microsoft.Powershell.DSC"
  virtual_machine_id            = var.virtual_machine_id
  publisher                     = "Microsoft.Powershell"
  type                          = "DSC"
  type_handler_version          = "2.77"
  auto_upgrade_minor_version    = true
  depends_on                    = [var.automation_depends_on]
  
  #use default extension properties as mentioned here:
  #https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-template
     #"rootConfig.${var.virtual_machine_id}",
  settings = <<SETTINGS_JSON
        {
            "configurationArguments": {
                "RegistrationUrl" : "${var.automation_endpoint}",
                "NodeConfigurationName" : "${var.name}.localhost",             
                "ConfigurationMode": "${local.dsc_mode}",
                "RefreshFrequencyMins": 30,
                "ConfigurationModeFrequencyMins": 15,
                "RebootNodeIfNeeded": true,
                "ActionAfterReboot": "continueConfiguration",
                "AllowModuleOverwrite": true

            }
        }
  SETTINGS_JSON
  protected_settings = <<PROTECTED_SETTINGS_JSON
    {
        "configurationArguments": {
                "RegistrationKey": {
                    "userName": "NOT_USED",
                    "Password": "${var.automation_key}"
                }
        }
    }
  PROTECTED_SETTINGS_JSON
}
/*
  settings = <<SETTINGS_JSON
        {
            "configurationArguments": {
                "RegistrationUrl" : "${var.automation_endpoint}",
                "NodeConfigurationName" : "${var.NodeConfigurationName}.localhost",             
                "ConfigurationMode": "${local.dsc_mode}",
                "RefreshFrequencyMins": 30,
                "ConfigurationModeFrequencyMins": 15,
                "RebootNodeIfNeeded": true,
                "ActionAfterReboot": "continueConfiguration",
                "AllowModuleOverwrite": true

            }
        }
  SETTINGS_JSON
  protected_settings = <<PROTECTED_SETTINGS_JSON
    {
        "configurationArguments": {
                "RegistrationKey": {
                    "userName": "NOT_USED",
                    "Password": "${var.automation_key}"
                }
        }
    }
  PROTECTED_SETTINGS_JSON

  */