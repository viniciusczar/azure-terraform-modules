module "basic_public_redis_module_example" {
  source = "./resources"

  azurerm_redis_cache_name = var.azurerm_redis_cache_name

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name

  azurerm_redis_cache_capacity = 1
  azurerm_redis_cache_family = "C"

  sku_name = "Standard" # Standard, Basic or Premium
  minimum_tls_version = "1.2"
  enable_non_ssl_port = false


  enable_authentication = true # Se false, deverá settar subnet_id

  public_network_access_enabled = true
  redis_version = 6

  tags = {
    environment = "development"
  }

}
