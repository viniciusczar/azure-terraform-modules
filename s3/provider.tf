terraform {
  backend "azurerm" {
    resource_group_name  = "tf-compute-dev-rg"
    storage_account_name = "tflubyterraform"
    container_name       = "tfstates"
    key                  = "storage/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

### Data Source ###

data "azurerm_resource_group" "compute_dev_rg" {
  name = "tf-compute-dev-rg"
}
