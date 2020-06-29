#output for VM's
output "vm_adds_object" {
    value = module.vm_ad-ds.object
}
/*
output "vm_aadc_object" {
    value = module.vm_aadc.object
}*/

output "vm_ad-ca_object" {
    value = module.vm_ad-ca.object
}

output "vm_ad-ca-sub_object" {
    value = module.vm_ad-ca-sub.object
}

output "vm_adfs_object" {
    value = module.vm_adfs.object
}
/*
output "vm_adfs-proxy_object" {
    value = module.vm_adfs-proxy.object
}

output "vm_win10_object" {
    value = module.vm_win10.object
}
*/
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

#output for VM's
output "vm_adds_id" {
    value = module.vm_ad-ds.id
}
/*
output "vm_aadc_id" {
    value = module.vm_aadc.id
}*/

output "vm_ad-ca_id" {
    value = module.vm_ad-ca.id
}

output "vm_ad-ca-sub_id" {
    value = module.vm_ad-ca-sub.id
}

output "vm_adfs_id" {
    value = module.vm_adfs.id
}
/*
output "vm_adfs-proxy_id" {
    value = module.vm_adfs-proxy.id
}

output "vm_win10_id" {
    value = module.vm_win10.id
}
*/
