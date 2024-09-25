locals {
  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  stack               = "${var.app_environment_configuration.name}-${var.app_environment_configuration.name}-${var.location}"
}

# Criação ou seleção de grupo de recursos - O padrão é "false"

data "azurerm_resource_group" "rgrp" {
  count = var.create_resource_group ? 0 : 1
  name  = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = lower(var.resource_group_name)
  location = var.location
  tags     = merge({ "ResourceName" = format("%s", var.resource_group_name) }, var.tags, )
}

/* Incluindo Componente Dapr ao App Container Environment - O padrão é "falso" */
resource "azurerm_container_app_environment_dapr_component" "dapr" {
  count                        = var.create_dapr_component && length(var.dapr_components) > 0 ? length(var.dapr_components) : 0
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  name                         = element(var.dapr_components, count.index).name
  component_type               = element(var.dapr_components, count.index).component_type
  version                      = element(var.dapr_components, count.index).version
  ignore_errors                = element(var.dapr_components, count.index).ignore_errors
  init_timeout                 = element(var.dapr_components, count.index).init_timeout
  scopes                       = element(var.dapr_components, count.index).scopes

  dynamic "metadata" {
    for_each = element(var.dapr_components, count.index).metadata
    content {
      name        = metadata.value.name
      secret_name = metadata.value.secret_name
      value       = metadata.value.value
    }
  }

  dynamic "secret" {
    for_each = element(var.dapr_components, count.index).secret != null ? element(var.dapr_components, count.index).secret : []
    content {
      name  = element(var.dapr_components, count.index)[0].name
      value = element(var.dapr_components, count.index)[0].value
    }
  }

}

resource "azurerm_container_app_environment_storage" "appstorage" {
  count                        = var.enable_storage_share ? 1 : 0
  name                         = var.storage_settings.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  share_name                   = var.storage_settings.share_name
  access_mode                  = var.storage_settings.access_mode
  account_name                 = var.storage_settings.account_name
  access_key                   = var.storage_settings.primary_access_key
}

resource "azurerm_container_app_environment" "app_env" {
  name                                        = var.app_environment_configuration.name
  location                                    = var.location
  resource_group_name                         = var.resource_group_name
  log_analytics_workspace_id                  = var.app_environment_configuration.log_analytics_workspace_id
  dapr_application_insights_connection_string = var.app_environment_configuration.dapr_application_insights_connection_string
  infrastructure_resource_group_name          = var.workload_profile != null ? var.app_environment_configuration.infrastructure_resource_group_name : null
  infrastructure_subnet_id                    = var.app_environment_configuration.infrastructure_subnet_id
  internal_load_balancer_enabled              = var.app_environment_configuration.internal_load_balancer_enabled
  zone_redundancy_enabled                     = var.app_environment_configuration.zone_redundancy_enabled
  mutual_tls_enabled                          = var.app_environment_configuration.mutual_tls_enabled
  tags                                        = merge({ "Name" = format("%s", "AppEnvironment-${var.app_environment_configuration.name}") }, var.tags, )

  dynamic "workload_profile" {
    for_each = var.workload_profile != null ? [1] : []
    content {
      name                  = var.workload_profile.name
      workload_profile_type = var.workload_profile.workload_profile_type
      maximum_count         = var.workload_profile.maximum_count
      minimum_count         = var.workload_profile.minimum_count
    }
  }

  lifecycle {
    precondition {
      condition     = var.app_environment_configuration.internal_load_balancer_enabled == null || var.app_environment_configuration.infrastructure_subnet_id != null
      error_message = "`var.container_app_environment_internal_load_balancer_enabled` can only be set when `var.container_app_environment_infrastructure_subnet_id` is specified."
    }

    ignore_changes = [ workload_profile ]
  }

}

resource "azurerm_container_app_environment_custom_domain" "example" {
  count                        = var.enable_container_app_environment_domain ? 1 : 0
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  certificate_blob_base64      = var.container_app_environment_custom_domain.certificate_base64
  certificate_password         = var.container_app_environment_custom_domain.password
  dns_suffix                   = var.container_app_environment_custom_domain.dns_suffix
}

resource "azurerm_container_app_environment_certificate" "env_certificate" {
  count                        = var.enable_container_app_certificate ? 1 : 0
  name                         = "tf-cert-${local.stack}"
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  certificate_blob_base64      = var.container_app_environment_custom_domain.certificate_base64
  certificate_password         = var.container_app_environment_custom_domain.password

  tags = var.tags
}