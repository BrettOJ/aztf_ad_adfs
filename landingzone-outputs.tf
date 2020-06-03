output  "resource_groups" {

    value = module.resource_groups.object

}
#Outputs from Virtual Networks

output "virtual_network_dmz" {

    value = module.virtual_network_dmz.virtual_network
}

output "virtual_network_ad_spoke" {

     value = module.virtual_network_ad_spoke.virtual_network
}

output "virtual_network_adfs_spoke" {

     value = module.virtual_network_adfs_spoke.virtual_network
}

#Outputs from Virtual Machine

output "ad-ds_network_interface_ids" {

    value = module.vm_ad-ds.network_interface_ids
}

output "ad-ds_primary_network_interface_id" {
    value = module.vm_ad-ds.primary_network_interface_id
}


# TODO - get a keyvault created to insert the ssh key and share the kv secret id instead
output "ad-ds_ssh_private_key_pem" {
    sensitive = true
    value = module.vm_ad-ds.ssh_private_key_pem
}

output "msi_system_principal_id" {
    value = module.vm_ad-ds.msi_system_principal_id
}

output "name" {
    value = module.vm_ad-ds.name
}

output "adds_virtual_nic_id" {

    value =  module.vnic-ad-ds.virtual_nic_id
}

#output for the Azure Firewall

output "azure_firewall" {

    value = module.azure-firewall.object
     
}

output "automation_object" {

    value = module.azure_automation_account.automation_object

}