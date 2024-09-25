locals {
  resource_group_name                = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location                           = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
  if_threat_detection_policy_enabled = var.enable_threat_detection_policy ? [{}] : []
  #if_extended_auditing_policy_enabled = var.enable_extended_auditing_policy ? [{}] : []
}

# Criação ou seleção de grupo de recursos - O padrão é "false"

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group == false ? 1 : 0
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

# Conta de armazenamento para manter logs de auditoria – o padrão é “false”

resource "random_string" "str" {
  count   = var.enable_sql_server_extended_auditing_policy || var.enable_database_extended_auditing_policy || var.enable_vulnerability_assessment ? 1 : 0
  length  = 6
  special = false
  upper   = false
  keepers = {
    name = var.storage_account_name
  }
}

resource "azurerm_storage_account" "storeacc" {
  count                     = var.enable_sql_server_extended_auditing_policy || var.enable_database_extended_auditing_policy || var.enable_vulnerability_assessment || var.enable_log_monitoring == true ? 1 : 0
  name                      = var.storage_account_name == null ? "stsqlauditlogs${element(concat(random_string.str.*.result, [""]), 0)}" : substr(var.storage_account_name, 0, 24)
  resource_group_name       = local.resource_group_name
  location                  = local.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "GRS"
  min_tls_version           = "TLS1_2"
  tags                      = merge({ "Name" = format("%s", "stsqlauditlogs") }, var.tags, )
}

resource "azurerm_storage_container" "storcont" {
  count                 = var.enable_vulnerability_assessment ? 1 : 0
  name                  = "vulnerability-assessment"
  storage_account_name  = azurerm_storage_account.storeacc[0].name
  container_access_type = "private"
}

# SQL Server – O servidor secundário é depende_on do grupo de failover

resource "random_password" "main" {
  length      = var.random_password_length
  min_upper   = 4
  min_lower   = 2
  min_numeric = 4
  special     = false

  keepers = {
    administrator_login_password = var.sqlserver_name
  }
}

resource "azurerm_sql_server" "primary" {
  name                         = format("%s-primary", var.sqlserver_name)
  resource_group_name          = local.resource_group_name
  location                     = local.location
  version                      = var.mssql_version
  administrator_login          = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_login_password = var.admin_password == null ? random_password.main.result : var.admin_password
  tags                         = merge({ "Name" = format("%s-primary", var.sqlserver_name) }, var.tags, )

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []
    content {
      type         = var.identity.type
    }
  }

  dynamic "threat_detection_policy" {
    for_each = local.if_threat_detection_policy_enabled
    content {
      state                      = "Enabled"
      storage_endpoint           = azurerm_storage_account.storeacc[0].primary_blob_endpoint
      storage_account_access_key = azurerm_storage_account.storeacc[0].primary_access_key
      retention_days             = var.log_retention_days
      email_addresses            = var.email_addresses_for_alerts
    }
  }

}

resource "azurerm_mssql_server_extended_auditing_policy" "primary" {
  count                                   = var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_sql_server.primary.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring == true && var.log_analytics_workspace_id != null ? true : false
}

resource "azurerm_sql_server" "secondary" {
  count                        = var.enable_failover_group ? 1 : 0
  name                         = format("%s-secondary", var.sqlserver_name)
  resource_group_name          = local.resource_group_name
  location                     = var.secondary_sql_server_location
  version                      = var.mssql_version
  administrator_login          = var.admin_username == null ? "sqladmin" : var.admin_username
  administrator_login_password = var.admin_password == null ? random_password.main.result : var.admin_password
  tags                         = merge({ "Name" = format("%s-secondary", var.sqlserver_name) }, var.tags, )

  dynamic "identity" {
    for_each = var.identity != null ? [1] : []
    content {
      type         = var.identity.type
    }
  }

  dynamic "threat_detection_policy" {
    for_each = local.if_threat_detection_policy_enabled
    content {
      state                      = "Enabled"
      storage_endpoint           = azurerm_storage_account.storeacc[0].primary_blob_endpoint
      storage_account_access_key = azurerm_storage_account.storeacc[0].primary_access_key
      retention_days             = var.log_retention_days
      email_addresses            = var.email_addresses_for_alerts
    }
  }

}

resource "azurerm_mssql_server_extended_auditing_policy" "secondary" {
  count                                   = var.enable_failover_group && var.enable_sql_server_extended_auditing_policy ? 1 : 0
  server_id                               = azurerm_sql_server.secondary[0].id
  storage_endpoint                        = azurerm_storage_account.storeacc[0].primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc[0].primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring == true && var.log_analytics_workspace_id != null ? true : null
}

# Criação de Banco de Dados SQL - Edição padrão:"Standard" e objetivo:"S1"

resource "azurerm_sql_database" "db" {
  name                             = var.database_name
  resource_group_name              = local.resource_group_name
  location                         = local.location
  server_name                      = azurerm_sql_server.primary.name
  edition                          = var.sql_database_edition
  requested_service_objective_name = var.sqldb_service_objective_name
  tags                             = merge({ "Name" = format("%s-primary", var.database_name) }, var.tags, )

  dynamic "threat_detection_policy" {
    for_each = local.if_threat_detection_policy_enabled
    content {
      state                      = "Enabled"
      storage_endpoint           = azurerm_storage_account.storeacc.0.primary_blob_endpoint
      storage_account_access_key = azurerm_storage_account.storeacc.0.primary_access_key
      retention_days             = var.log_retention_days
      email_addresses            = var.email_addresses_for_alerts
    }
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "primary" {
  count                                   = var.enable_database_extended_auditing_policy ? 1 : 0
  database_id                             = azurerm_sql_database.db.id
  storage_endpoint                        = azurerm_storage_account.storeacc.0.primary_blob_endpoint
  storage_account_access_key              = azurerm_storage_account.storeacc.0.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.log_retention_days
  log_monitoring_enabled                  = var.enable_log_monitoring == true && var.log_analytics_workspace_id != null ? true : null
}

# Avaliação de vulnerabilidade do SQL Server e alerta para a equipe de administração – o padrão é "false"

resource "azurerm_mssql_server_security_alert_policy" "sap_primary" {
  count                      = var.enable_vulnerability_assessment ? 1 : 0
  resource_group_name        = local.resource_group_name
  server_name                = azurerm_sql_server.primary.name
  state                      = "Enabled"
  email_account_admins       = true
  email_addresses            = var.email_addresses_for_alerts
  retention_days             = var.threat_detection_audit_logs_retention_days
  disabled_alerts            = var.disabled_alerts
  storage_account_access_key = azurerm_storage_account.storeacc[0].primary_access_key
  storage_endpoint           = azurerm_storage_account.storeacc[0].primary_blob_endpoint
}

resource "azurerm_mssql_server_security_alert_policy" "sap_secondary" {
  count                      = var.enable_vulnerability_assessment && var.enable_failover_group ? 1 : 0
  resource_group_name        = local.resource_group_name
  server_name                = azurerm_sql_server.secondary[0].name
  state                      = "Enabled"
  email_account_admins       = true
  email_addresses            = var.email_addresses_for_alerts
  retention_days             = var.threat_detection_audit_logs_retention_days
  disabled_alerts            = var.disabled_alerts
  storage_account_access_key = azurerm_storage_account.storeacc[0].primary_access_key
  storage_endpoint           = azurerm_storage_account.storeacc[0].primary_blob_endpoint
}

resource "azurerm_mssql_server_vulnerability_assessment" "va_primary" {
  count                           = var.enable_vulnerability_assessment ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sap_primary[0].id
  storage_container_path          = "${azurerm_storage_account.storeacc[0].primary_blob_endpoint}${azurerm_storage_container.storcont[0].name}/"
  storage_account_access_key      = azurerm_storage_account.storeacc[0].primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.email_addresses_for_alerts
  }
}

resource "azurerm_mssql_server_vulnerability_assessment" "va_secondary" {
  count                           = var.enable_vulnerability_assessment && var.enable_failover_group == true ? 1 : 0
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sap_secondary[0].id
  storage_container_path          = "${azurerm_storage_account.storeacc[0].primary_blob_endpoint}${azurerm_storage_container.storcont[0].name}/"
  storage_account_access_key      = azurerm_storage_account.storeacc[0].primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails                    = var.email_addresses_for_alerts
  }
}


# Crie e inicialize um banco de dados Microsoft SQL Server usando o utilitário sqlcmd - O padrão é "false"

resource "null_resource" "create_sql" {
  count = var.initialize_sql_script_execution ? 1 : 0
  provisioner "local-exec" {
    command = "sqlcmd -I -U ${azurerm_sql_server.primary.administrator_login} -P ${azurerm_sql_server.primary.administrator_login_password} -S ${azurerm_sql_server.primary.fully_qualified_domain_name} -d ${azurerm_sql_database.db.name} -i ${var.sqldb_init_script_file} -o ${format("%s.log", replace(var.sqldb_init_script_file, "/.sql/", ""))}"
  }
}

# Adicionando AD Admin ao SQL Server - O servidor secundário depende do grupo de failover - O padrão é "false"

resource "azurerm_sql_active_directory_administrator" "aduser1" {
  count               = var.ad_admin_login_name != null ? 1 : 0
  server_name         = azurerm_sql_server.primary.name
  resource_group_name = local.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}

resource "azurerm_sql_active_directory_administrator" "aduser2" {
  count               = var.enable_failover_group && var.ad_admin_login_name != null ? 1 : 0
  server_name         = azurerm_sql_server.secondary[0].name
  resource_group_name = local.resource_group_name
  login               = var.ad_admin_login_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
}


# Regra de Firewall SQL do Azure - O padrão é "false"

resource "azurerm_sql_firewall_rule" "fw01" {
  count               = var.enable_firewall_rules && length(var.firewall_rules) > 0 ? length(var.firewall_rules) : 0
  name                = element(var.firewall_rules, count.index).name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  start_ip_address    = element(var.firewall_rules, count.index).start_ip_address
  end_ip_address      = element(var.firewall_rules, count.index).end_ip_address
}

resource "azurerm_sql_firewall_rule" "fw02" {
  count               = var.enable_failover_group && var.enable_firewall_rules && length(var.firewall_rules) > 0 ? length(var.firewall_rules) : 0
  name                = element(var.firewall_rules, count.index).name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_sql_server.secondary[0].name
  start_ip_address    = element(var.firewall_rules, count.index).start_ip_address
  end_ip_address      = element(var.firewall_rules, count.index).end_ip_address
}

# Grupo de Failover SQL do Azure - O padrão é "false"

resource "azurerm_sql_failover_group" "fog" {
  count               = var.enable_failover_group ? 1 : 0
  name                = format("%s-sqldb-failover-group", var.sqlserver_name)
  resource_group_name = local.resource_group_name
  server_name         = azurerm_sql_server.primary.name
  databases           = [azurerm_sql_database.db.id]
  tags                = merge({ "Name" = format("%s", "sqldb-failover-group") }, var.tags, )

  partner_servers {
    id = azurerm_sql_server.secondary[0].id
  }

  read_write_endpoint_failover_policy {
    mode          = "Automatic"
    grace_minutes = 60
  }

  readonly_endpoint_failover_policy {
    mode = "Enabled"
  }
}

# Link Privado para SQL Server - O padrão é "false"

data "azurerm_virtual_network" "vnet01" {
  count               = var.enable_private_endpoint && var.existing_vnet_id == null ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "snet-ep" {
  count                                          = var.enable_private_endpoint && var.existing_subnet_id == null ? 1 : 0
  name                                           = "tf-network-full-vnet-subnet-by-${var.sqlserver_name}"
  resource_group_name                            = local.resource_group_name
  virtual_network_name                           = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01[0].name : element(split("/", var.existing_vnet_id), 8)
  address_prefixes                               = var.private_subnet_address_prefix
}

resource "azurerm_private_endpoint" "pep1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-primary-private-endpoint", var.sqlserver_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet-ep[0].id : var.existing_subnet_id
  tags                = merge({ "Name" = format("%s", "sqldb-private-endpoint") }, var.tags, )

  private_service_connection {
    name                           = format("%s-sqldbprivatelink-primary", var.sqlserver_name)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.primary.id
    subresource_names              = ["sqlServer"]
  }
}

resource "azurerm_private_endpoint" "pep2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = format("%s-secondary-private-endpoint", var.sqlserver_name)
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet-ep[0].id : var.existing_subnet_id
  tags                = merge({ "Name" = format("%s", "sqldb-private-endpoint") }, var.tags, )

  private_service_connection {
    name                           = format("%s-sqldbprivatelink-primary", var.sqlserver_name)
    is_manual_connection           = false
    private_connection_resource_id = azurerm_sql_server.secondary[0].id
    subresource_names              = ["sqlServer"]
  }
}

# Zona DNS e registros para endpoints privados SQL - O padrão é "false"

data "azurerm_private_endpoint_connection" "private-ip1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep1[0].name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_sql_server.primary]
}

data "azurerm_private_endpoint_connection" "private-ip2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep2[0].name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_sql_server.secondary]
}

resource "azurerm_private_dns_zone" "dnszone1" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.azurerm_private_dns_zone_name
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "SQL-Private-DNS-Zone") }, var.tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vent-link1" {
  count                 = var.enable_private_endpoint ? 1 : 0
  name                  = format("%s-vnet-private-zone-link", var.sqlserver_name)
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1[0].name : var.existing_private_dns_zone
  virtual_network_id    = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet01[0].id : var.existing_vnet_id
  registration_enabled  = true
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.tags, )
}

resource "azurerm_private_dns_a_record" "arecord1" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_sql_server.primary.name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1[0].name : var.existing_private_dns_zone
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip1[0].private_service_connection[0].private_ip_address]
}

resource "azurerm_private_dns_a_record" "arecord2" {
  count               = var.enable_failover_group && var.enable_private_endpoint ? 1 : 0
  name                = azurerm_sql_server.secondary[0].name
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dnszone1[0].name : var.existing_private_dns_zone
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.private-ip2[0].private_service_connection[0].private_ip_address]

}


# Diagnóstico de monitoramento do azurerm – O padrão é “false”

resource "azurerm_monitor_diagnostic_setting" "extaudit" {
  count                      = var.enable_log_monitoring == true && var.log_analytics_workspace_id != null ? 1 : 0
  name                       = lower("extaudit-${var.database_name}-diag")
  target_resource_id         = azurerm_sql_database.db.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  storage_account_id         = var.storage_account_id != null ? var.storage_account_id : null

  dynamic "enabled_log" {
    for_each = var.extaudit_diag_logs
    content {
      category = enabled_log.value
      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [log, metric]
  }
}