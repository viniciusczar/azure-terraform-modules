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

variable "location" {
  description = "O local/região para manter todos os recursos da sua rede. Para obter a lista de todos os locais com formato de tabela do Azure CLI, execute 'az account list-locations -o table'"
  default     = ""
}

variable "create_resource_group" {
  description = "Se deve criar um grupo de recursos e usá-lo para todos os recursos de rede. O valor default é `false`"
  default     = false
}

variable "enable_app_custom_domain" {
  description = "Valor booleano para habilitar Custom Domain para o app container. O valor default é `false`"
  default     = false
}

variable "resource_group_name" {
  description = "Nome do grupo de recursos"
  type        = string
  default     = null
}

variable "secret" {
  type = list(object({
    name  = string
    value = optional(string)
    identity = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default     = []
  description = "(Opcional) Os segredos dos aplicativos de contêiner. A chave do mapa deve estar alinhada com o aplicativo contêiner correspondente."
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
  type = list(any)
  default = []
}

variable "liveness_probe" {
  type = any
  default = {}
}

variable "readiness_probe" {
  type = any
  default = {}
}

variable "startup_probe" {
  type = any
  default = {}
}

variable "volume_mounts" {
  type = list(any)
  default = []
}

variable "container_app_configurations" {
  type = object({
    name                  = string
    tags                  = optional(map(string))
    revision_mode         = string
    workload_profile_name = optional(string)
  })
  description = "Os aplicativos de contêiner a serem implantados."
  default = null
}

variable "max_replicas" {
  type = number
  default = null
}

variable "min_replicas" {
  type = number
  default = null
}

variable "revision_suffix" {
  type = string
  default = null
}

variable "volume" {
  type = any
  default = {}
}

variable "init_container" {
  type = any
  default = {}
}

variable "dapr" {
      type = object({
      app_id       = string
      app_port     = number
      app_protocol = optional(string)
    })
    default = null
}

variable "azure_queue_scale_rule" {
  type = list(any)
  default = []
}

variable "custom_scale_rule" {
  type = list(any)
  default = []
}

variable "http_scale_rule" {
  type = list(any)
  default = []
}

variable "tcp_scale_rule" {
  type = list(any)
  default = []
}

variable "ingress" {
  type = object({
    target_port                = number
    exposed_port               = optional(number)
    allow_insecure_connections = optional(bool, false)
    external_enabled           = optional(bool, false)
    transport                  = optional(string)
    fqdn                       = optional(string)
  })
  default = null
}

variable "traffic_weight" {
  type = list(object({
    percentage      = number
    label           = optional(string)
    latest_revision = optional(bool)
    revision_suffix = optional(string)
  }))
  default = []
}

variable "ip_security_restrictions" {
  type = list(object({
    action           = string
    ip_address_range = string
    name             = string
    description      = optional(string)
  }))
  default = null
}

variable "identity" {
  type = object({
      type         = string
      identity_ids = optional(list(string))
    })
  default = null
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

variable "identity_ids" {
  description = "Especifica uma lista de IDs de identidade gerenciados pelo usuário a serem atribuídos. Isso é necessário quando `type` é definido como `UserAssigned` ou `SystemAssigned, UserAssigned`"
  default     = null
}

variable "key_vault_name" {
  description = "O nome do key vault"
  default     = ""
}

variable "key_vault_id" {
  description = "O ID do key vault"
  default     = ""
}

variable "dns_record" {
  description = "O nome do registro TXT do DNS."
  default     = ""
}

variable "dns_zone_name" {
  description = "Especifica a zona DNS onde o recurso existe."
  default     = ""
}

variable "container_app_environment_id" {
  description = "O ID do Container App Environment dentro do qual este Container App deve existir."
  default     = ""
  type = string
}

variable "container_app_environment_certificate_id" {
  description = "O ID do Container App Environment Certificate a ser usado. Alterar isso força a criação de um novo recurso."
  default     = ""
  type = string
}

variable "tags" {
  description = "Um map de tags para adicionar a todos os recursos"
  type        = map(string)
  default     = {}
}