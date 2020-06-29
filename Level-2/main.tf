
terraform {
  required_version = ">= 0.12.6"
}

provider "azurerm" {
  version             = "~>2.11.0"
  features {
    
  }
}

terraform {
  backend "azurerm" {
    storage_account_name = "bojstatfstateml"
    container_name       = "tf-state-l2"
    key                  = "l2.terraform.tfstate"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "b4XzzMBYyebj8FX/Jke4RSNUv/T8XxrGdS/UfUAmb6TY8do4e2AqXpOl7qjfWkBNsR/zHRTjaZiFxUCSFuGwhA=="
  }
}


data "terraform_remote_state" "tfstate-l1" {
  backend = "azurerm"
  config = {
    storage_account_name = "bojstatfstateml"
    container_name       = "tf-state-l0"
    key                  = "l1.terraform.tfstate"

    # rather than defining this inline, the Access Key can also be sourced
    # from an Environment Variable - more information is available below.
    access_key = "b4XzzMBYyebj8FX/Jke4RSNUv/T8XxrGdS/UfUAmb6TY8do4e2AqXpOl7qjfWkBNsR/zHRTjaZiFxUCSFuGwhA=="
  }
}


