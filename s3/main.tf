module "storage_account_test" {
  source = "web-virtua-azure-multi-account-modules/storage/azurerm"

  name     = "tflubyterraform"
  resource_group_name = data.azurerm_resource_group.compute_dev_rg.name

  blob_properties = {
    versioning_enabled = true
  }

  queue_properties = {
    logging = {
      retention_policy_days = 7
    }
  }

  storage_containers = [
    {
      name                  = "tfstates"
      container_access_type = "private"
    }
  ]
}
