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

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "location" {
  description = "O local/região para manter todos os recursos da sua rede. Para obter a lista de todos os locais com formato de tabela do Azure CLI, execute 'az account list-locations -o table'"
  default     = ""
}

variable "container_app_environment_id" {
  description = "O ID do Container App Environment dentro do qual este Container App deve existir."
  default     = ""
  type        = string
}

variable "container" {
  type = object({
    name    = string
    image   = string
    cpu     = string
    memory  = string
    args    = optional(list(string))
    command = optional(list(string))
  })
  default = null
}

variable "environment_variables" {
  type    = list(any)
  default = []
}

variable "liveness_probe" {
  type    = any
  default = {}
}

variable "readiness_probe" {
  type    = any
  default = {}
}

variable "startup_probe" {
  type    = any
  default = {}
}

variable "volume_mounts" {
  type    = list(any)
  default = []
}

variable "volume" {
  type    = any
  default = {}
}

variable "init_container" {
  type    = any
  default = {}
}

variable "registry" {
  type = list(object({
    server               = string
    identity             = optional(string)
    password_secret_name = optional(string)
    username             = optional(string)
  }))
  default = []
}

variable "event_trigger_config" {
  type = object({
    parallelism              = optional(string)
    replica_completion_count = optional(string)
    scale = optional(object({
      max_executions              = optional(number, 3)
      min_executions              = optional(number, 1)
      polling_interval_in_seconds = optional(number, 10)
      rules = optional(list(any))
    }))
  })
  default = null
}

variable "manual_trigger_config" {
  type = object({
    parallelism              = optional(string)
    replica_completion_count = optional(string)
  })
  default = null
}

variable "schedule_trigger_config" {
  type = object({
    cron_expression          = string
    parallelism              = optional(string)
    replica_completion_count = optional(string)
  })
  default = null
}

variable "app_job_settings" {
  type = object({
    name                       = string
    tags                       = optional(map(string))
    workload_profile_name      = optional(string)
    replica_timeout_in_seconds = number
    replica_retry_limit        = optional(number)
  })
  default = null
}

variable "identity_ids" {
  description = "Especifica uma lista de IDs de identidade gerenciados pelo usuário a serem atribuídos. Isso é necessário quando `type` é definido como `UserAssigned` ou `SystemAssigned, UserAssigned`"
  default     = null
}

variable "secret" {
  type = list(object({
    name                = string
    value               = optional(string)
    identity            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default     = []
  description = "(Opcional) Os segredos dos aplicativos de contêiner. A chave do mapa deve estar alinhada com o aplicativo contêiner correspondente."
}
