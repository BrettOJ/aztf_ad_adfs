locals {

    ad-ds = lookup(module.resource_groups.names, "ad-ds", null)
    adfs = lookup(module.resource_groups.names, "adfs", null)
    dmz = lookup(module.resource_groups.names, "dmz", null)
    win10 = lookup(module.resource_groups.names, "win10", null)

    os = "Windows"
    os_profile = {
        computer_name  = "bojtestvm"
        admin_username = "bojadmin"
        admin_password = "Password@1234"
        provision_vm_agent = true
        license_type = "Windows_Server"
        timezone = "Singapore Standard Time"
    #Support for BYOL (HUB) - values can be "Windows_Server" or "Windows_Client"
    }
    storage_image_reference = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2019-Datacenter"
        version   = "latest"
    }
    storage_os_disk_ad = {
        name              = "adosdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "128"
    }
        storage_os_disk_adfs = {
        name              = "adfsosdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "128"
    }

       storage_os_disk_jh = {
        name              = "jhosdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "128"
    }
        storage_os_disk_adfs-proxy = {
        name              = "adfs-proxysosdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "128"
    }
        storage_os_disk_aadc = {
        name              = "aadcsosdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "128"
    }
           storage_os_disk_ad-ca = {
        name              = "adcacsosdisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
        disk_size_gb      = "128"
    }

    vm_size = "Standard_DS1_v2"

    subnet_id_ad-ds         = lookup(lookup(module.virtual_network_ad_spoke.subnet_ids_map, "Subnet_1", {}), "id", "")
    subnet_id_jh            = lookup(lookup(module.virtual_network_dmz.subnet_ids_map, "Subnet_1", {}), "id", "")
    subnet_id_adfs-proxy    = lookup(lookup(module.virtual_network_dmz.subnet_ids_map, "Subnet_1", {}), "id", "")
    subnet_id_adfs          = lookup(lookup(module.virtual_network_adfs_spoke.subnet_ids_map, "Subnet_1", {}), "id", "")
    subnet_id_azfw          = lookup(lookup(module.virtual_network_dmz.subnet_ids_map, "Subnet_2", {}), "id", "")
    subnet_id_dmz           = lookup(lookup(module.virtual_network_dmz.subnet_ids_map, "Subnet_1", {}), "id", "")

    nsg_id_dmz              = lookup(lookup(module.virtual_network_dmz.nsg_obj, "Subnet_1", {}), "id", "")
    nsg_id_ad-ds            = lookup(lookup(module.virtual_network_ad_spoke.nsg_obj, "Subnet_1", {}), "id", "")
    nsg_id_adfs             = lookup(lookup(module.virtual_network_adfs_spoke.nsg_obj, "Subnet_1", {}), "id", "")
   

    ip_addr = {
       ip_name             = "azfw_pip"
       allocation_method   = "Static"
     
       #properties below are optional 
       sku                 = "Standard"                        
       ip_version          = "IPv4"                         
       dns_prefix          = "brettoj" 
       timeout             = 15                               
       zones               = [1]                               
 }

 azfw_public_ip_id  = module.public_ip_azfw.id
 azure_fw_name = module.azure-firewall.name

rule_priority_100 = "100"
rule_action_allow = "Allow"

private_ip_address_allocation  = "static"

jump_host_ip = "10.101.4.134"
ad-ds_ip_address = "10.110.4.134"
ad-ca_ip_address = "10.110.4.138"
aadc_ip = "10.110.4.136"
adfs_ip_address = "10.120.4.138"
adfs-proxy_ip_address = "10.101.4.136"


destination_addresses = module.public_ip_azfw.ip_address

automation_account_id = module.azure_automation_account.id


nat_rule =  {
    name = "allow_rdp_from_brett"
    
    source_addresses = [
      "118.189.40.39", 
    ]
    #"220.255.65.76",
    
    destination_ports = [
      "3389",
    ]
    
    translated_address = "10.101.4.134"
    
    translated_port = "3389"

    destination_addresses  = [
        "${module.public_ip_azfw.ip_address}"
    ]
        
    #azurerm_public_ip.public_ip.ip_address
    protocols = [
      "TCP",
      "UDP",
    ]
  }
  module_link_psdesiredstate = {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xpsdesiredstateconfiguration.9.1.0.nupkg"
  }
   module_link_xactivedirectory =   {
    uri = "https://psg-prod-eastus.azureedge.net/packages/xactivedirectory.3.0.0.nupkg"
  }
     module_link_networkingdsc = {
    uri = "https://psg-prod-eastus.azureedge.net/packages/networkingdsc.8.0.0-preview0004.nupkg"
  }

node_config_name  = "iis.localhost"
automation_key = module.azure_automation_account.automation_object.dsc_primary_access_key
automation_endpoint = module.azure_automation_account.automation_object.dsc_server_endpoint

virtual_machine_id_adds = module.vm_ad-ds.id
virtual_machine_id_adfs = module.vm_adfs.id

aa_variable_name  = "adfsmachinename"
adfs_machine_name = "srv-adfs01"

dsc_config_adfs   = "ADFSInit"
dsc_config_adds   = "DomainInit"

}