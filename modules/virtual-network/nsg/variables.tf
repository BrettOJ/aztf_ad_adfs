
variable "resource_group_name" {
  description = "(Required) Map of the resource groups to create"
  type        = string
}
variable "virtual_network_name" {
  description = "name of the parent virtual network"
}

variable "subnets" {
  description = "map structure for the subnets to be created"
}

variable "tags" {
  description = "tags of the resource"
}

variable "location" {
  description = "location of the resource"
}


variable "link_nsg_to_subnet" {
  default = true
}

