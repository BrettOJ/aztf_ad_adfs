# Creates one or multiple resource groups
Sets one or more resource groups, each of them in a specific Azure region.

Reference the module to a specific version (recommended):
```hcl
module "resource_groups" {
    source  = "/modules/resource-group"
    
    prefix                  = var.prefix
    resource_groups         = var.resource_groups
    tags                    = var.tags
}
```

# Parameters

## resource_groups
(Required) Object that describes the resource groups to be created with their geo. 
Global group of tags will be added to all RG, specific tags can be added per RG.

```hcl
variable "resource_groups" {
  description = "(Required) Map of the resource groups to create"
}
```

Example of structure: 
```hcl
resource_groups = {
    ad-ds          = { 
                    name     = "-ad-ds"
                    location = "southeastasia" 
    },
    adfs    = {    
                    name     = "-adfs"
                    location = "southeastasia" 
    },
    dmz      = { 
                    name     = "-dmz"
                    location = "southeastasia" 
    },
}
```

## prefix
(Optional) You can use a prefix to add to the list of resource groups you want to create
```hcl
variable "prefix" {
    description = "(Optional) You can use a prefix to add to the list of resource groups you want to create"
}
```
Example
```hcl
locals {
    prefix = "${random_string.prefix.result}-"
}

resource "random_string" "prefix" {
    length  = 4
    upper   = false
    special = false
}
```

# Outputs
| Name | Type | Description | 
| -- | -- | -- | 
| object | object | Returns the full set of created resource groups as an object. |
| names | map | Kept for backward compatibility, might be removed in a future version. Returns a map of: <br> key   = key name (internal name) of the resource group <br> value = name of the resource group |
| ids | map | Kept for backward compatibility, might be removed in a future version. Returns a map of: <br> key   = key name (internal name) of the resource group <br> value = id of the resource group