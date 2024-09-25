module "app_job_container" {
  source = "./resources/app_job"

  resource_group_name          = "tf-compute-dev-rg"
  location                     = "eastus"
  container_app_environment_id = azurerm_container_app_environment.example.id

  app_job_settings = {
    name = "job-nginx-example-1"
    tags = {
      job = "JobExample"
    }
    replica_timeout_in_seconds = 10
    replica_retry_limit        = 10
  }

  container = {
    name = "nginx-job"
    image  = "nginx:latest"
    cpu    = "0.25"
    memory = "0.5Gi"
    environment_variables = {
      "ENV_VAR1" = "value1"
      "ENV_VAR2" = "value2"
    }
    liveness_probe = {
      transport               = "HTTP"
      path                    = "/health"
      port                    = 80
      initial_delay           = 30
      interval_seconds        = 30
      timeout                 = 15
      failure_count_threshold = 3
      header = {
        name  = "Content-Type"
        value = "application/json"
      }
    }
    volume_mounts = [
      {
        name = "shared"
        path = "/usr/share/nginx/html"
      }
    ]
  }

#  secret = [
#    {
#      name  = "acrpassword"
#      value = "data.azurerm_container_registry.acr.admin_username"
#    },
#    {
#      name  = "azp-token"
#      value = "data.azurerm_key_vault_secret.azptoken.value"
#    },
#    {
#      identity            = "data.azurerm_user_assigned_identity.aca_user_identity.id"
#      key_vault_secret_id = "data.azurerm_key_vault_secret.azptoken.id"
#      name                = "azp-token"
#    }
#  ]

  #identity_ids = [data.azurerm_user_assigned_identity.aca_user_identity.id] # Exemplo para UserAssignedId

  #    registry = [
  #        {
  #          server               = "http://serverhost.com:4000"
  #          username             = "UserName"
  #          password_secret_name = "Password123"
  #        }
  #      ]

# (Opcional) Somente um tipo de schedulle dentre `manual_trigger_config`, `event_trigger_config` ou `schedule_trigger_config` pode ser especificado.
#  manual_trigger_config = {
#    parallelism              = 4
#    replica_completion_count = 1
#  }
#  schedule_trigger_config = {
#    cron_expression = "0 8 * * MON" # Rodar às 8h00 de toda segunda-feira
#  }
  event_trigger_config = {
    replica_completion_count = 1
    parallelism              = 1
    scale = {
      min_executions              = 0
      max_executions              = 2
      polling_interval_in_seconds = 30
      rules = [
        {
          name             = "azure-pipelines"
          custom_rule_type = "azure-pipelines",
          metadata = {
            demands                    = "agent_config_capabilities"
            poolID                     = "poolIdExample"
            targetPipelinesQueueLength = "1"
          },
          authentication = [
            {
              secret_name       = "azp-token"
              trigger_parameter = "personalAccessToken"
            },
            {
              secret_name       = "organization-url"
              trigger_parameter = "organizationURL"
            }
          ]
        }
      ]
    }
  }

}