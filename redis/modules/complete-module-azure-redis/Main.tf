module "complete_module_azure_redis_example" {
  source = "./resources"

  azurerm_redis_cache_name = var.azurerm_redis_cache_name

  tenant_id           = var.tenant_id
  subscription_id     = var.subscription_id
  resource_group_name = var.resource_group_name

  azurerm_redis_cache_capacity = 1
  azurerm_redis_cache_family = "C"

  sku_name = "Premium" # Standard, Basic or Premium
  minimum_tls_version = "1.2"
  enable_non_ssl_port = true

    enable_authentication = true # Se false, deverá settar subnet_id

    maxmemory_reserved              = 50
    maxfragmentationmemory_reserved = 50
    maxmemory_delta                 = 3
    maxmemory_policy                = "volatile-lru"

    aof_backup_enabled              = true
    aof_storage_connection_string_0 = "STRING_URL_CONNECTION"
    aof_storage_connection_string_1 = "STRING_URL_CONNECTION"

  identity = {
    type         = "UserAssigned"
    identity_ids = ["examplexxxxxxxxxx"]
  }

  patch_schedule = {
    day_of_week = "Friday"
    start_hour_utc = 12
    maintenance_window = "PT5H"
  }

  private_static_ip_address = "10.0.108.96/24" # Você precisa ter uma Network criada anteriormente para atachá-lo e subnet_id deste módulo definido
  public_network_access_enabled = true
  replicas_per_master = 2 # Você precisa definir sku_name como Premium para utilizar essa opção
  replicas_per_primary = 2 # Você precisa definir sku_name como Premium para utilizar essa opção
  redis_version = 6
  shard_count = 1 # Você precisa definir sku_name como Premium para utilizar essa opção
  subnet_id = "STRING_SUBNET_ID_AQUI"

  tenant_settings = {
    OPTION_ENVIRONMENT       = "Example"
  }

  tags = {
    environment = "development"
  }

}
