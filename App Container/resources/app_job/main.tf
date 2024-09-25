resource "azurerm_container_app_job" "main" {
  name                         = var.app_job_settings.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.container_app_environment_id

  replica_timeout_in_seconds = var.app_job_settings.replica_timeout_in_seconds
  replica_retry_limit        = var.app_job_settings.replica_retry_limit
  workload_profile_name      = var.app_job_settings.workload_profile_name
  tags = var.app_job_settings.tags

  identity {
    type         = var.identity_ids != null ? "SystemAssigned, UserAssigned" : "SystemAssigned"
    identity_ids = var.identity_ids
  }

  template {

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
            args    = lookup(init_container.value, "args")
            command = lookup(init_container.value, "command")
            cpu     = lookup(init_container.value, "cpu")
            image   = lookup(init_container.value, "image")
            memory  = lookup(init_container.value, "memory")
            name    = lookup(init_container.value, "name")
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

    dynamic "registry" {
      for_each = var.registry
      content {
        server               = lookup(registry.value, "server")
        identity             = lookup(registry.value, "identity")
        password_secret_name = lookup(registry.value, "password_secret_name")
        username             = lookup(registry.value, "username")
      }
    }

  dynamic "event_trigger_config" {
    for_each = var.event_trigger_config != null && var.schedule_trigger_config == null && var.manual_trigger_config == null ? [1] : []
    content {
      parallelism              = var.event_trigger_config.parallelism
      replica_completion_count = var.event_trigger_config.replica_completion_count
      dynamic "scale" {
        for_each = var.event_trigger_config.scale != null ? [1] : []
        content {
          max_executions              = var.event_trigger_config.scale.max_executions
          min_executions              = var.event_trigger_config.scale.min_executions
          polling_interval_in_seconds = var.event_trigger_config.scale.polling_interval_in_seconds
          dynamic "rules" {
            for_each = var.event_trigger_config.scale.rules
            content {
              name             = lookup(rules.value, "name")
              custom_rule_type = lookup(rules.value, "custom_rule_type")
              metadata         = lookup(rules.value, "metadata")
              dynamic "authentication" {
                for_each = lookup(rules.value, "authentication")
                content {
                  secret_name       = lookup(authentication.value, "secret_name")
                  trigger_parameter = lookup(authentication.value, "trigger_parameter")
                }
              }
            }
          }
        }
      }
    }
  }

  dynamic "schedule_trigger_config" {
    for_each = var.schedule_trigger_config != null && var.event_trigger_config == null && var.manual_trigger_config == null ? [1] : []
    content {
      cron_expression          = var.schedule_trigger_config.cron_expression
      parallelism              = var.schedule_trigger_config.parallelism
      replica_completion_count = var.schedule_trigger_config.replica_completion_count
    }
  }

  dynamic "manual_trigger_config" {
    for_each = var.manual_trigger_config != null && var.event_trigger_config == null && var.schedule_trigger_config == null ? [1] : []
    content {
      parallelism              = var.manual_trigger_config.parallelism
      replica_completion_count = var.manual_trigger_config.replica_completion_count
    }
  }

  lifecycle {
    ignore_changes = [
      secret,
      tags
    ]
  }
}