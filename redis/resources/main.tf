# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "example" {
  name                = var.azurerm_redis_cache_name
  resource_group_name = data.azurerm_resource_group.compute_dev_rg.name
  location            = data.azurerm_resource_group.compute_dev_rg.location
  capacity            = var.azurerm_redis_cache_capacity
  family              = var.azurerm_redis_cache_family
  sku_name            = var.sku_name
  enable_non_ssl_port = var.enable_non_ssl_port
  minimum_tls_version = var.minimum_tls_version

  redis_configuration {
      enable_authentication = var.enable_authentication
      maxmemory_reserved = var.maxmemory_reserved
      maxfragmentationmemory_reserved = var.maxfragmentationmemory_reserved
      maxmemory_delta = var.maxmemory_delta
      maxmemory_policy = var.maxmemory_policy
      maxclients         = var.maxclients
      aof_backup_enabled = var.aof_backup_enabled
      aof_storage_connection_string_0 = var.aof_storage_connection_string_0
      aof_storage_connection_string_1 = var.aof_storage_connection_string_1
  }

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []
    content {
      type         = can(identity.value["type"]) ? identity.value["type"] : "SystemAssigned"
      identity_ids = can(identity.value["identity_ids"]) ? identity.value["identity_ids"] : null
    }
  }

  dynamic "patch_schedule" {
    for_each = var.patch_schedule != null ? [1] : []
    content {
      day_of_week         = can(patch_schedule.value["day_of_week"]) ? patch_schedule.value["day_of_week"] : "Monday"
      start_hour_utc = can(patch_schedule.value["start_hour_utc"]) ? patch_schedule.value["start_hour_utc"] : 0
      maintenance_window = can(patch_schedule.value["maintenance_window"]) ? patch_schedule.value["maintenance_window"] : "PT5H"
    }
  }

  private_static_ip_address = var.private_static_ip_address
  public_network_access_enabled = var.public_network_access_enabled
  replicas_per_master = var.replicas_per_master
  replicas_per_primary = var.replicas_per_primary
  redis_version = var.redis_version
  tenant_settings = var.tenant_settings
  shard_count = var.shard_count
  subnet_id = var.subnet_id
  tags = var.tags

  zones = var.zones

}