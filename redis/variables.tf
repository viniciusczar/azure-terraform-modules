variable "tenant_id" {
  description = "Tenant ID"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
  default     = null
}

variable "azurerm_redis_cache_name" {
  description = "(Required) The name of the Redis instance. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = null
}

variable "sku_name" {
  description = "sku name"
  type        = string
  default     = "Standard"
}

variable "minimum_tls_version" {
  description = "(Optional) The configures the minimum version of TLS required for SSL requests. Possible values include: 1.0, 1.1, and 1.2. Defaults to 1.2."
  type        = string
  default     = null
}

variable "enable_non_ssl_port" {
  description = "(Optional) Enable the non-SSL port (6379) - disabled by default."
  type        = bool
  default     = false
}

variable "azurerm_redis_cache_capacity" {
  description = "(Required) The size of the Redis cache to deploy. Valid values for a SKU family of C (Basic/Standard) are 0, 1, 2, 3, 4, 5, 6, and for P (Premium) family are 1, 2, 3, 4, 5."
  type        = string
  default     = 1
}

variable "azurerm_redis_cache_family" {
  description = "(Required) The SKU family/pricing group to use. Valid values are C (for Basic/Standard SKU family) and P (for Premium)"
  type        = string
  default     = "C"
}

variable "enable_authentication" {
  description = "(Optional) If set to false, the Redis instance will be accessible without authentication. Defaults to true."
  type        = bool
  default     = true
}

variable "maxclients" {
  description = "Returns the max number of connected clients at the same time."
  type        = string
  default     = null
}

variable "aof_backup_enabled" {
  description = "(Optional) Enable or disable AOF persistence for this Redis Cache. Defaults to false."
  type        = bool
  default     = false
}

variable "aof_storage_connection_string_0" {
  description = "(Optional) First Storage Account connection string for AOF persistence."
  type        = string
  default     = null
}

variable "aof_storage_connection_string_1" {
  description = "(Optional) Second Storage Account connection string for AOF persistence."
  type        = string
  default     = null
}

variable "maxmemory_reserved" {
  description = "(Optional) Value in megabytes reserved for non-cache usage e.g. failover. Defaults are shown below."
  type        = number
  default     = 50
}

variable "maxfragmentationmemory_reserved" {
  description = "(Optional) Value in megabytes reserved to accommodate for memory fragmentation. Defaults are shown below."
  type        = number
  default     = 50
}

variable "maxmemory_delta" {
  description = "(Optional) The max-memory delta for this Redis instance. Defaults are shown below."
  type        = number
  default     = 50
}

variable "maxmemory_policy" {
  description = "(Optional) How Redis will select what to remove when maxmemory is reached. Defaults to volatile-lru."
  type        = string
  default     = "volatile-lru"
}

variable "identity" {
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
}

variable "patch_schedule" {
  type = object({
    day_of_week        = string
    start_hour_utc     = number
    maintenance_window = string
  })
  default = null
}

variable "private_static_ip_address" {
  description = "(Optional) The Static IP Address to assign to the Redis Cache when hosted inside the Virtual Network. This argument implies the use of subnet_id. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = " (Optional) Whether or not public network access is allowed for this Redis Cache. true means this resource could be accessed by both public and private endpoint. false means only private endpoint access is allowed."
  type        = bool
  default     = true
}

variable "replicas_per_master" {
  description = "(Optional) Amount of replicas to create per master for this Redis Cache."
  type        = number
  default     = null
}

variable "replicas_per_primary" {
  description = "(Optional) Amount of replicas to create per primary for this Redis Cache. If both replicas_per_primary and replicas_per_master are set, they need to be equal."
  type        = number
  default     = null
}

variable "redis_version" {
  description = "(Optional) Redis version. Only major version needed. Valid values: 4, 6."
  type        = number
  default     = 6
}

variable "tenant_settings" {
  description = "(Optional) A mapping of tenant settings to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "shard_count" {
  description = "(Optional) Only available when using the Premium SKU The number of Shards to create on the Redis Cluster."
  type        = number
  default     = null
}

variable "subnet_id" {
  description = "(Optional) Only available when using the Premium SKU The ID of the Subnet within which the Redis Cache should be deployed. This Subnet must only contain Azure Cache for Redis instances without any other type of resources. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "zones" {
  description = "(Optional) Specifies a list of Availability Zones in which this Redis Cache should be located. Changing this forces a new Redis Cache to be created."
  type        = list(string)
  default     = []
}