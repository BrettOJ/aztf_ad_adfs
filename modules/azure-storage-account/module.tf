locals {
  account_tier             = (var.kind == "FileStorage" ? "Premium" : split("_", var.sku)[0])
  account_replication_type = (local.account_tier == "Premium" ? "LRS" : split("_", var.sku)[1])
}

resource "azurerm_storage_account" "sst_obj" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = local.account_tier 
  account_replication_type = local.account_replication_type
  tags                     = var.tags

}

resource "azurerm_storage_container" "ss_cnt_obj" {

   for_each = var.container

  name     = "${each.value.name}"
  storage_account_name  = azurerm_storage_account.sst_obj.name
  container_access_type = "private"

}
