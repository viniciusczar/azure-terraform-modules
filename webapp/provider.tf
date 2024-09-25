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
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
}

data "azurerm_client_config" "main" {}