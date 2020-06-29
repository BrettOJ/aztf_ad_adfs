locals  {   
    resource_group_name = lookup(module.resource_groups.names, "sta-tf-state-l0", null)
}

module "resource_groups" {
    source = "../modules/resource-group"

    prefix = var.prefix
    resource_groups = var.resource_groups
    tags = var.tags

}

module "storage_account_tfstate-l0" {
  source              = "../modules/azure-storage-account"

  name                = var.sta_name
  resource_group_name = local.resource_group_name
  location            = var.location
  kind                = "StorageV2"
  sku                 = "Standard_LRS"
  access_tier         = "Hot"
  container           = var.container
  tags                = var.tags
}
