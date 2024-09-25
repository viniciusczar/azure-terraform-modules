locals {

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
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

/* Adicionando Domain ao App Container - O padrão é "falso" */

data "azurerm_dns_txt_record" "record" {
  count               = var.enable_app_custom_domain && var.dns_record != null ? 1 : 0
  name                = var.dns_record
  zone_name           = var.dns_zone_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_container_app_custom_domain" "cdomain" {
  count                                    = var.enable_app_custom_domain && var.dns_record != null ? 1 : 0
  name                                     = trimprefix(data.azurerm_dns_txt_record.record[0].fqdn, "asuid.")
  container_app_id                         = azurerm_container_app.main.id
  container_app_environment_certificate_id = var.container_app_environment_certificate_id
  certificate_binding_type                 = "SniEnabled"
}

resource "azurerm_container_app" "main" {
  name                         = var.container_app_configurations.name
  container_app_environment_id = var.container_app_environment_id
  resource_group_name          = local.resource_group_name
  revision_mode                = var.container_app_configurations.revision_mode
  workload_profile_name        = var.container_app_configurations.workload_profile_name
  tags                         = var.container_app_configurations.tags

  template {

    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    revision_suffix = var.revision_suffix

    container {
        cpu     = var.container.cpu
        image   = var.container.image
        memory  = var.container.memory
        name    = var.container.name
        args    = var.container.args
        command = var.container.command
      dynamic "env" {
        for_each = var.environment_variables
        content {
          name        = lookup(environment_variables.value, "name", null)
          secret_name = lookup(environment_variables.value, "secret_name", null)
          value       = lookup(environment_variables.value, "value", null)
        }
      }
      dynamic "liveness_probe" {
        for_each = var.liveness_probe
        content {
          port                    = lookup(liveness_probe.value, "port")
          transport               = lookup(liveness_probe.value, "transport")
          failure_count_threshold = lookup(liveness_probe.value, "failure_count_threshold", null)
          host                    = lookup(liveness_probe.value, "host", null)
          initial_delay           = lookup(liveness_probe.value, "initial_delay", null)
          interval_seconds        = lookup(liveness_probe.value, "interval_seconds", null)
          path                    = lookup(liveness_probe.value, "path", null)
          timeout                 = lookup(liveness_probe.value, "timeout", null)
          dynamic "header" {
            for_each = lookup(liveness_probe.value, "header", null)
            content {
              name  = lookup(header.value, "name")
              value = lookup(header.value, "value")
            }
          }
        }
      }
      dynamic "readiness_probe" { 
        for_each = var.readiness_probe
        content {
          port                    = lookup(readiness_probe.value, "port")
          transport               = lookup(readiness_probe.value, "transport")
          failure_count_threshold = lookup(readiness_probe.value, "failure_count_threshold", null)
          host                    = lookup(readiness_probe.value, "host", null)
          interval_seconds        = lookup(readiness_probe.value, "interval_seconds", null)
          path                    = lookup(readiness_probe.value, "path", null)
          success_count_threshold = lookup(readiness_probe.value, "success_count_threshold", null)
          timeout                 = lookup(readiness_probe.value, "timeout", null)
          dynamic "header" {
            for_each = lookup(readiness_probe.value, "header", null)
            content {
              name  = lookup(header.value, "name")
              value = lookup(header.value, "value")
            }
          }
        }
      }
        dynamic "startup_probe" {
          for_each = var.startup_probe
          content {
            port                    = lookup(startup_probe.value, "port")
            transport               = lookup(startup_probe.value, "transport")
            failure_count_threshold = lookup(startup_probe.value, "failure_count_threshold", null)
            host                    = lookup(startup_probe.value, "host", null)
            interval_seconds        = lookup(startup_probe.value, "interval_seconds", null)
            path                    = lookup(startup_probe.value, "path", null)
            timeout                 = lookup(startup_probe.value, "timeout", null)
            dynamic "header" {
              for_each = lookup(startup_probe.value, "header", null)
              content {
                name  = lookup(header.value, "name")
                value = lookup(header.value, "value")
              }
            }
          }
        }
        dynamic "volume_mounts" {
          for_each = var.volume_mounts
          content {
            name = lookup(volume_mounts.value, "name")
            path = lookup(volume_mounts.value, "path")
          }
        }
    }

        dynamic "volume" {
          for_each = var.volume
    
          content {
            name         = lookup(volume.value, "name")
            storage_name = lookup(volume.value, "storage_name")
            storage_type = lookup(volume.value, "storage_type")
          }
        }

        dynamic "init_container" {
          for_each = var.init_container
          content {
            args    = lookup(init_container.value, args)
            command = lookup(init_container.value, command)
            cpu     = lookup(init_container.value, cpu)
            image   = lookup(init_container.value, image)
            memory  = lookup(init_container.value, memory)
            name    = lookup(init_container.value, name)
            dynamic "env" {
              for_each = lookup(init_container.value, "env", [])
              content {
                name        = lookup(env.value, "name", null)
                secret_name = lookup(env.value, "secret_name", null)
                value       = lookup(env.value, "value", null)
              }
            }
            dynamic "volume_mounts" {
              for_each = lookup(init_container.value, "volume_mounts", [])
              content {
                name = lookup(volume_mounts.value, "name")
                path = lookup(volume_mounts.value, "path")
              }
            }
          }
        }
    
      dynamic "azure_queue_scale_rule" {
        for_each = var.azure_queue_scale_rule
        content {
          name = lookup(azure_queue_scale_rule.value, "name")
          queue_name = lookup(azure_queue_scale_rule.value, "queue_name")
          queue_length = lookup(azure_queue_scale_rule.value, "queue_length")
          dynamic "authentication" {
            for_each = lookup(azure_queue_scale_rule.value, "authentication")
            content {
              secret_name = lookup(authentication.value, "secret_name")
              trigger_parameter = lookup(authentication.value, "trigger_parameter")
            }
          }
        }
      }
    
      dynamic "custom_scale_rule" {
        for_each = var.custom_scale_rule
        content {
          name = lookup(custom_scale_rule.value, "name")
          custom_rule_type = lookup(custom_scale_rule.value, "custom_rule_type")
          metadata = lookup(custom_scale_rule.value, "metadata")
          dynamic "authentication" {
            for_each = lookup(custom_scale_rule.value, "authentication")
            content {
              secret_name = lookup(authentication.value, "secret_name")
              trigger_parameter = lookup(authentication.value, "trigger_parameter")
            }
          }
        }
      }
    
      dynamic "http_scale_rule" {
        for_each = var.http_scale_rule
        content {
          name = lookup(http_scale_rule.value, "name")
          concurrent_requests = lookup(http_scale_rule.value, "concurrent_requests")
          dynamic "authentication" {
            for_each = lookup(http_scale_rule.value, "authentication")
            content {
              secret_name = lookup(authentication.value, "secret_name")
              trigger_parameter = lookup(authentication.value, "trigger_parameter")
            }
          }
        }
      }
    
      dynamic "tcp_scale_rule" {
        for_each = var.tcp_scale_rule
        content {
          name = lookup(tcp_scale_rule.value, "name")
          concurrent_requests = lookup(tcp_scale_rule.value, "concurrent_requests")
          dynamic "authentication" {
            for_each = lookup(tcp_scale_rule.value, "authentication")
            content {
              secret_name = lookup(authentication.value, "secret_name")
              trigger_parameter = lookup(authentication.value, "trigger_parameter")
            }
          }
        }
      }
  }

    dynamic "dapr" {
      for_each = var.dapr != null ? [1] : [0]
  
      content {
        app_id       = var.dapr.app_id
        app_port     = var.dapr.app_port
        app_protocol = var.dapr.app_protocol
      }
    }

    dynamic "secret" {
      for_each = var.secret
      content {
        name  = lookup(secret.value, "name")
        value = lookup(secret.value, "value")
        identity = lookup(secret.value, "identity")
        key_vault_secret_id = lookup(secret.value, "key_vault_secret_id")
      }
    }
  
    identity {
      type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
      identity_ids = var.identity_ids
    }
  
    dynamic "ingress" {
      for_each = var.ingress != null ? [1] : [0]
      content {
        target_port                = var.ingress.target_port
        exposed_port               = var.ingress.exposed_port
        allow_insecure_connections = var.ingress.allow_insecure_connections
        external_enabled           = var.ingress.external_enabled
        transport                  = var.ingress.transport
        fqdn                       = var.ingress.fqdn
        dynamic "traffic_weight" {
          for_each = var.traffic_weight
          content {
            percentage      = lookup(traffic_weight.value, "percentage")
            label           = lookup(traffic_weight.value, "label", null)
            latest_revision = lookup(traffic_weight.value, "latest_revision", null)
            revision_suffix = lookup(traffic_weight.value, "revision_suffix", null)
          }
        }
        dynamic "ip_security_restriction" {
          for_each = var.ip_security_restrictions
          content {
            action           = lookup(ip_security_restriction.value, "action")
            ip_address_range = lookup(ip_security_restriction.value, "ip_address_range")
            name             = lookup(ip_security_restriction.value, "name")
            description      = lookup(ip_security_restriction.value, "description")
          }
        }
      }
    }
    dynamic "registry" {
      for_each = var.registry
      content {
        server               = lookup(registry.value, "server")
        identity             = lookup(registry.value, "identity")
        password_secret_name = lookup(registry.value, "password_secret_name")
        username             = lookup(registry.value, "username")
      }
    }

  lifecycle {
    ignore_changes = [
      secret,
      tags
    ]
  }
}




