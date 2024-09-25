locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.example.*.name, azurerm_resource_group.example.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.example.*.location, azurerm_resource_group.example.*.location, [""]), 0)
  identity_user_ad_id = element(coalescelist(data.azurerm_user_assigned_identity.main.*.id, azurerm_user_assigned_identity.main.*.id, [""]), 0)
  subnet_name         = element(coalescelist(data.azurerm_subnet.snet.*.id, azurerm_subnet.snet.*.id, [""]), 0)
  private_dns_zone_id = element(coalescelist(data.azurerm_dns_zone.main.*.id, azurerm_private_dns_zone.dnszone1.*.id, [""]), 0)
  private_dns_zone_name = element(coalescelist(data.azurerm_dns_zone.main.*.name, azurerm_private_dns_zone.dnszone1.*.name, [""]), 0)
}

data "azurerm_resource_group" "example" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

data "azurerm_virtual_network" "vnet01" {
  count = var.azurerm_private_dns_zone_name != null ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

data "azurerm_subnet" "snet" {
  count = var.delegated_subnet_name != null ? 1 : 0
  name                 = var.delegated_subnet_name
  virtual_network_name = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

data "azurerm_user_assigned_identity" "main" {
  count = var.create_user_assigned_identity == false && var.user_assigned_identity_name != null ? 1 : 0
  name                = var.user_assigned_identity_name
  resource_group_name = local.resource_group_name
}

data "azurerm_dns_zone" "main" {
  count = var.enable_private_dns_zone_endpoint == true && var.create_private_dns_zone_name == false ? 1 : 0
  name                = var.azurerm_private_dns_zone_name
  resource_group_name = local.resource_group_name
}

/* Criação ou seleção de grupo de recursos - O padrão é "false" */

resource "azurerm_resource_group" "example" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

/* Criação de workspace para armazenamento dos logs analíticos – o padrão é true */

data "azurerm_log_analytics_workspace" "logws" {
  count               = var.log_analytics_workspace_already_exists == true && var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_log_analytics_workspace" "main" {
  count               = var.log_analytics_workspace_already_exists != true && var.log_analytics_workspace_name != null ? 1 : 0
  name                = var.log_analytics_workspace_name
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

/* Conta de armazenamento para manter logs de auditoria - O padrão é "falso" */
resource "random_string" "str" {
  count   = var.enable_logs_to_storage_account != true && var.log_analytics_workspace_name != null ? 1 : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    name = var.storage_account_name
  }
}

resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_logs_to_storage_account == true && var.log_analytics_workspace_name != null ? 1 : 0
  name                      = var.storage_account_name == null ? "stsqlauditlogs${element(concat(random_string.str.*.result, [""]), 0)}" : substr(var.storage_account_name, 0, 24)
  resource_group_name       = local.resource_group_name
  location                  = local.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  min_tls_version           = "TLS1_2"
  tags                      = merge({ "Name" = format("%s", "stsqlauditlogs") }, var.tags, )
}

resource "random_password" "main" {
  count       = var.admin_password == null ? 1 : 0
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.mysqlserver_name
  }
}

/* Adicionando criação e configurações do servidor MySQL - o padrão é "True" */

resource "azurerm_mysql_flexible_server" "main" {
  name                   = var.mysqlserver_name
  resource_group_name               = local.resource_group_name
  location                          = local.location
  administrator_login    = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_password = var.admin_password == null ? random_password.main.0.result : var.admin_password
  backup_retention_days  = var.mysqlserver_settings.backup_retention_days
  create_mode                       = var.mysqlserver_settings.create_mode
  delegated_subnet_id    = var.delegated_subnet_name != null ? local.subnet_name : null
  private_dns_zone_id    = var.enable_private_dns_zone_endpoint == true ? local.private_dns_zone_id : null
  geo_redundant_backup_enabled      = var.mysqlserver_settings.geo_redundant_backup_enabled
  sku_name               = var.mysqlserver_settings.sku_name
  point_in_time_restore_time_in_utc = var.mysqlserver_settings.point_in_time_restore_time_in_utc
  replication_role = var.mysqlserver_settings.replication_role
  source_server_id = var.mysqlserver_settings.source_server_id
  version                           = var.mysqlserver_settings.version
  zone = var.mysqlserver_settings.zone
  tags                              = merge({ "Name" = format("%s", var.mysqlserver_name) }, var.tags, )

  dynamic "storage" {
    for_each = var.storage != null ? [1] : []
    content {
      auto_grow_enabled = var.storage.auto_grow_enabled
      io_scaling_enabled = var.storage.io_scaling_enabled
      iops = var.storage.iops
      size_gb = var.storage.size_gb
    }
  }

  dynamic "high_availability" {
    for_each = var.high_availability != null ? [1] : []
    content {
      mode = var.high_availability.mode
      standby_availability_zone = var.high_availability.standby_availability_zone
    }
  }

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

 /* Gerencia uma chave gerenciada pelo cliente para um servidor MySQL. - O padrão é "null" */

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [1] : []
    content {
      key_vault_key_id = var.customer_managed_key.key_vault_key_id
      primary_user_assigned_identity_id = var.customer_managed_key.primary_user_assigned_identity_id
      geo_backup_key_vault_key_id = var.customer_managed_key.geo_backup_key_vault_key_id
      geo_backup_user_assigned_identity_id = var.customer_managed_key.geo_backup_user_assigned_identity_id
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [1] : []
    content {
      day_of_week         = can(maintenance_window.value["day_of_week"]) ? maintenance_window.value["day_of_week"] : "Monday"
      start_hour = can(maintenance_window.value["start_hour"]) ? maintenance_window.value["start_hour"] : 0
      start_minute = can(start_minute.value["start_minute"]) ? start_minute.value["start_minute"] : 0
    }
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.vent-link1]
}

/* Adicionando banco de dados do servidor MySQL - o padrão é "true" */

resource "azurerm_mysql_flexible_database" "main" {
  name                = var.mysqlserver_settings.database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = var.mysqlserver_settings.charset == null ? "utf8" : var.mysqlserver_settings.charset
  collation           = var.mysqlserver_settings.collation == null ? "utf8_general_ci" : var.mysqlserver_settings.collation
}

/* Adicionando parâmetros do servidor MySQL - o padrão é "false" */

resource "azurerm_mysql_flexible_server_configuration" "main" {
  for_each            = var.mysql_configuration != null ? { for k, v in var.mysql_configuration : k => v if v != null } : {}
  name                = each.key
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = each.value
}

/* Adicionando regras de Firewall para MySQL Server - O padrão é "false" */

resource "azurerm_mysql_flexible_server_firewall_rule" "main" {
  for_each            = var.firewall_rules != null ? { for k, v in var.firewall_rules : k => v if v != null } : {}
  name                = format("%s", each.key)
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = each.value["start_ip_address"]
  end_ip_address      = each.value["end_ip_address"]

  depends_on = [ azurerm_postgresql_flexible_server.main ]
}

/* Criando & Adicionando AD Admin ao servidor MySQL - o padrão é "false" */

resource "azurerm_user_assigned_identity" "main" {
  count = var.create_user_assigned_identity ? 1 : 0
  name                = var.user_assigned_identity_name
  resource_group_name = local.resource_group_name
  location            = local.location
}

resource "azurerm_mysql_flexible_server_active_directory_administrator" "main" {
  count               = var.ad_admin_login_name != null ? 1 : 0
  server_id           = azurerm_mysql_flexible_server.main.id
  identity_id         = local.identity_user_ad_id
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

/* Criação de subnet que serão utilizadas por `delegated_subnet_id` */

resource "azurerm_subnet" "snet" {
  count                                          = var.enable_private_dns_zone_endpoint == true && var.subnet_address_prefix != null ? 1 : 0
  name                                           = "tf-network-full-vnet-private-subnet-by-${var.mysqlserver_name}"
  resource_group_name                            = local.resource_group_name
  virtual_network_name                           = data.azurerm_virtual_network.vnet01[0].name
  address_prefixes                               = var.subnet_address_prefix
  service_endpoints    = ["Microsoft.AzureActiveDirectory", "Microsoft.AzureCosmosDB", "Microsoft.ContainerRegistry", "Microsoft.EventHub", "Microsoft.KeyVault", "Microsoft.ServiceBus", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.Storage.Global", "Microsoft.Web"]

  delegation {
    name = "all"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

/* Link privado para MySQL Server – O padrão é “falso” */

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.enable_private_dns_zone_endpoint == true && var.create_private_dns_zone_name == true ? 1 : 0
  name                = var.azurerm_private_dns_zone_name
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "MySQL-Private-DNS-Zone") }, var.tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.enable_private_dns_zone_endpoint == true && var.create_private_dns_zone_name == true ? 1 : 0
  name                  = "tf-mysql-vnet-private-zone-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = local.private_dns_zone_name
  virtual_network_id    = data.azurerm_virtual_network.vnet01[0].id
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.tags, )

}

/* Diagnóstico de monitoramento do azurerm – o padrão é “falso” */

resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  count                      = var.log_analytics_workspace_name != null ? 1 : 0
  name                       = lower("extaudit-${var.mysqlserver_name}-diag")
  target_resource_id         = azurerm_mysql_flexible_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_already_exists == true ? data.azurerm_log_analytics_workspace.logws.0.id : azurerm_log_analytics_workspace.main.0.id
  storage_account_id         = var.enable_logs_to_storage_account == true ? element(concat(azurerm_storage_account.storeacc.*.id, [""]), 0) : null

  dynamic "enabled_log" {
    for_each = var.extaudit_diag_logs
    content {
      category = enabled_log.value
    }
  }

  metric {
    category = "AllMetrics"

  }

  lifecycle {
    ignore_changes = [enabled_log, metric]
  }

  depends_on = [ azurerm_log_analytics_workspace.main ]
}