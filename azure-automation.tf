module "azure_automation_account" {
    source = "./modules/azure-automation-account"

    name                        = var.automation_account_name
    resource_group_name         = local.ad-ds
    location                    = var.location 
    tags                        = var.tags


}
