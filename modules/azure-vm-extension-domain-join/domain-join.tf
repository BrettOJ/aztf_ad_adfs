locals {
  # construct the correct domain user principal name
  domain_user_name = var.domain_info == null ? "" : "${var.domain_info.active_directory_username}@${var.domain_info.active_directory_domain}"
}

resource "azurerm_virtual_machine_extension" "join-domain" {
  count = var.domain_info != null ? var.instance_count : 0
  name  = element(module.vm_domain_name.naming_convention_output[var.naming_convention_info.name].names, count.index)
  # location             = var.location
  # resource_group_name  = var.resource_group_name
  virtual_machine_id = azurerm_virtual_machine.vm_obj[count.index].id
  #virtual_machine_name = azurerm_virtual_machine.vm_obj[count.index].name
  publisher            = "Microsoft.Compute"
  type                 = "JsonADDomainExtension"
  type_handler_version = "1.3"
  # NOTE: the `OUPath` field is intentionally blank, to put it in the Computers OU
  protected_settings = <<SETTINGS
    {
      "Password":"${var.domain_info.active_directory_password}"
    }
SETTINGS
  settings           = <<SETTINGS
    {
    "Name":"${var.domain_info.active_directory_domain}",
    "OUPath":"${var.domain_info.oupath}",
    "User":"${local.domain_user_name}",
    "Restart":"true",
    "Options":"3"
    }
SETTINGS
  depends_on         = [azurerm_virtual_machine.vm_obj]
}


# // NOTE: this is a hack.
# // the AD Domain takes ~7m to provision, so we don't try and join an non-existant domain we sleep
# // unfortunately we can't depend on the Domain Creation VM Extension since there's a reboot.
# // We sleep for 12 minutes here to give Azure some breathing room.
# resource "null_resource" "wait-for-domain-to-provision" {
#   depends_on = []
#   provisioner "local-exec" {
#     command = "sleep 720"
#   }
# }
