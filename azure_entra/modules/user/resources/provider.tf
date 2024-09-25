terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.74.0"
    }
  }

  #backend "azurerm" {
  #  resource_group_name  = tf-compute-dev-rg"
  #  storage_account_name = "tf-test-remote-state"
  #  container_name       = "terraform-remote-state"
  #  key                  = "admin/terraform.tfstate"
  #}

}

provider "azurerm" {
  features {}
  tenant_id       = "cea9d5c4-da67-4343-9882-aaa697e5836a"
  subscription_id = "93ebcf81-8118-4fb6-a4a7-de78cc2549e1"
}

provider "azuread" {}

### Data Source ###

data "azuread_domains" "default" {
  only_initial = true
}

data "azuread_client_config" "current" {}

data "azurerm_subscription" "primary" {
}
