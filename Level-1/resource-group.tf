module "resource_groups" {

    source = "../modules/resource-group"

    prefix = var.prefix
    resource_groups = var.resource_groups
    tags = var.tags

}